import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:food_finder/models/mood_entry.dart';

class MoodProvider with ChangeNotifier {
  final Isar isar;

  MoodProvider({required this.isar});

  Future<List<MoodEntry>> getAll() async {
    return await isar.moodEntrys.where().findAll();
  }

  /// Returns the MoodEntry for a specific date if it exists (matching on day precision).
  Future<MoodEntry?> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    // Filter by createdAt within the day range
    final results = await isar.moodEntrys
        .filter()
        .createdAtBetween(start, end, includeLower: true, includeUpper: false)
        .findAll();
    if (results.isEmpty) return null;
    // If multiple exist, return the latest updated
    results.sort((a, b) => (b.updatedAt ?? b.createdAt!)
        .compareTo((a.updatedAt ?? a.createdAt!)));
    return results.first;
  }

  /// Upserts a mood entry for a specific date (day precision).
  Future<MoodEntry> upsertForDate({
    required DateTime date,
    required int mood,
    String? notes,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    final existing = await getByDate(date);
    if (existing != null) {
      existing.mood = mood;
      existing.notes = notes;
      existing.latitude = latitude ?? existing.latitude;
      existing.longitude = longitude ?? existing.longitude;
      existing.imagePath = imagePath ?? existing.imagePath;
      await update(existing);
      return existing;
    }
    final entry = MoodEntry(
      mood: mood,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
      createdAt: DateTime(date.year, date.month, date.day),
    );
    return await create(entry);
  }

  Future<MoodEntry> create(MoodEntry entry) async {
    final id = await isar.writeTxn(() async => await isar.moodEntrys.put(entry));
    entry.id = id;
    notifyListeners();
    return entry;
  }

  Future<void> update(MoodEntry entry) async {
    entry.updatedAt = DateTime.now();
    await isar.writeTxn(() async => await isar.moodEntrys.put(entry));
    notifyListeners();
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() async => await isar.moodEntrys.delete(id));
    notifyListeners();
  }
}
