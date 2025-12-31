// lib/pages/friend_chat_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/friend.dart';

class FriendChatPage extends StatefulWidget {
  final Friend friend;
  const FriendChatPage({super.key, required this.friend});

  @override
  State<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends State<FriendChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.friend.avatarUrl != null ? NetworkImage(widget.friend.avatarUrl!) : null,
              child: widget.friend.avatarUrl == null
                  ? Text(widget.friend.name[0].toUpperCase(), style: GoogleFonts.kanit(fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.friend.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    widget.friend.isOnline ? 'ออนไลน์' : 'ออฟไลน์',
                    style: GoogleFonts.kanit(fontSize: 12, color: widget.friend.isOnline ? Colors.green : Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.red),
            onPressed: () {
              // TODO: Start video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              // TODO: Start voice call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('ยังไม่มีข้อความ', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('เริ่มสนทนากับ ${widget.friend.name}', style: GoogleFonts.kanit(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] as bool;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF58CC02) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 2))
                            ],
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          child: Text(
                            msg['text'] as String,
                            style: GoogleFonts.kanit(color: isMe ? Colors.white : const Color(0xFF2B3445)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    style: GoogleFonts.kanit(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        setState(() {
                          _messages.add({
                            'text': _messageController.text,
                            'isMe': true,
                            'time': DateTime.now(),
                          });
                        });
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

