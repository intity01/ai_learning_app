// lib/pages/community_room_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_room.dart';
import '../services/community_service.dart';
import '../user_data.dart';

class CommunityRoomDetailPage extends StatefulWidget {
  final CommunityRoom room;

  const CommunityRoomDetailPage({
    super.key,
    required this.room,
  });

  @override
  State<CommunityRoomDetailPage> createState() => _CommunityRoomDetailPageState();
}

class _CommunityRoomDetailPageState extends State<CommunityRoomDetailPage> {
  final _communityService = CommunityService();
  bool _isLoading = false;
  late CommunityRoom _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  Future<void> _joinRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาล็อคอินก่อนเข้าร่วมห้อง', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_room.participantIds.contains(user.uid)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('คุณอยู่ในห้องนี้แล้ว', style: GoogleFonts.kanit()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_room.participantCount >= _room.maxParticipants) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ห้องเต็มแล้ว', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _communityService.joinRoom(_room.id, user.uid);
      final updatedRoom = await _communityService.getRoom(_room.id);
      
      if (mounted) {
        setState(() {
          _room = updatedRoom!;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าร่วมห้องสำเร็จ!', style: GoogleFonts.kanit()),
            backgroundColor: const Color(0xFF58CC02),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!_room.participantIds.contains(user.uid)) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ออกจากห้อง', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากห้องนี้หรือไม่?', style: GoogleFonts.kanit()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text('ออก', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _communityService.leaveRoom(_room.id, user.uid);
      final updatedRoom = await _communityService.getRoom(_room.id);
      
      if (mounted) {
        setState(() {
          _room = updatedRoom!;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากห้องแล้ว', style: GoogleFonts.kanit()),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isParticipant = user != null && _room.participantIds.contains(user.uid);
    final langName = UserData.targetLanguageToDisplayName(_room.language);
    final langFlag = _room.language == 'JP' ? '🇯🇵' : _room.language == 'EN' ? '🇬🇧' : _room.language == 'CN' ? '🇨🇳' : '🇰🇷';
    final roomTypeIcon = _room.type == RoomType.video 
        ? Icons.videocam 
        : _room.type == RoomType.voice 
            ? Icons.call 
            : Icons.chat;
    final roomTypeText = _room.type == RoomType.video 
        ? 'Video Call' 
        : _room.type == RoomType.voice 
            ? 'Voice Call' 
            : 'Chat';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
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
        title: Text(
          'รายละเอียดห้อง',
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Info Card
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
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(roomTypeIcon, color: const Color(0xFF58CC02), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _room.title,
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              roomTypeText,
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _room.description,
                    style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.language, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(langFlag, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        langName,
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${_room.participantCount}/${_room.maxParticipants}',
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Participants
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
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ผู้เข้าร่วม (${_room.participantCount})',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_room.participantIds.isEmpty)
                    Text(
                      'ยังไม่มีผู้เข้าร่วม',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    )
                  else
                    ..._room.participantIds.map((id) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            UserData.avatarTemplates[0], // ใช้ avatar template
                          ),
                        ),
                        title: Text(
                          id == _room.creatorId ? '${_room.creatorName} (ผู้สร้าง)' : 'ผู้ใช้ $id',
                          style: GoogleFonts.kanit(fontSize: 14),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (isParticipant)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _leaveRoom,
                  icon: const Icon(Icons.exit_to_app),
                  label: Text(
                    'ออกจากห้อง',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _joinRoom,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    'เข้าร่วมห้อง',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

