import 'package:flutter/material.dart';
import 'package:food_finder/models/venues_db.dart';
import 'package:food_finder/drawings/drawing_page.dart';
import 'package:food_finder/artGallery/art_gallery.dart';
import 'package:food_finder/views/mood_calendar.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/providers/mood_provider.dart';

/// The main application widget for the Food Finder app.
/// This app provides functionality to:
/// - View and search for food venues
/// - Create and save drawings
/// - Browse saved drawings in the art gallery
class DrawingApp extends StatelessWidget {
  // Database containing venue information
  final VenuesDB venues;

  /// Creates a new DrawingApp instance.
  /// Parameters:
  ///   - venues: The database containing venue information
  const DrawingApp({required this.venues, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      title: 'Capture your travel moment',
      home: MainNavigation(venues: venues),
    );
  }
}

/// The main navigation widget that handles switching between different app sections.
/// Features:
/// - Bottom navigation bar for switching between sections
/// - Dynamic app bar title based on current section
/// - Three main sections: Home, Drawing, and Art Gallery
class MainNavigation extends StatefulWidget {
  // Database containing venue information
  final VenuesDB venues;

  /// Creates a new MainNavigation instance.
  /// Parameters:
  ///   - venues: The database containing venue information
  const MainNavigation({required this.venues, super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Index of the currently selected navigation item
  int _selectedIndex = 0;

  /// Returns the appropriate title string based on the selected navigation item.
  /// Returns:
  ///   - 'Drawing' for the drawing page
  ///   - 'Art Gallery' for the gallery page
  ///   - 'Capture your travel moment' for the home page
  String titleString() {
    switch (_selectedIndex) {
      case 1:
        return 'Drawing';
      case 2:
        return 'Mood Gallery';
      case 3:
        return 'Mood Calendar';
      default:
        return 'Capture your mood';
    }
  }

  /// Builds the main navigation UI with three sections:
  /// - Home page with location and weather information
  /// - Drawing page for creating artwork
  /// - Art Gallery for viewing saved drawings
  DateTime? _homeDate; // null means today

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(date: _homeDate),
      const DrawingPage(width: 300, height: 300),
      ArtGallery(),
      // Provide a callback so the calendar can select a day and switch to Home
      MoodCalendarPage(
        onSelectDay: (d) => setState(() {
          _homeDate = DateTime(d.year, d.month, d.day);
          _selectedIndex = 0;
        }),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ///_selectedIndex == 0 ? 'Capture your travel moment' : 'Drawing'),
          titleString(),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedIconTheme: const IconThemeData(color: Colors.black54),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush),
            label: 'Drawing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.burst_mode),
            label: 'Mood Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Mood Calendar',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

/// The home page widget that displays location and weather information.
/// Features:
/// - Current location display
/// - Weather information
/// - Google Maps integration placeholder
class HomePage extends StatefulWidget {
  final DateTime? date; // if null, defaults to today
  const HomePage({super.key, this.date});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _thoughtsCtrl = TextEditingController();
  // Base colors user can choose (6)
  final List<Color> _baseColors = const [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.pink,
  ];
  int _selectedColorIdx = 1; // 0-5 (default green)
  int _intensity = 2; // 1-3

  // Encode 6 colors x 3 intensities into a single 1..18 integer
  int _encodeMood(int colorIdx, int intensity) => (colorIdx * 3) + intensity;
  // Decode 1..18 into (colorIdx, intensity)
  (int colorIdx, int intensity) _decodeMood(int mood) {
    final m = mood.clamp(1, 18);
    final idx = (m - 1) ~/ 3;
    final sev = ((m - 1) % 3) + 1;
    return (idx, sev);
  }

  Color _shadeForIntensity(Color base, int intensity) {
    // 1: light, 2: base, 3: dark
    if (intensity == 2) return base;
    if (intensity == 1) {
      return Color.lerp(base, Colors.white, 0.5)!;
    }
    return Color.lerp(base, Colors.black, 0.4)!;
  }
  DateTime get _day => widget.date == null
      ? DateTime.now()
      : DateTime(widget.date!.year, widget.date!.month, widget.date!.day);

  @override
  void initState() {
    super.initState();
    // Load existing entry for the specified day
    // Delay to access provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final moodProv = Provider.of<MoodProvider>(context, listen: false);
      final existing = await moodProv.getByDate(_day);
      if (!mounted) return;
      setState(() {
        if (existing?.mood != null && existing!.mood >= 1 && existing.mood <= 18) {
          final decoded = _decodeMood(existing.mood);
          _selectedColorIdx = decoded.$1;
          _intensity = decoded.$2;
        } else {
          _selectedColorIdx = 1;
          _intensity = 2;
        }
        _thoughtsCtrl.text = existing?.notes ?? '';
      });
    });
  }

  @override
  void dispose() {
    _thoughtsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Select your color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_baseColors.length, (i) {
                final color = _baseColors[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIdx = i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColorIdx == i ? Colors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Intensity (1-3: light → dark)'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(3, (i) {
                final level = i + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text('$level'),
                    selected: _intensity == level,
                    onSelected: (_) => setState(() => _intensity = level),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Selected:'),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _shadeForIntensity(_baseColors[_selectedColorIdx], _intensity),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Write your thoughts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _thoughtsCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'How are you feeling today?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final moodProv = Provider.of<MoodProvider>(context, listen: false);
                  await moodProv.upsertForDate(
                    date: _day,
                    mood: _encodeMood(_selectedColorIdx, _intensity),
                    notes: _thoughtsCtrl.text,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved today's mood")),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
