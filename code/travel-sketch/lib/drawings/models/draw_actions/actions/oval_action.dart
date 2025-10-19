import 'package:food_finder/drawings/models/draw_actions/draw_actions.dart';
import 'package:flutter/material.dart';

/// This is used to represent the user choosing to add an oval to their drawing.
/// The oval is defined by two points: the top left and bottom right corners.
/// The color is used to draw the oval.
/// The oval is drawn as a stroke, not filled in.
class OvalAction extends DrawAction{
  final Offset point1;
  final Offset point2;
  final Color color;

  OvalAction(this.point1, this.point2, this.color);
}
