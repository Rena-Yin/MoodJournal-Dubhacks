import 'package:isar/isar.dart';
import 'gallery_entry.dart';

/// A class that manages the collection of saved drawings in the gallery.
/// This class provides functionality to:
/// - Store and retrieve gallery entries
/// - Maintain a synchronized list of entries
/// - Handle database operations for entries
class Gallery {
  // Database instance for persistent storage
  final Isar _isar;
  
  // Internal list of gallery entries
  // Invariant: no duplicate IDs
  final List<GalleryEntry> _entries;

  /// Creates a new Gallery instance.
  /// This constructor:
  /// - Initializes the gallery with entries from the database
  /// - Maintains synchronization between memory and database
  /// Parameters:
  ///   - isar: The database instance for persistent storage
  Gallery({required Isar isar})
      : _entries = isar.galleryEntrys.where().findAllSync(),
        _isar = isar;

  /// Returns a copy of the current gallery entries.
  /// This getter:
  /// - Creates a new list to prevent external modification
  /// - Maintains encapsulation of the internal entries list
  /// Returns: A new list containing all gallery entries
  List<GalleryEntry> get entries => List.from(_entries);

  /// Adds or updates a gallery entry.
  /// This method:
  /// - Adds new entries to the list
  /// - Updates existing entries if they have the same ID
  /// - Synchronizes changes with the database
  /// Parameters:
  ///   - entry: The gallery entry to add or update
  void upsertEntry(GalleryEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }

    _isar.writeTxnSync(() {
      _isar.galleryEntrys.putSync(entry);
    });
  }

  /// Creates a new Gallery instance with the same database connection.
  /// This method:
  /// - Creates a new instance with the same database
  /// - Loads fresh entries from the database
  /// Returns: A new Gallery instance
  Gallery clone() {
    return Gallery(isar: _isar);
  }
}
