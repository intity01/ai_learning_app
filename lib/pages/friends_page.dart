// lib/pages/friends_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../services/friend_service.dart';
import '../models/friend.dart';
import 'friend_chat_page.dart';
import 'add_friend_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendService _friendService = FriendService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _userId => UserData.name.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        title: Text('เพื่อน & กลุ่ม', style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
        centerTitle: true,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF58CC02),
          labelColor: const Color(0xFF58CC02),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'เพื่อน'),
            Tab(text: 'คำขอ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(),
          _buildRequestsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFriendPage()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFF58CC02),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('เพิ่มเพื่อน', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return FutureBuilder<List<Friend>>(
      future: _friendService.getAllFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('ยังไม่มีเพื่อน', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                const SizedBox(height: 8),
                Text('เพิ่มเพื่อนเพื่อเริ่มสนทนา!', style: GoogleFonts.kanit(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendCard(friend).animate().fadeIn(delay: (50 * index).ms);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _friendService.getIncomingRequests(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('ไม่มีคำขอเพื่อนใหม่', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final friend = Friend.fromMap(request['friend']);
            return _buildRequestCard(request['from'], friend).animate().fadeIn(delay: (50 * index).ms);
          },
        );
      },
    );
  }

  Widget _buildFriendCard(Friend friend) {
    final langName = UserData.targetLanguageToThaiName(friend.targetLanguage);
    final langFlag = friend.targetLanguage == 'JP' ? '🇯🇵' : friend.targetLanguage == 'EN' ? '🇬🇧' : friend.targetLanguage == 'CN' ? '🇨🇳' : '🇰🇷';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
              child: friend.avatarUrl == null 
                ? Text(friend.name[0].toUpperCase(), style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold))
                : null,
            ),
            if (friend.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(friend.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$langFlag $langName', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Call Button
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.red),
              onPressed: () => _showCallOptions(friend, isVideo: true),
            ),
            // Voice Call Button
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _showCallOptions(friend, isVideo: false),
            ),
            // Chat Button
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FriendChatPage(friend: friend)),
                );
              },
            ),
            // More Options
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text('บล็อก', style: GoogleFonts.kanit()),
                    ],
                  ),
                  onTap: () => _blockFriend(friend.id),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text('ลบเพื่อน', style: GoogleFonts.kanit()),
                    ],
                  ),
                  onTap: () => _removeFriend(friend.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(String requestId, Friend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
          child: friend.avatarUrl == null 
            ? Text(friend.name[0].toUpperCase(), style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold))
            : null,
        ),
        title: Text(friend.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('ต้องการเป็นเพื่อนกับคุณ', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _rejectRequest(requestId),
              child: Text('ปฏิเสธ', style: GoogleFonts.kanit(color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)),
              onPressed: () => _acceptRequest(requestId),
              child: Text('ยอมรับ', style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallOptions(Friend friend, {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Video Call' : 'Voice Call', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('โทรหา ${friend.name}?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isVideo ? Colors.red : Colors.green),
            onPressed: () {
              Navigator.pop(context);
              // TODO: เริ่ม video/voice call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เริ่ม ${isVideo ? 'Video' : 'Voice'} Call กับ ${friend.name}', style: GoogleFonts.kanit())),
              );
            },
            child: Text('โทร', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    await _friendService.acceptFriendRequest(requestId, _userId);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยอมรับคำขอเพื่อนแล้ว')),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    await _friendService.rejectFriendRequest(requestId, _userId);
    setState(() {});
  }

  Future<void> _removeFriend(String friendId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ลบเพื่อน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณแน่ใจหรือไม่?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('ลบ', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _friendService.removeFriend(friendId);
      setState(() {});
    }
  }

  Future<void> _blockFriend(String friendId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('บล็อกเพื่อน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณแน่ใจหรือไม่?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('บล็อก', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _friendService.blockFriend(friendId);
      setState(() {});
    }
  }
}

