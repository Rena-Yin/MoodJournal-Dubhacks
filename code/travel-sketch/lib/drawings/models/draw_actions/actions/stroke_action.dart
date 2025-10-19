import 'package:flutter/material.dart';
import '../draw_actions.dart';


// This is used to represent a single continuous path drawn by the user, 
// for example, if they put their finger down, wiggled it around, and let go.
class StrokeAction extends DrawAction {
  final List<Offset> points;
  final Color color;
  final double thicknesses;

  StrokeAction(this.points, this.color, [this.thicknesses = 3.0]);
}