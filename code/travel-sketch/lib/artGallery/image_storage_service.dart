import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

/// A singleton service that manages image storage operations for the gallery.
/// Features:
/// - Image picking from device gallery
/// - Saving images to local storage
/// - Deleting images
/// - Retrieving image files and metadata
class ImageStorageService {
  // Singleton instance of the service
  static final ImageStorageService _instance = ImageStorageService._internal();
  
  // Factory constructor to return the singleton instance
  factory ImageStorageService() => _instance;
  
  // Private constructor for singleton pattern
  ImageStorageService._internal();

  // Image picker instance for selecting images from gallery
  final _picker = ImagePicker();

  /// Picks an image from the device gallery and saves it to local storage.
  /// This method:
  /// - Opens the device's image picker
  /// - Applies size and quality constraints
  /// - Saves the selected image
  /// Returns: The path to the saved image, or null if no image was selected
  Future<String?> pickAndSaveImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Allow larger images since we're storing on filesystem
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image == null) return null;

      // Save the picked image
      return await saveImage(File(image.path));
    } catch (e) {
      throw 'Error picking image: $e';
    }
  }

  /// Saves an image file to the application's local storage.
  /// This method:
  /// - Creates a dedicated gallery directory if needed
  /// - Generates a unique filename using UUID
  /// - Copies the image to the new location
  /// Parameters:
  ///   - imageFile: The image file to save
  /// Returns: The path to the saved image
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final galleryDir = Directory('${directory.path}/gallery_images');
    
    // Create gallery directory if it doesn't exist
    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }

    // Generate unique filename
    final uuid = const Uuid().v4();
    final extension = path.extension(imageFile.path);
    final newPath = '${galleryDir.path}/$uuid$extension';

    // Copy the file to the new location
    await imageFile.copy(newPath);
    return newPath;
  }

  /// Deletes an image file from local storage.
  /// This method:
  /// - Checks if the file exists
  /// - Deletes the file if found
  /// Parameters:
  ///   - imagePath: The path to the image file to delete
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Retrieves a File object for a given image path.
  /// This method:
  /// - Checks if the file exists
  /// - Returns the File object if found
  /// Parameters:
  ///   - imagePath: The path to the image file
  /// Returns: The File object if the image exists, null otherwise
  Future<File?> getImageFile(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Calculates the size of an image file in megabytes.
  /// This method:
  /// - Checks if the file exists
  /// - Calculates the file size in MB
  /// Parameters:
  ///   - imagePath: The path to the image file
  /// Returns: The size of the image in MB, or 0 if the file doesn't exist
  Future<double> getImageSizeInMB(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      final size = await file.length();
      return size / (1024 * 1024);
    }
    return 0;
  }
} 