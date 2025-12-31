import 'package:flutter/material.dart';

class VocabularyCard extends StatelessWidget {
  final String word;
  final String pronunciation;
  final String translation;
  final VoidCallback onPlay;
  final VoidCallback onSave;

  const VocabularyCard({
    super.key,
    required this.word,
    required this.pronunciation,
    required this.translation,
    required this.onPlay,
    required this.onSave,
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
            Text(word,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(pronunciation, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(translation, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: onSave,
                  icon: const Icon(Icons.star_border),
                  color: Colors.orangeAccent,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}