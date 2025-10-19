import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:food_finder/artGallery/gallery_entry.dart';
import 'package:food_finder/artGallery/image_storage_service.dart';
import 'package:intl/intl.dart';

/// A widget that displays a grid of saved drawings in the art gallery.
/// Features:
/// - Real-time updates when gallery entries change
/// - Grid layout with two columns
/// - Individual gallery items with image, title, and delete functionality
/// - Empty state and error handling
class GalleryView extends StatelessWidget {
  // Database instance for accessing gallery entries
  final Isar isar;

  /// Creates a new GalleryView instance.
  /// Parameters:
  ///   - isar: The Isar database instance for accessing gallery entries
  const GalleryView({super.key, required this.isar});

  /// Builds the gallery view UI.
  /// This method:
  /// - Shows a loading indicator while data is being fetched
  /// - Displays error messages if data fetching fails
  /// - Shows an empty state message if no images exist
  /// - Renders a grid of gallery items if images exist
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<GalleryEntry>>(
        stream: isar.galleryEntrys
            .where()
            .sortByCreatedAtDesc()
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Error message',
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Semantics(
                label: 'Loading',
                child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            );
          }

          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Empty gallery icon',
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'No drawings message',
                    child: Text(
                      'No drawings yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Create drawing suggestion',
                    child: Text(
                      'Create your first drawing in the drawing page',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Semantics(
            label: 'Gallery grid',
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _GalleryItem(
                  entry: entry,
                  onDelete: () => _deleteImage(context, entry),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Deletes a gallery entry and its associated image file.
  /// This method:
  /// - Shows a confirmation dialog
  /// - Deletes the image file from storage
  /// - Removes the entry from the database
  /// Parameters:
  ///   - context: The build context
  ///   - entry: The gallery entry to delete
  Future<void> _deleteImage(BuildContext context, GalleryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drawing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Delete confirmation message',
              child: Text(
                'Are you sure you want to delete "${entry.title}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Delete the image file
    await ImageStorageService().deleteImage(entry.imagePath);

    // Delete the database entry
    await isar.writeTxn(() async {
      await isar.galleryEntrys.delete(entry.id!);
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drawing deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// A widget that displays a single gallery item in the grid.
/// Features:
/// - Displays the saved drawing image
/// - Shows the drawing title and creation date
/// - Provides a delete button
class _GalleryItem extends StatelessWidget {
  // The gallery entry to display
  final GalleryEntry entry;

  // Callback function to handle deletion
  final VoidCallback onDelete;

  /// Creates a new GalleryItem instance.
  /// Parameters:
  ///   - entry: The gallery entry to display
  ///   - onDelete: Callback function to handle deletion
  const _GalleryItem({
    required this.entry,
    required this.onDelete,
  });

  /// Builds the gallery item UI.
  /// This method:
  /// - Displays the image with error handling
  /// - Shows the title and creation date
  /// - Renders a delete button
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Drawing: ${entry.title}',
      button: true,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Semantics(
              label: 'Drawing image',
              image: true,
              child: Image.file(
                File(entry.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      // ignore: deprecated_member_use
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'Drawing title',
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: 'Creation date',
                      child: Text(
                        DateFormat('MMM d, y').format(entry.createdAt),
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: Semantics(
                  label: 'Delete drawing',
                  button: true,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
