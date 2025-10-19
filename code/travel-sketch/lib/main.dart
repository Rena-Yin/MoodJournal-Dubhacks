import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:food_finder/models/venues_db.dart';
import 'package:food_finder/providers/position_provider.dart';
import 'package:food_finder/providers/weather_provider.dart';
import 'package:food_finder/views/drawing_app.dart';
import 'package:food_finder/drawings/providers/drawing_provider.dart';
import 'package:food_finder/providers/mood_provider.dart';
import 'package:food_finder/models/mood_entry.dart';
import 'package:food_finder/artGallery/gallery_entry.dart';
import 'package:food_finder/views/mood_edit.dart';
import 'package:food_finder/views/mood_history.dart';
import 'package:food_finder/views/mood_insights.dart';
import 'package:food_finder/views/mood_map.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// Loads the venues database from a JSON file.
/// This function:
/// - Reads the JSON file from the app's assets
/// - Initializes the VenuesDB with the loaded data
/// Parameters:
///   - dataPath: The path to the venues JSON file in the assets
/// Returns: A Future that completes with the initialized VenuesDB
Future<VenuesDB> loadVenuesDB(String dataPath) async {
  return VenuesDB.initializeFromJson(await rootBundle.loadString(dataPath));
}

/// The entry point of the application.
/// This function:
/// - Initializes Flutter bindings
/// - Loads the venues database
/// - Sets up providers for:
///   - Position tracking
///   - Weather information
///   - Drawing functionality
/// - Launches the main app
Future<void> main() async {
  // await dotenv.load();
  const dataPath = 'assets/venues.json';
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  // Register both MoodEntry and existing GalleryEntry schema so they can
  // coexist in the same Isar instance.
  // GalleryEntrySchema comes from the generated file in lib/artGallery
  final isar = await Isar.open([
    MoodEntrySchema,
    GalleryEntrySchema,
  ], directory: dir.path);

  loadVenuesDB(dataPath).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PositionProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ChangeNotifierProvider(
              create: (_) => DrawingProvider(width: 300, height: 300)),
          ChangeNotifierProvider(create: (_) => MoodProvider(isar: isar)),
        ],
        child: MaterialApp(
          title: 'Mood Journal',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: DrawingApp(venues: value),
          routes: {
            '/mood/new': (_) => const MoodEditPage(),
            '/mood/history': (_) => const MoodHistoryPage(),
            '/mood/insights': (_) => const MoodInsightsPage(),
            '/mood/map': (_) => const MoodMapPage(),
          },
        ),
      ),
    ),
  );
}
