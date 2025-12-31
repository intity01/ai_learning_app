import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/lesson_list_page.dart';
import 'pages/vocabulary_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/profile_page.dart';
import 'pages/friends_page.dart';
import 'pages/community_page.dart';
import 'pages/blog_feed_page.dart';
import 'user_data.dart';
import 'app_strings.dart';

// Enum สำหรับ Lesson Skill
enum LessonSkill {
  speaking,
  reading,
  writing,
  mixed,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LeaderboardPage(),
    const LessonListPage(),
    const VocabularyPage(),
    const BlogFeedPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // เมนูล่างแบบติดพื้น มาตรฐานแอปอาชีพ
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            // Shadow หลัก (ด้านล่าง)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
            // Shadow เพิ่มเติมสำหรับมิติ
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
              spreadRadius: -2,
            ),
            // Inner shadow effect (ใช้สีอ่อน)
            BoxShadow(
              color: Colors.grey.shade200.withValues(alpha: 0.5),
              blurRadius: 5,
              offset: const Offset(0, -1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) {
            return BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.home_outlined, size: 28),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_rounded,
                        size: 28, color: Color(0xFF58CC02)),
                  ),
                  label: '', // ซ่อน label
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.emoji_events_outlined, size: 28),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        size: 28, color: Color(0xFF58CC02)),
                  ),
                  label: '', // ซ่อน label
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.map_outlined, size: 28),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map_rounded,
                        size: 28, color: Color(0xFF58CC02)),
                  ),
                  label: '', // ซ่อน label
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.menu_book_outlined, size: 28),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        size: 28, color: Color(0xFF58CC02)),
                  ),
                  label: '', // ซ่อน label
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.article_outlined, size: 28),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.article_rounded,
                        size: 28, color: Color(0xFF58CC02)),
                  ),
                  label: '', // ซ่อน label
                ),
                BottomNavigationBarItem(
                  icon: Builder(
                    builder: (context) => PopupMenuButton<String>(
                      // ปรับ offset ให้เหมาะสม - อยู่เหนือ navbar และอยู่ด้านขวา
                      offset: Offset(
                        -MediaQuery.of(context).size.width *
                            0.15, // อยู่ด้านขวา (ลดลงเพื่อให้กว้างขึ้น)
                        -280, // อยู่เหนือ navbar พอดี
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz,
                            color: Colors.grey, size: 24),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 12,
                      color: Colors.white, // สีขาวเข้ากับธีมแอป
                      padding:
                          EdgeInsets.zero, // ลบ padding เพื่อให้ขนาดตามเนื้อหา
                      constraints: BoxConstraints(
                        minWidth: 280,
                        maxWidth: MediaQuery.of(context).size.width * 0.85, // กว้างขึ้นตามขนาดหน้าจอ
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfilePage()));
                            break;
                          case 'friends':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FriendsPage()));
                            break;
                          case 'community':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CommunityPage()));
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'profile',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF58CC02)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: Color(0xFF58CC02), size: 24),
                              ),
                              const SizedBox(width: 12),
                              ValueListenableBuilder<String>(
                                valueListenable: UserData.appLanguage,
                                builder: (context, lang, _) => Text(
                                  AppStrings.t('menu_profile'),
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xFF2B3445),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'friends',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCE82FF)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.people_rounded,
                                    color: Color(0xFFCE82FF), size: 24),
                              ),
                              const SizedBox(width: 12),
                              ValueListenableBuilder<String>(
                                valueListenable: UserData.appLanguage,
                                builder: (context, lang, _) => Text(
                                  AppStrings.t('friends_groups'),
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xFF2B3445),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'community',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9600)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.group_rounded,
                                    color: Color(0xFFFF9600), size: 24),
                              ),
                              const SizedBox(width: 12),
                              ValueListenableBuilder<String>(
                                valueListenable: UserData.appLanguage,
                                builder: (context, lang, _) => Text(
                                  AppStrings.t('community'),
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xFF2B3445),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  label: '', // ซ่อน label
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF58CC02),
              unselectedItemColor: Colors.grey.shade500,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              showSelectedLabels: false, // ซ่อน label เมื่อเลือก
              showUnselectedLabels: false, // ซ่อน label เมื่อไม่เลือก
              iconSize: 28, // ขนาด icon
              onTap: (index) {
                // ถ้ากดที่ index 5 (เมนู) ไม่ต้องเปลี่ยนหน้า
                if (index != 5) {
                  _onItemTapped(index);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
