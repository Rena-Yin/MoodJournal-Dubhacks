import 'package:food_finder/drawings/models/tools.dart';
import 'package:food_finder/drawings/providers/drawing_provider.dart';
import 'package:food_finder/drawings/models/draw_actions/draw_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'drawing_painter.dart';

/// A stateless widget that provides an interactive drawing area.
/// Handles user gestures and updates the drawing state accordingly.
class DrawArea extends StatelessWidget {
  const DrawArea({super.key, required this.width, required this.height});
  // The width and height of the drawing area.
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, unchangingChild) {
        return CustomPaint(
          size: Size(width, height),
          painter: DrawingPainter(drawingProvider),
          child: Semantics(
            label: 'Interactive drawing canvas',
            hint: 'Draw using finger or stylus based on the selected tool',
            enabled: true,
            container: true,
            child: GestureDetector(
                // Handles user gestures for drawing actions.
                onPanStart: (details) => _panStart(details, drawingProvider),
                onPanUpdate: (details) => _panUpdate(details, drawingProvider),
                onPanEnd: (details) => _panEnd(details, drawingProvider),
                child: Container(
                    width: width,
                    height: height,
                    color: Colors.transparent,
                    child: unchangingChild)),
          ),
        );
      },
    );
  }

  /// Handles the start of a pan gesture.
  /// Initializes the pending drawing action based on the selected tool.
  void _panStart(DragStartDetails details, DrawingProvider drawingProvider) {
    final currentTool = drawingProvider.toolSelected;
    final pos = details.localPosition;
    switch (currentTool) {
      case Tools.none: //No drawing action
        break;
      case Tools.line: //Start drawing a line
        drawingProvider.pendingAction =
            LineAction(pos, pos, drawingProvider.colorSelected);
        break;
      case Tools.oval: //Start drawing an oval
        drawingProvider.pendingAction =
            OvalAction(pos, pos, drawingProvider.colorSelected);
        break;
      case Tools.stroke: //Start drawing a stroke
        drawingProvider.pendingAction =
            StrokeAction([pos], drawingProvider.colorSelected);
        break;
    }
  }

  /// Handles updates during a pan gesture.
  /// Updates the pending drawing action as the user moves.
  void _panUpdate(DragUpdateDetails details, DrawingProvider drawingProvider) {
    final currentTool = drawingProvider.toolSelected;
    final pos = details.localPosition;
    switch (currentTool) {
      case Tools.none: //No drawing action
        break;
      case Tools.line: //Update the line action
        final action = drawingProvider.pendingAction as LineAction;
        drawingProvider.pendingAction =
            LineAction(action.point1, pos, action.color);
        break;
      case Tools.oval: //Update the oval action
        final action = drawingProvider.pendingAction as OvalAction;
        drawingProvider.pendingAction =
            OvalAction(action.point1, pos, action.color);
        break;
      case Tools.stroke: //Update the stroke action
        final action = drawingProvider.pendingAction as StrokeAction;
        final newPoints = [...action.points, pos];
        drawingProvider.pendingAction =
            StrokeAction(newPoints, action.color, action.thicknesses);
        break;
    }
  }

  /// Called when the user lifts their finger from the canvas.
  /// This method commits the pendingAction to the drawing history
  /// and resets the pendingAction to NullAction.
  void _panEnd(DragEndDetails details, DrawingProvider drawingProvider) {
    if (drawingProvider.pendingAction is! NullAction) {
      drawingProvider.add(drawingProvider.pendingAction);
      drawingProvider.pendingAction = NullAction();
    }
  }
}
