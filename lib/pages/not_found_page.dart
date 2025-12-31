import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('404 - Page Not Found', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}