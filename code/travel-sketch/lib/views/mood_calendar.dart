import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:food_finder/providers/mood_provider.dart';
import 'package:food_finder/models/mood_entry.dart';
import 'package:food_finder/drawings/drawing_page.dart';

class MoodCalendarPage extends StatefulWidget {
  final ValueChanged<DateTime>? onSelectDay;
  const MoodCalendarPage({super.key, this.onSelectDay});

  @override
  State<MoodCalendarPage> createState() => _MoodCalendarPageState();
}

class _MoodCalendarPageState extends State<MoodCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedMood = 3;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Color _moodToColor(int mood) {
    // Decode our 1..18 scheme: 6 colors * 3 intensities (1=light,2=base,3=dark)
    if (mood < 1 || mood > 18) return Colors.grey.shade200;
    final baseIdx = (mood - 1) ~/ 3; // 0..5
    final intensity = ((mood - 1) % 3) + 1; // 1..3
    final List<Color> bases = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.pink,
    ];
    Color base = bases[baseIdx];
    if (intensity == 2) return base;
    if (intensity == 1) return Color.lerp(base, Colors.white, 0.5)!;
    return Color.lerp(base, Colors.black, 0.4)!;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(5, (i) {
        final mood = i + 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: _moodToColor(mood), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('$mood'),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodProv = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<MoodEntry>>(
        future: moodProv.getAll(),
        builder: (context, snap) {
          final entries = snap.data ?? [];
          final Map<DateTime, MoodEntry> byDay = {
            for (final e in entries)
              if (e.createdAt != null)
                DateTime(e.createdAt!.year, e.createdAt!.month, e.createdAt!.day): e
          };

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.utc(2050, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      final existing = byDay[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ??
                          await moodProv.getByDate(selectedDay);
                      setState(() {
                        _selectedMood = existing?.mood ?? 3;
                        _notesCtrl.text = existing?.notes ?? '';
                      });
                      // Notify selected day to parent if callback provided
                      widget.onSelectDay?.call(selectedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final key = DateTime(day.year, day.month, day.day);
                        final e = byDay[key];
                        final color = e != null ? _moodToColor(e.mood) : Colors.white;
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final key = DateTime(day.year, day.month, day.day);
                        final e = byDay[key];
                        final color = e != null ? _moodToColor(e.mood) : Colors.white;
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueAccent, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final key = DateTime(day.year, day.month, day.day);
                        final e = byDay[key];
                        final color = e != null ? _moodToColor(e.mood) : Colors.white;
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black87, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  if (_selectedDay != null) ...[
                    const Text('Select mood'),
                    Slider(
                      value: _selectedMood.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_selectedMood',
                      onChanged: (v) => setState(() => _selectedMood = v.toInt()),
                    ),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Thoughts', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final day = _selectedDay!;
                            await moodProv.upsertForDate(
                              date: day,
                              mood: _selectedMood,
                              notes: _notesCtrl.text,
                            );
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DrawingPage(width: 300, height: 300),
                              ),
                            );
                          },
                          icon: const Icon(Icons.brush),
                          label: const Text('Open Canvas'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


