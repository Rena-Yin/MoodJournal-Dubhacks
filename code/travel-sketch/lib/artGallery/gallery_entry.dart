import 'package:isar/isar.dart';
part 'gallery_entry.g.dart';

/// A model class representing a single entry in the art gallery.
/// This class is used to store and manage information about saved drawings,
/// including their metadata and file locations.
@collection
class GalleryEntry {
  /// Unique identifier for the gallery entry in the database
  Id? id;

  /// Title of the drawing as provided by the user
  final String title;
  
  /// File system path where the drawing image is stored
  final String imagePath;
  
  /// Timestamp when the drawing was first saved
  final DateTime createdAt;
  
  /// Timestamp when the drawing was last modified
  final DateTime updatedAt;

  /// Creates a new GalleryEntry instance.
  /// Parameters:
  ///   - id: Optional database identifier
  ///   - title: The title of the drawing
  ///   - imagePath: Path to the stored image file
  ///   - createdAt: Creation timestamp
  ///   - updatedAt: Last modification timestamp
  GalleryEntry({
    this.id,
    required this.title,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new GalleryEntry with current timestamp and optional initial values.
  /// This factory constructor is used when saving a new drawing.
  /// Parameters:
  ///   - title: Optional title for the drawing (defaults to empty string)
  ///   - imagePath: Optional path to the image file (defaults to empty string)
  /// Returns: A new GalleryEntry instance with current timestamps
  factory GalleryEntry.fresh({
    String title = '',
    String imagePath = '',
  }) {
    final now = DateTime.now();
    return GalleryEntry(
      title: title,
      imagePath: imagePath,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a new GalleryEntry with updated values 
  /// while preserving the original ID and creation time.
  /// This method is used when modifying an existing gallery entry.
  /// Parameters:
  ///   - title: Optional new title for the drawing
  ///   - imagePath: Optional new path to the image file
  /// Returns: A new GalleryEntry instance with updated values 
  /// and current modification timestamp
  GalleryEntry withUpdatedValues({
    String? title,
    String? imagePath,
  }) {
    return GalleryEntry(
      id: id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}