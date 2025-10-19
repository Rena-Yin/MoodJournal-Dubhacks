import 'package:flutter/material.dart';
import 'package:food_finder/models/mood_entry.dart';

/// A very simple map-like canvas that plots mood entries as colored circles
/// based on their latitude/longitude projected into the widget rect.
class SimpleMoodMap extends StatelessWidget {
  final List<MoodEntry> entries;

  const SimpleMoodMap({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MoodPainter(entries),
    );
  }
}

class _MoodPainter extends CustomPainter {
  final List<MoodEntry> entries;

  _MoodPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Determine bounds from entries
    if (entries.isEmpty) {
      // draw placeholder grid
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke;
      const step = 40.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
      final tp = TextPainter(
          text: const TextSpan(text: 'No mood points', style: TextStyle(color: Colors.grey)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: size.width);
      tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
      return;
    }

    final lats = entries.map((e) => e.latitude ?? 0).toList();
    final lons = entries.map((e) => e.longitude ?? 0).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLon = lons.reduce((a, b) => a < b ? a : b);
    final maxLon = lons.reduce((a, b) => a > b ? a : b);

    double projectLat(double lat) {
      if (maxLat - minLat == 0) return size.height / 2;
      return size.height - ((lat - minLat) / (maxLat - minLat)) * size.height;
    }

    double projectLon(double lon) {
      if (maxLon - minLon == 0) return size.width / 2;
      return ((lon - minLon) / (maxLon - minLon)) * size.width;
    }

    for (final e in entries) {
      final mood = e.mood.clamp(1, 5);
      // map mood to color (1 sad=blue ... 5 happy=orange)
      final color = Color.lerp(Colors.blue, Colors.orange, (mood - 1) / 4)!;
      paint.color = color.withOpacity(0.9);
      final dx = projectLon(e.longitude ?? (minLon + maxLon) / 2);
      final dy = projectLat(e.latitude ?? (minLat + maxLat) / 2);
      final r = 6.0 + (mood - 1) * 3.0;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodPainter oldDelegate) => oldDelegate.entries != entries;
}
