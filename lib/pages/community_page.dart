// lib/pages/community_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../services/community_service.dart';
import '../models/community_room.dart';
import '../models/community_group.dart';
import 'create_room_page.dart';
import 'create_group_page.dart';
import 'community_room_detail_page.dart';
import 'community_group_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _communityService.dispose();
    super.dispose();
  }

  String get _userId => UserData.name.value; // Use name as temporary ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        title: Text(
          'ชุมชน',
          style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
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
          tabs: const [
            Tab(text: 'ห้องสนทนา'),
            Tab(text: 'กลุ่ม'),
            Tab(text: 'ของฉัน'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomsTab(),
          _buildGroupsTab(),
          _buildMyTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateRoomDialog(context),
              backgroundColor: const Color(0xFF58CC02),
              icon: const Icon(Icons.video_call, color: Colors.white),
              label: Text('สร้างห้อง', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateGroupDialog(context),
                  backgroundColor: const Color(0xFF1CB0F6),
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  label: Text('สร้างกลุ่ม', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              : null,
    );
  }

  Widget _buildRoomsTab() {
    return ValueListenableBuilder<String>(
      valueListenable: UserData.targetLanguage,
      builder: (context, targetLang, _) {
        return FutureBuilder<List<CommunityRoom>>(
          future: _communityService.getRoomsByLanguage(targetLang),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final rooms = snapshot.data ?? [];

            if (rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('ยังไม่มีห้อง', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('สร้างห้องใหม่เพื่อเริ่มสนทนา!', style: GoogleFonts.kanit(color: Colors.grey.shade500)),
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
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return _buildRoomCard(room).animate().fadeIn(delay: (50 * index).ms);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    return ValueListenableBuilder<String>(
      valueListenable: UserData.targetLanguage,
      builder: (context, targetLang, _) {
        return FutureBuilder<List<CommunityGroup>>(
          future: _communityService.getGroupsByLanguage(targetLang),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('ยังไม่มีกลุ่ม', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('สร้างกลุ่มใหม่เพื่อเริ่มชุมชน!', style: GoogleFonts.kanit(color: Colors.grey.shade500)),
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
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _buildGroupCard(group).animate().fadeIn(delay: (50 * index).ms);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _communityService.getUserRooms(_userId),
        _communityService.getAllGroups().then((groups) => 
          groups.where((g) => g.memberIds.contains(_userId)).toList()
        ),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snapshot.data?[0] as List<CommunityRoom>? ?? [];
        final groups = snapshot.data?[1] as List<CommunityGroup>? ?? [];

        if (rooms.isEmpty && groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('คุณยังไม่ได้เข้าร่วมห้องหรือกลุ่ม', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 18)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (rooms.isNotEmpty) ...[
              Text('ห้องที่เข้าร่วม (${rooms.length})', 
                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
              const SizedBox(height: 12),
              ...rooms.map((room) => _buildRoomCard(room)),
              const SizedBox(height: 24),
            ],
            if (groups.isNotEmpty) ...[
              Text('กลุ่มที่เข้าร่วม (${groups.length})', 
                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
              const SizedBox(height: 12),
              ...groups.map((group) => _buildGroupCard(group)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRoomCard(CommunityRoom room) {
    final langName = UserData.targetLanguageToThaiName(room.language);
    final langFlag = room.language == 'JP' ? '🇯🇵' : room.language == 'EN' ? '🇬🇧' : room.language == 'CN' ? '🇨🇳' : '🇰🇷';
    final typeIcon = room.type == RoomType.video ? Icons.videocam : room.type == RoomType.voice ? Icons.call : Icons.chat;
    final typeColor = room.type == RoomType.video ? Colors.red : room.type == RoomType.voice ? Colors.green : Colors.blue;

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
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeIcon, color: typeColor, size: 24),
        ),
        title: Text(room.title, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(room.description, 
              style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$langFlag $langName', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 12),
                Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${room.participantCount}/${room.maxParticipants}', 
                  style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityRoomDetailPage(room: room)),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  Widget _buildGroupCard(CommunityGroup group) {
    final langName = UserData.targetLanguageToThaiName(group.language);
    final langFlag = group.language == 'JP' ? '🇯🇵' : group.language == 'EN' ? '🇬🇧' : group.language == 'CN' ? '🇨🇳' : '🇰🇷';

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
          radius: 24,
          backgroundImage: group.imageUrl != null ? NetworkImage(group.imageUrl!) : null,
          child: group.imageUrl == null ? Icon(Icons.group, color: Colors.grey.shade300) : null,
        ),
        title: Text(group.name, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(group.description, 
              style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$langFlag $langName', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 12),
                Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${group.memberCount}/${group.maxMembers}', 
                  style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityGroupDetailPage(group: group)),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('สร้างห้องใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('เลือกประเภทห้องที่ต้องการสร้าง', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CreateRoomPage(roomType: RoomType.video),
              )).then((_) => setState(() {}));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, color: Colors.red),
                const SizedBox(width: 8),
                Text('Video Call', style: GoogleFonts.kanit()),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CreateRoomPage(roomType: RoomType.voice),
              )).then((_) => setState(() {}));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, color: Colors.green),
                const SizedBox(width: 8),
                Text('Voice Call', style: GoogleFonts.kanit()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupPage()),
    ).then((_) => setState(() {}));
  }
}

