
import 'package:flutter/material.dart';

class ConversationRoomPage extends StatelessWidget {
  const ConversationRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ห้องสนทนา')),
      body: const Center(child: Text('Mock Chat Room (WebSocket Ready)')),
    );
  }
}
