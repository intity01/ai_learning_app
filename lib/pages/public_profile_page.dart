// lib/pages/public_profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_data.dart';
import '../app_strings.dart';
import '../services/friend_service.dart';
import '../models/friend.dart';

class PublicProfilePage extends StatefulWidget {
  final String userName;
  final String avatarUrl;
  final int xp;
  final bool isMe;

  const PublicProfilePage({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.xp,
    this.isMe = false,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final FriendService _friendService = FriendService();
  bool _isLoading = false;
  bool _isFriend = false;
  bool _hasRequest = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isMe) {
      _checkFriendStatus();
    }
  }

  Future<void> _checkFriendStatus() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendService.getAllFriends();
      final friendRequests = await _friendService.getFriendRequests();
      
      setState(() {
        _isFriend = friends.any((f) => f.name == widget.userName);
        // friendRequests เป็น List<Map<String, dynamic>> ต้องเข้าถึง friend object ก่อน
        _hasRequest = friendRequests.any((r) {
          final friend = Friend.fromMap(r['friend'] as Map<String, dynamic>);
          return friend.name == widget.userName;
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_isLoading || _isFriend || _hasRequest) return;
    
    setState(() => _isLoading = true);
    try {
      final newFriend = Friend(
        id: widget.userName, // ใช้ name เป็น ID ชั่วคราว
        name: widget.userName,
        targetLanguage: UserData.targetLanguage.value,
        avatarUrl: widget.avatarUrl,
      );
      
      final success = await _friendService.sendFriendRequest(UserData.name.value, newFriend);
      if (mounted) {
        setState(() {
          _hasRequest = success;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(
                success ? AppStrings.t('friend_request_sent') : AppStrings.t('friend_request_exists'),
                style: GoogleFonts.kanit(),
              ),
            ),
            backgroundColor: success ? const Color(0xFF58CC02) : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(
                '${AppStrings.t('error_occurred')}: $e',
                style: GoogleFonts.kanit(),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRank(int xp) {
    if (xp < 100) return "Bronze";
    else if (xp < 500) return "Silver";
    else if (xp < 1000) return "Gold";
    else if (xp < 2000) return "Platinum";
    else return "Diamond";
  }

  String _getLevel(int xp) {
    if (xp < 100) return "Beginner";
    else if (xp < 500) return "Intermediate";
    else if (xp < 1000) return "Advanced";
    else if (xp < 2000) return "Expert";
    else return "Master";
  }

  @override
  Widget build(BuildContext context) {
    final rank = _getRank(widget.xp);
    final level = _getLevel(widget.xp);

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
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('profile'),
            style: GoogleFonts.kanit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFF58CC02).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10)
                  )
                ]
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF58CC02),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.avatarUrl),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    widget.userName,
                    style: GoogleFonts.kanit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B3445)
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rank Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9600),
                          const Color(0xFFFFB84D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9600).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, _, __) => Text(
                            rank,
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // XP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Text(
                      "${widget.xp} XP",
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Level
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple.shade200, width: 1),
                    ),
                    child: Text(
                      level,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                  // Add Friend Button (ถ้าไม่ใช่ตัวเองและยังไม่ได้เป็นเพื่อน)
                  if (!widget.isMe && !_isFriend && !_hasRequest) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _sendFriendRequest,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.person_add, color: Colors.white),
                      label: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('add_friend'),
                          style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                  if (!widget.isMe && _hasRequest) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.orange.shade200, width: 1),
                      ),
                      child: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('friend_request_sent'),
                          style: GoogleFonts.kanit(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!widget.isMe && _isFriend) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFF58CC02), width: 1),
                      ),
                      child: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.t('friends'),
                              style: GoogleFonts.kanit(
                                color: const Color(0xFF58CC02),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Stats Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.appLanguage,
                    builder: (context, lang, _) => Text(
                      AppStrings.t('statistics'),
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B3445),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.emoji_events,
                          label: AppStrings.t('rank'),
                          value: rank,
                          color: const Color(0xFFFF9600),
                        ),
                        _buildStatItem(
                          icon: Icons.star,
                          label: AppStrings.t('level'),
                          value: level,
                          color: Colors.purpleAccent,
                        ),
                        _buildStatItem(
                          icon: Icons.auto_awesome,
                          label: 'XP',
                          value: '${widget.xp}',
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
      ],
    );
  }
}

