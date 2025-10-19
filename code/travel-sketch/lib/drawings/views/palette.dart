import 'package:food_finder/drawings/models/tools.dart';
import 'package:food_finder/drawings/providers/drawing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// / This widget represents the palette of tools and colors used in the drawing app.
class Palette extends StatelessWidget {
  /// Constructor for the Palette widget.
  const Palette(BuildContext context, {super.key});

  /// Builds the palette widget.
  /// It contains a list of tools and colors that the user can select.
  /// The tools include Line, Stroke, and Oval.
  /// The colors include Red, Green, Blue, Orange, Purple, Black, and Pink.
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, unchangingChild) => Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drawing Tools',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select tools and colors to create your drawing',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Tools',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildToolButton(
                    name: 'Line',
                    icon: Icons.timeline_sharp,
                    tool: Tools.line,
                    provider: drawingProvider,
                  ),
                  _buildToolButton(
                    name: 'Stroke',
                    icon: Icons.brush,
                    tool: Tools.stroke,
                    provider: drawingProvider,
                  ),
                  _buildToolButton(
                    name: 'Oval',
                    icon: Icons.circle_outlined,
                    tool: Tools.oval,
                    provider: drawingProvider,
                  ),
                  const Divider(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Colors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildColorCircle(Colors.red, drawingProvider),
                        _buildColorCircle(Colors.green, drawingProvider),
                        _buildColorCircle(Colors.blue, drawingProvider),
                        _buildColorCircle(Colors.orange, drawingProvider),
                        _buildColorCircle(Colors.purple, drawingProvider),
                        _buildColorCircle(Colors.black, drawingProvider),
                        _buildColorCircle(Colors.pink, drawingProvider),
                        _buildColorCircle(Colors.teal, drawingProvider),
                        _buildColorCircle(Colors.amber, drawingProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a button for selecting a tool.
  /// It returns a widget that contains the tool name and icon.
  Widget _buildToolButton({
    required String name,
    required IconData icon,
    required Tools tool,
    required DrawingProvider provider,
  }) {
    final bool isSelected = provider.toolSelected == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        key: Key(name),
        onTap: () {
          provider.toolSelected = isSelected ? Tools.none : tool;
        },
        borderRadius: BorderRadius.circular(8),
        child: Semantics(
          label: '$name tool',
          selected: isSelected,
          button: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
              border: Border.all(
                color: isSelected ? 
                  const Color.fromARGB(255, 105, 123, 137) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? 
                    const Color.fromARGB(255, 105, 123, 137) : Colors.grey[700],
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? 
                      const Color.fromARGB(255, 105, 123, 137) : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a button for selecting a color.
  /// It returns a widget that contains the color name and a circle of that color.
  Widget _buildColorCircle(Color color, DrawingProvider provider) {
    final bool isSelected = provider.colorSelected == color;
    final String colorName = _getColorName(color);
    return Semantics(
      label: '$colorName color',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () {
          provider.colorSelected = color;
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? 
                const Color.fromARGB(255, 105, 123, 137) : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  /// Returns a user-friendly name for the given color.
  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.green) return 'Green';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.black) return 'Black';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.amber) return 'Amber';
    return 'Custom';
  }
}
