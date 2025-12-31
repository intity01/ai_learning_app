// lib/pages/community_group_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_group.dart';
import '../services/community_service.dart';
import '../user_data.dart';

class CommunityGroupDetailPage extends StatefulWidget {
  final CommunityGroup group;

  const CommunityGroupDetailPage({
    super.key,
    required this.group,
  });

  @override
  State<CommunityGroupDetailPage> createState() => _CommunityGroupDetailPageState();
}

class _CommunityGroupDetailPageState extends State<CommunityGroupDetailPage> {
  final _communityService = CommunityService();
  bool _isLoading = false;
  late CommunityGroup _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  Future<void> _joinGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาล็อคอินก่อนเข้าร่วมกลุ่ม', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_group.isMember(user.uid)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('คุณอยู่ในกลุ่มนี้แล้ว', style: GoogleFonts.kanit()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_group.isFull) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กลุ่มเต็มแล้ว', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _communityService.joinGroup(_group.id, user.uid);
      final updatedGroup = await _communityService.getGroup(_group.id);
      
      if (mounted) {
        setState(() {
          _group = updatedGroup!;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าร่วมกลุ่มสำเร็จ!', style: GoogleFonts.kanit()),
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

  Future<void> _leaveGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!_group.isMember(user.uid)) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ออกจากกลุ่ม', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากกลุ่มนี้หรือไม่?', style: GoogleFonts.kanit()),
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
      await _communityService.leaveGroup(_group.id, user.uid);
      final updatedGroup = await _communityService.getGroup(_group.id);
      
      if (mounted) {
        setState(() {
          _group = updatedGroup!;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากกลุ่มแล้ว', style: GoogleFonts.kanit()),
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
    final isMember = user != null && _group.isMember(user.uid);
    final langName = UserData.targetLanguageToDisplayName(_group.language);
    final langFlag = _group.language == 'JP' ? '🇯🇵' : _group.language == 'EN' ? '🇬🇧' : _group.language == 'CN' ? '🇨🇳' : '🇰🇷';

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
          'รายละเอียดกลุ่ม',
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
            // Group Info Card
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
                      if (_group.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _group.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.group, color: Color(0xFF58CC02)),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.group, color: Color(0xFF58CC02), size: 30),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _group.name,
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(langFlag, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  langName,
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _group.description,
                    style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  if (_group.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _group.tags.map((tag) {
                        return Chip(
                          label: Text(tag, style: GoogleFonts.kanit(fontSize: 12)),
                          backgroundColor: const Color(0xFF58CC02).withValues(alpha: 0.1),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${_group.memberCount}/${_group.maxMembers} สมาชิก',
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.public, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        _group.isPublic ? 'สาธารณะ' : 'ส่วนตัว',
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

            // Members
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
                    'สมาชิก (${_group.memberCount})',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_group.memberIds.isEmpty)
                    Text(
                      'ยังไม่มีสมาชิก',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    )
                  else
                    ..._group.memberIds.take(10).map((id) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            UserData.avatarTemplates[0], // ใช้ avatar template
                          ),
                        ),
                        title: Text(
                          id == _group.creatorId ? '${_group.creatorName} (ผู้สร้าง)' : 'ผู้ใช้ $id',
                          style: GoogleFonts.kanit(fontSize: 14),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  if (_group.memberIds.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'และอีก ${_group.memberIds.length - 10} คน...',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (isMember)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _leaveGroup,
                  icon: const Icon(Icons.exit_to_app),
                  label: Text(
                    'ออกจากกลุ่ม',
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
                  onPressed: _isLoading ? null : _joinGroup,
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
                    'เข้าร่วมกลุ่ม',
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

