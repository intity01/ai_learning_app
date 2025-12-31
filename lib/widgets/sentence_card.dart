import 'package:flutter/material.dart';

class SentenceCard extends StatelessWidget {
  final String sentence;
  final String translation;
  final VoidCallback onPlay;

  const SentenceCard({
    super.key,
    required this.sentence,
    required this.translation,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sentence,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(translation, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}