import 'package:isar/isar.dart';

part 'mood_entry.g.dart';

@collection
class MoodEntry {
  Id id = Isar.autoIncrement;

  DateTime? createdAt;
  DateTime? updatedAt;

  double? latitude;
  double? longitude;

  // Simple integer mood score (e.g., 1-5) or enum mapping
  int mood;

  String? notes;

  // Path to saved canvas image
  String? imagePath;

  MoodEntry({
    this.id = Isar.autoIncrement,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    required this.mood,
    this.notes,
    this.imagePath,
  }) {
    createdAt ??= DateTime.now();
  }
}
