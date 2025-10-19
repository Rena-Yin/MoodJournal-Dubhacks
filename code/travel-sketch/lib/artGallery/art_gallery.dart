import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:food_finder/artGallery/gallery_view.dart';
import 'package:food_finder/artGallery/gallery_entry.dart';

/// A widget that displays the art gallery of saved drawings.
/// Features:
/// - Initializes the Isar database for storing gallery entries
/// - Shows a loading indicator while the database is being opened
/// - Displays error messages if database initialization fails
/// - Renders the gallery view once the database is ready
class ArtGallery extends StatelessWidget {
  /// Creates a new ArtGallery instance.
  const ArtGallery({super.key});

  /// Opens or initializes the Isar database for gallery entries.
  /// This method:
  /// - Checks if an Isar instance already exists
  /// - If not, creates a new instance in the application documents directory
  /// - If yes, returns the existing instance
  /// Returns: A Future that completes with the Isar database instance
  static Future<Isar> _openIsar() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [GalleryEntrySchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// Builds the art gallery UI.
  /// This method:
  /// - Shows a loading indicator while the database is being initialized
  /// - Displays error messages if initialization fails
  /// - Renders the GalleryView once the database is ready
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Isar>(
      future: _openIsar(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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

        return GalleryView(isar: snapshot.data!);
      },
    );
  }
}
