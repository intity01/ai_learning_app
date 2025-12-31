import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';
import '../app_strings.dart';
import '../services/auth_service_firebase.dart';
import '../services/friend_service.dart';
import '../models/friend.dart';
import 'history_page.dart';
// import 'leaderboard_page.dart'; // (ถ้ามีหน้า Leaderboard ให้เปิดบรรทัดนี้)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthServiceFirebase _authService = AuthServiceFirebase();
  final FriendService _friendService = FriendService();
  User? _currentUser;
  List<Friend> _friends = [];
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadFriends();
  }

  void _loadUserInfo() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    try {
      final friends = await _friendService.getAllFriends();
      setState(() {
        _friends = friends;
        _isLoadingFriends = false;
      });
    } catch (e) {
      setState(() => _isLoadingFriends = false);
    }
  }

  Future<void> _sendFriendRequest(String userId, String userName) async {
    try {
      final newFriend = Friend(
        id: userId,
        name: userName,
        targetLanguage: UserData.targetLanguage.value,
        avatarUrl: UserData.currentAvatarUrl,
      );
      
      final success = await _friendService.sendFriendRequest(UserData.name.value, newFriend);
      if (mounted) {
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

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('sign_out_confirm').split('\n')[0] + '?',
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          ),
        ),
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('sign_out_confirm'),
            style: GoogleFonts.kanit(),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit(color: Colors.grey)),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.t('sign_out'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
        }
      } catch (e) {
        if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 240;
    final double profileRadius = 60;

    return ValueListenableBuilder(
      valueListenable: UserData.appLanguage,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- ส่วนหัว Stack ---
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // 1. พื้นหลัง Gradient
                    Container(
                      height: headerHeight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    
                    // 2. 🔥 ปุ่ม Back อัจฉริยะ (ซ้ายบน)
                    Positioned(
                      top: 50, left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2), // พื้นหลังปุ่มจางๆ
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              // ถ้ากดจากเมนูล่าง -> เด้งกลับ Home
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            }
                          },
                        ),
                      ),
                    ),

                    // 3. ปุ่ม Settings (ขวาบน)
                    Positioned(
                      top: 50, right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ),
                    ),

                    // 4. รูปโปรไฟล์ (ใช้ Avatar Template)
                    Positioned(
                      bottom: -profileRadius, 
                      child: GestureDetector(
                        onTap: () => _showAvatarPicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Stack(
                            children: [
                              ValueListenableBuilder<int>(
                                valueListenable: UserData.avatarIndex,
                                builder: (context, index, _) {
                                  return CircleAvatar(
                                    radius: profileRadius,
                                    backgroundImage: NetworkImage(
                                      UserData.avatarTemplates[index.clamp(0, UserData.avatarTemplates.length - 1)]
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF58CC02),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: profileRadius + 20), 

                // --- ข้อมูล User ---
                ValueListenableBuilder(
                  valueListenable: UserData.name,
                  builder: (context, name, _) => Text(
                    name,
                    style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                  ),
                ),
                if (_currentUser != null && _currentUser!.email != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _currentUser!.email!,
                        style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
                ValueListenableBuilder(
                  valueListenable: UserData.level,
                  builder: (context, level, _) => Text(
                    'Level: $level',
                    style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 25),
                
                // --- Stats Grid ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       _buildStatCard(context, 'Streak', UserData.streak, Icons.local_fire_department, Colors.orange),
                       _buildStatCard(context, 'XP', UserData.xp, Icons.star_rounded, Colors.purple),
                       // 🔥 การ์ด Rank กดแล้วไปหน้า Leaderboard ได้
                       _buildStatCard(context, 'Rank', UserData.rank, Icons.emoji_events, Colors.amber, isLink: true),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- เพื่อน ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: UserData.appLanguage,
                            builder: (context, lang, _) => Text(
                              '${AppStrings.t('friends')} (${_friends.length})',
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2B3445),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/friends').then((_) => _loadFriends());
                            },
                            icon: const Icon(Icons.people, size: 18),
                            label: ValueListenableBuilder<String>(
                              valueListenable: UserData.appLanguage,
                              builder: (context, lang, _) => Text(
                                AppStrings.t('view_all'),
                                style: GoogleFonts.kanit(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isLoadingFriends
                          ? const Center(child: CircularProgressIndicator())
                          : _friends.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
                                        const SizedBox(height: 12),
                                        ValueListenableBuilder<String>(
                                          valueListenable: UserData.appLanguage,
                                          builder: (context, lang, _) => Column(
                                            children: [
                                              Text(
                                                AppStrings.t('no_friends'),
                                                style: GoogleFonts.kanit(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                AppStrings.t('add_friends'),
                                                style: GoogleFonts.kanit(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    itemCount: _friends.length > 5 ? 5 : _friends.length,
                                    itemBuilder: (context, index) {
                                      final friend = _friends[index];
                                      return GestureDetector(
                                        onTap: () {
                                          // TODO: Navigate to friend profile
                                        },
                                        child: Container(
                                          width: 70,
                                          margin: const EdgeInsets.only(right: 12),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 28,
                                                    backgroundImage: friend.avatarUrl != null
                                                        ? NetworkImage(friend.avatarUrl!)
                                                        : NetworkImage(UserData.avatarTemplates[0]),
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
                                              const SizedBox(height: 6),
                                              Text(
                                                friend.name,
                                                style: GoogleFonts.kanit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                
                // --- เมนู ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => _buildMenuItem(
                          icon: Icons.edit, 
                          color: Colors.blue, 
                          text: AppStrings.t('edit_name'),
                          onTap: () => _showEditProfileDialog(context),
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => _buildMenuItem(
                          icon: Icons.history, 
                          color: Colors.green, 
                          text: AppStrings.t('history_title'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                          },
                        ),
                      ),
                      if (_currentUser != null)
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, lang, _) => _buildMenuItem(
                            icon: Icons.logout, 
                            color: Colors.redAccent, 
                            text: AppStrings.t('sign_out'),
                            onTap: _handleSignOut,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // เผื่อที่ด้านล่าง
              ],
            ),
          ),
        );
      }
    );
  }

  // Widget การ์ดสถิติ (อัปเกรดให้กดได้ถ้าต้องการ)
  Widget _buildStatCard(BuildContext context, String title, ValueNotifier valueNotifier, IconData icon, Color color, {bool isLink = false}) {
    return GestureDetector(
      onTap: isLink ? () {
        // ถ้าเป็นการ์ด Rank ให้ไปหน้า Leaderboard
        Navigator.pushNamed(context, '/leaderboard');
      } : null,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
          border: isLink ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5) : null, // ถ้ากดได้จะมีขอบสี
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: valueNotifier,
              builder: (context, val, _) => Text('$val', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Text(title, style: GoogleFonts.kanit(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon, 
    required Color color, 
    required String text, 
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(15),
         boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(text, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMenuItemWithValue<T>({
    required IconData icon, 
    required Color color, 
    required String text, 
    required ValueNotifier<T> valueNotifier,
    required String Function(T) valueBuilder,
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(15),
         boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(text, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<T>(
              valueListenable: valueNotifier,
              builder: (context, value, _) => Text(
                valueBuilder(value),
                style: GoogleFonts.kanit(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final controller = TextEditingController(text: UserData.name.value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('edit_your_name'),
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          ),
        ),
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => TextField(
            controller: controller,
            style: GoogleFonts.kanit(),
            decoration: InputDecoration(
              labelText: AppStrings.t('new_name'),
              border: const OutlineInputBorder(),
            ),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  UserData.updateName(controller.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('name_changed_success'),
                          style: GoogleFonts.kanit(),
                        ),
                      ),
                      backgroundColor: const Color(0xFF58CC02),
                    ),
                  );
                }
              },
              child: Text(AppStrings.t('save'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('select_avatar'),
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: UserData.avatarTemplates.length,
            itemBuilder: (context, index) {
              final isSelected = UserData.avatarIndex.value == index;
              return GestureDetector(
                onTap: () {
                  UserData.setAvatarIndex(index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('avatar_changed_success'),
                          style: GoogleFonts.kanit(),
                        ),
                      ),
                      backgroundColor: const Color(0xFF58CC02),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(UserData.avatarTemplates[index]),
                  ),
                ),
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('close'), style: GoogleFonts.kanit()),
            ),
          ),
        ],
      ),
    );
  }
}