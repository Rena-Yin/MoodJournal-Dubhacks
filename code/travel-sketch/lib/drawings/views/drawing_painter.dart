import 'package:food_finder/drawings/models/drawing.dart';
import 'package:food_finder/drawings/providers/drawing_provider.dart';
import 'package:food_finder/drawings/models/draw_actions/draw_actions.dart';
import 'package:flutter/material.dart';

/// A custom painter that renders drawing actions on a canvas.
/// This class handles the visual representation of all drawing actions,
/// including lines, ovals, and freehand strokes.
class DrawingPainter extends CustomPainter {
  // The current state of the drawing being rendered
  final Drawing _drawing;
  
  // Provider that manages the drawing state and actions
  final DrawingProvider _provider;

  /// Creates a new DrawingPainter instance.
  /// Parameters:
  ///   - provider: The DrawingProvider that manages the drawing state
  DrawingPainter(DrawingProvider provider) : _drawing = provider.drawing, _provider = provider;

  /// Renders the drawing on the canvas.
  /// This method handles both the drawing history and any pending actions.
  /// Parameters:
  ///   - canvas: The canvas to draw on
  ///   - size: The available size for drawing
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.clipRect(rect); // make sure we don't scribble outside the lines.

    // Clear the canvas before drawing.
    final erasePaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(rect, erasePaint);

    // Draw all actions in the drawing history.
    for (final action in _provider.drawing.drawActions) {
      _paintAction(canvas, action, size);
    }

    // Draw the pending action, if it exists and is not a NullAction.
    if (_provider.pendingAction is! NullAction) {
      _paintAction(canvas, _provider.pendingAction, size);
    }
  }

  /// Renders a single drawing action on the canvas.
  /// Handles different types of drawing actions including:
  /// - Lines between two points
  /// - Ovals defined by two points
  /// - Freehand strokes connecting multiple points
  /// - Canvas clearing
  /// Parameters:
  ///   - canvas: The canvas to draw on
  ///   - action: The drawing action to render
  ///   - size: The available size for drawing
  void _paintAction(Canvas canvas, DrawAction action, Size size) {
    final Rect rect = Offset.zero & size;
    final erasePaint = Paint()..blendMode = BlendMode.clear;

    switch (action) {
      case NullAction _: //Do nothing for NullAction
        break;
      case ClearAction _: //Clear the canvas
        canvas.drawRect(rect, erasePaint);
        break;
      case final LineAction lineAction: // Draw a line between two points
        final paint = Paint()
          ..color = lineAction.color
          ..strokeWidth = 2;
        canvas.drawLine(lineAction.point1, lineAction.point2, paint);
        break;
      case final OvalAction ovalAction: // Draw an oval between two points
        final paint = Paint()
          ..color = ovalAction.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        final rect = Rect.fromPoints(ovalAction.point1, ovalAction.point2);
        canvas.drawOval(rect, paint);
        break;
      case final StrokeAction strokeAction: //Draw a freehand stroke connecting a list of points.
        final paint = Paint()
          ..color = strokeAction.color
          ..strokeWidth = strokeAction.thicknesses
          ..style = PaintingStyle.stroke;

        for (int i = 0; i < strokeAction.points.length - 1; i++) {
          canvas.drawLine(strokeAction.points[i], strokeAction.points[i + 1], paint);
        }
        break;
    }
  }

  /// Determines if the painter needs to be redrawn.
  /// Returns true if the drawing state has changed since the last paint.
  /// Parameters:
  ///   - oldDelegate: The previous DrawingPainter instance
  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate._drawing != _drawing;
  }
}
