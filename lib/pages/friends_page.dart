// lib/pages/friends_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../app_strings.dart';
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
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('friends_groups'), style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
        ),
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
          tabs: [
            ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Tab(text: AppStrings.t('friends')),
            ),
            ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Tab(text: AppStrings.t('friend_requests')),
            ),
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
        label: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('add_friend'), style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
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
                ValueListenableBuilder<String>(
                  valueListenable: UserData.appLanguage,
                  builder: (context, lang, _) => Text(AppStrings.t('no_friends'), style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: UserData.appLanguage,
                  builder: (context, lang, _) => Text(AppStrings.t('add_friends'), style: GoogleFonts.kanit(color: Colors.grey.shade500)),
                ),
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
                ValueListenableBuilder<String>(
                  valueListenable: UserData.appLanguage,
                  builder: (context, lang, _) => Text(AppStrings.t('no_friend_requests'), style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                ),
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
    final langName = UserData.targetLanguageToDisplayName(friend.targetLanguage);
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
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(AppStrings.t('block'), style: GoogleFonts.kanit()),
                      ),
                    ],
                  ),
                  onTap: () => _blockFriend(friend.id),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(AppStrings.t('delete_friend'), style: GoogleFonts.kanit()),
                      ),
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
        subtitle: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('wants_to_be_friend'), style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _rejectRequest(requestId),
              child: ValueListenableBuilder<String>(
                valueListenable: UserData.appLanguage,
                builder: (context, lang, _) => Text(AppStrings.t('reject'), style: GoogleFonts.kanit(color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)),
              onPressed: () => _acceptRequest(requestId),
              child: ValueListenableBuilder<String>(
                valueListenable: UserData.appLanguage,
                builder: (context, lang, _) => Text(AppStrings.t('accept'), style: GoogleFonts.kanit(color: Colors.white)),
              ),
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
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            '${AppStrings.t('call')} ${friend.name}?',
            style: GoogleFonts.kanit(),
          ),
        ),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit()),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isVideo ? Colors.red : Colors.green),
              onPressed: () {
                Navigator.pop(context);
                // TODO: เริ่ม video/voice call
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: ValueListenableBuilder<String>(
                      valueListenable: UserData.appLanguage,
                      builder: (context, lang, _) => Text(
                        '${AppStrings.t('start')} ${isVideo ? 'Video' : 'Voice'} Call ${AppStrings.t('with')} ${friend.name}',
                        style: GoogleFonts.kanit(),
                      ),
                    ),
                  ),
                );
              },
              child: Text(AppStrings.t('call_button'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
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
        SnackBar(content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('accept_friend_request')),
        )),
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
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('delete_friend'), style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        ),
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(AppStrings.t('are_you_sure'), style: GoogleFonts.kanit()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => Text(AppStrings.t('cancel'), style: GoogleFonts.kanit()),
          )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(AppStrings.t('delete'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
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
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('block_friend'),
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          ),
        ),
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('are_you_sure'),
            style: GoogleFonts.kanit(),
          ),
        ),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit()),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.t('block'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
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

