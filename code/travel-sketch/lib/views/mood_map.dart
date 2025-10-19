import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_finder/providers/mood_provider.dart';
import 'package:food_finder/mapAPI/simple_mood_map.dart';

class MoodMapPage extends StatefulWidget {
  const MoodMapPage({super.key});

  @override
  State<MoodMapPage> createState() => _MoodMapPageState();
}

class _MoodMapPageState extends State<MoodMapPage> {
  @override
  Widget build(BuildContext context) {
    final moodProv = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Map')),
      body: FutureBuilder(
        future: moodProv.getAll(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snap.data as List;
          return SizedBox.expand(
            child: SimpleMoodMap(entries: List.castFrom(entries)),
          );
        },
      ),
    );
  }
}
