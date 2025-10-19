import 'package:flutter/material.dart';

import '../models/draw_actions/draw_actions.dart';
import '../models/drawing.dart';
import '../models/tools.dart';

/// This class is responsible for managing the drawing state,
/// including the current drawing, selected tool, and color.
/// It also handles the history of drawing actions, allowing for undo and redo functionality.
class DrawingProvider extends ChangeNotifier {
  Drawing?
      _drawing; // used to create a cached drawing via replay of past actions
  DrawAction _pendingAction = NullAction();
  Tools _toolSelected = Tools.none;
  Color _colorSelected = Colors.blue;

  final List<DrawAction> _pastActions;
  final List<DrawAction> _futureActions;

  final double width;
  final double height;

  /// Constructor for the DrawingProvider.
  DrawingProvider({required this.width, required this.height})
      : _pastActions = [],
        _futureActions = [];

  /// Returns the current drawing, creating it if it doesn't exist.
  Drawing get drawing {
    if (_drawing == null) {
      _createCachedDrawing();
    }
    return _drawing!;
  }

  /// Sets the pending action (e.g., a currently-being-drawn shape)
  /// and invalidates the cached drawing to trigger a redraw.
  set pendingAction(DrawAction action) {
    _pendingAction = action;
    _invalidateAndNotify();
  }

  /// Returns the current pending action.
  DrawAction get pendingAction => _pendingAction;

  /// Sets the selected drawing tool (e.g., line, oval, stroke),
  /// and triggers a UI update.
  set toolSelected(Tools aTool) {
    _toolSelected = aTool;
    _invalidateAndNotify();
  }

  Tools get toolSelected => _toolSelected;

  /// Sets the selected drawing color (used in new DrawActions),
  /// and triggers a UI update.
  set colorSelected(Color color) {
    _colorSelected = color;
    _invalidateAndNotify();
  }

  Color get colorSelected => _colorSelected;

  List<DrawAction> get pastActions => _pastActions;

  List<DrawAction> get futureActions => _futureActions;

  /// Creates a new cached Drawing object by replaying all past actions.
  /// This ensures we can reconstruct the full image from just the actions.
  /// Called whenever the drawing needs to be repainted.
  void _createCachedDrawing() {
    _drawing = Drawing(
      List.from(_pastActions),
      width: width,
      height: height,
    );
  }

  /// Invalidates the cached drawing and notifies listeners.
  /// This ensures any UI using the drawing will rebuild.
  void _invalidateAndNotify() {
    _drawing = null;
    notifyListeners();
  }

  /// Adds a new DrawAction to the drawing history.
  /// Clears the redo stack (futureActions), since redo is only valid
  /// immediately after an undo.
  void add(DrawAction action) {
    _pastActions.add(action);
    _futureActions.clear();
    _invalidateAndNotify();
  }

  /// Undoes the last action by removing it from pastActions
  /// and pushing it onto futureActions. Then invalidates drawing.
  /// Can also undo a ClearAction by leaving pastActions as-is and
  /// restoring previous actions when redone.
  void undo() {
    if (_pastActions.isNotEmpty) {
      final action = _pastActions.removeLast();
      _futureActions.add(action);
      _invalidateAndNotify();
    }
  }

  /// Redoes the last undone action by moving it from futureActions
  /// back to pastActions, and re-renders the drawing.
  void redo() {
    if (_futureActions.isNotEmpty) {
      final action = _futureActions.removeLast();
      _pastActions.add(action);
      _invalidateAndNotify();
    }
  }

  /// Clears the drawing by adding a ClearAction to the past actions list.
  /// This can be undone via the undo() method.
  void clear() {
    _pastActions.add(ClearAction());
    futureActions.clear();
    _invalidateAndNotify();
  }
}
