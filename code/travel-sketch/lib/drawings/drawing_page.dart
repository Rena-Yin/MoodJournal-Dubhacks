import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/drawings/views/palette.dart';
import 'package:food_finder/drawings/views/draw_area.dart';
import 'package:food_finder/drawings/providers/drawing_provider.dart';
import 'package:food_finder/services/image_storage_service.dart';
import 'package:food_finder/artGallery/gallery_entry.dart';
import 'package:isar/isar.dart';

/// A page that provides a canvas for users to create drawings.
/// Features include:
/// - Drawing tools accessible through a palette drawer
/// - Save functionality to store drawings in the gallery
/// - Undo/redo capabilities
/// - Canvas clearing
class DrawingPage extends StatefulWidget {
  // Width of the drawing canvas
  final double width;
  
  // Height of the drawing canvas
  final double height;
  
  /// Creates a new DrawingPage instance.
  /// Parameters:
  ///   - width: The width of the drawing canvas
  ///   - height: The height of the drawing canvas
  const DrawingPage({super.key, required this.width, required this.height});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // Key used to capture the drawing area for saving
  final GlobalKey _drawingKey = GlobalKey();

  /// Clears all content from the drawing canvas.
  /// Parameters:
  ///   - context: The build context
  void _clear(BuildContext context) {
    Provider.of<DrawingProvider>(context, listen: false).clear();
  }

  /// Reverts the last drawing action.
  /// Parameters:
  ///   - context: The build context
  void _undo(BuildContext context) {
    Provider.of<DrawingProvider>(context, listen: false).undo();
  }

  /// Restores the last undone drawing action.
  /// Parameters:
  ///   - context: The build context
  void _redo(BuildContext context) {
    Provider.of<DrawingProvider>(context, listen: false).redo();
  }

  /// Saves the current drawing to the gallery.
  Future<void> _saveDrawing(BuildContext context) async {
    final drawingProvider = context.read<DrawingProvider>();
    final imageStorageService = ImageStorageService();

    // Show dialog to get drawing title
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Save Your Drawing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Semantics(
                label: 'Drawing title input field',
                hint: 'Enter a title for your drawing',
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Drawing Title',
                    hintText: 'Enter a title for your drawing',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
              ),
            ],
          ),
          actions: [
            Semantics(
              label: 'Cancel saving drawing',
              button: true,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            Semantics(
              label: 'Save drawing to gallery',
              button: true,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        );
      },
    );

    if (title == null || title.isEmpty) return;

    try {
      // Capture the drawing using the GlobalKey
      final boundary = _drawingKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the image to file system
      final imagePath = await imageStorageService.saveImage(pngBytes, title);

      // Get the Isar instance
      final isar = Isar.getInstance();
      if (isar == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not access gallery database'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create and save gallery entry
      final entry = GalleryEntry.fresh(
        title: title,
        imagePath: imagePath,
      );

      await isar.writeTxn(() async {
        await isar.galleryEntrys.put(entry);
      });

      // Clear the canvas
      drawingProvider.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drawing saved to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save drawing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Builds the drawing page UI.
  /// The page includes:
  /// - An app bar with save, clear, undo, and redo actions
  /// - A drawer containing the drawing palette
  /// - The main drawing area
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
        actions: [
          // Save button with a more visible style
          Semantics(
            label: 'Save drawing to the gallery',
            button: true,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _saveDrawing(context),
            ),
          ),
          const SizedBox(width: 8),
          // Clear button
          Semantics(
            label: 'Clear the canvas',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Canvas',
              onPressed: () => _clear(context),
            ),
          ),
          // Undo button
          Consumer<DrawingProvider>(
            builder: (context, provider, _) => Semantics(
              label: 'Undo the last action',
              button: true,
              enabled: provider.pastActions.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: provider.pastActions.isEmpty ? null : () => _undo(context),
              ),
            ),
          ),
          // Redo button
          Consumer<DrawingProvider>(
            builder: (context, provider, _) => Semantics(
              label: 'Redo last undone action',
              button: true,
              enabled: provider.futureActions.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
                onPressed: provider.futureActions.isEmpty ? null : () => _redo(context),
              ),
            ),
          ),
        ],
      ),
      drawer: Semantics(
        label: 'Drawing tools and colors palette',
        child: Drawer(
          child: Palette(context),
        ),
      ),
      body: Semantics(
        label: 'Drawing canvas area',
        hint: 'Use the tools in the drawer to create your drawing',
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _drawingKey,
                child: DrawArea(width: widget.width, height: widget.height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}