import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// A service that handles the storage and management of drawing images.
/// This service provides functionality to:
/// - Save drawings as PNG files
/// - Retrieve a list of saved drawings
/// - Delete saved drawings
class ImageStorageService {
  /// Saves an image to the application's documents directory.
  /// Creates a 'drawings' subdirectory if it doesn't exist.
  /// Parameters:
  ///   - imageBytes: The raw bytes of the image to save
  ///   - title: The title of the drawing, used in the filename
  /// Returns: The full path to the saved image file
  Future<String> saveImage(List<int> imageBytes, String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'drawings'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$title.png';
    final file = File(path.join(imagesDir.path, fileName));
    await file.writeAsBytes(imageBytes);
    
    return file.path;
  }

  /// Retrieves a list of all saved drawing image paths.
  /// Returns an empty list if no drawings exist.
  /// Returns: A list of file paths to all saved drawings
  Future<List<String>> getSavedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(directory.path, 'drawings'));
    
    if (!await imagesDir.exists()) {
      return [];
    }

    final files = await imagesDir.list().toList();
    return files
        .whereType<File>()
        .map((file) => file.path)
        .toList();
  }

  /// Deletes a saved drawing image from storage.
  /// Parameters:
  ///   - imagePath: The full path to the image file to delete
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
} 