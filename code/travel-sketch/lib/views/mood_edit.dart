import 'package:flutter/material.dart';
import 'package:food_finder/models/mood_entry.dart';

class MoodEditPage extends StatefulWidget {
  final MoodEntry? entry;

  const MoodEditPage({this.entry, super.key});

  @override
  State<MoodEditPage> createState() => _MoodEditPageState();
}

class _MoodEditPageState extends State<MoodEditPage> {
  late int mood;
  final notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    mood = widget.entry?.mood ?? 3;
    notesCtrl.text = widget.entry?.notes ?? '';
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry == null ? 'New Mood' : 'Edit Mood')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Mood'),
          Slider(value: mood.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => mood = v.toInt())),
          TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {
            // Save via provider (TODO: implement)
            Navigator.of(context).pop();
          }, child: const Text('Save'))
        ]),
      ),
    );
  }
}
