import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double progress;

  const UserAvatar({super.key, required this.imageUrl, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            color: Colors.blueAccent,
            backgroundColor: Colors.grey[300],
          ),
        ),
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ],
    );
  }
}