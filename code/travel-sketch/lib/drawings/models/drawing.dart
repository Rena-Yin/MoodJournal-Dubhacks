import 'draw_actions/draw_actions.dart';

/// This class represents a drawing, which consists of a list of drawing actions.
/// It also contains the width and height of the drawing area.
class Drawing {
  //width of the drawing canvas
  final double width;
  //height of the drawing canvas
  final double height;
  //a list of the drawing actions
  final List<DrawAction> drawActions;

  //constructs a Drawing with actions and its dimensions
  Drawing(this.drawActions, {required this.width, required this.height});
}
