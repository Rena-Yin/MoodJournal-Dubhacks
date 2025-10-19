import 'package:flutter/material.dart';

class MoodInsightsPage extends StatelessWidget {
  const MoodInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Insights')),
      body: const Center(child: Text('Charts and stats go here')),
    );
  }
}
