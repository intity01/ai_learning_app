import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../user_data.dart';
import '../app_strings.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  const HomePage({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // พื้นหลังคลีนๆ สบายตา
      body: Stack(
        children: [
          // 1. ✨ Ambient Background (พื้นหลังฟุ้งๆ ดูมีมิติ)
          Positioned(
            top: -150, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF58CC02).withValues(alpha: 0.08),
                boxShadow: const [BoxShadow(blurRadius: 100, spreadRadius: 10, color: Color(0x1158CC02))],
              ),
            ),
          ),
          
          // 2. 🏠 Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  _buildHeader(context).animate().fade().slideY(begin: -0.5, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
                  const Gap(30),

                  // --- 🔥 Hero Card (Card เรียนต่อ) ---
                  _buildHeroCard(context).animate().fade(delay: 200.ms).slideX(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),

                  const Gap(30),

                  // --- 🎯 Daily Quests ---
                  _buildSectionTitle("ภารกิจประจำวัน")
                      .animate().fade(delay: 400.ms).slideX(begin: -0.1),
                  const Gap(15),
                  _buildDailyQuestList()
                      .animate().fade(delay: 500.ms).slideY(begin: 0.2),

                  const Gap(30),

                  // --- 🎨 Colorful Menu Grid ---
                  _buildSectionTitle("โหมดฝึกฝน")
                      .animate().fade(delay: 600.ms).slideX(begin: -0.1),
                  const Gap(15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, 
                    children: [
                      _buildColorfulCard(
                        context,
                        title: AppStrings.t('menu_ai_tutor'),
                        icon: Icons.smart_toy_rounded,
                        colors: [const Color(0xFFCE82FF), const Color(0xFF9F4BF6)], // ม่วง
                        route: '/ai-tutor',
                        badge: 'PRO',
                      ),
                      _buildColorfulCard(
                        context,
                        title: AppStrings.t('menu_vocab'),
                        icon: Icons.menu_book_rounded,
                        colors: [const Color(0xFF1CB0F6), const Color(0xFF1882D6)], // ฟ้า
                        route: '/vocabulary',
                      ),
                      _buildColorfulCard(
                        context,
                        title: "คอร์สเรียน",
                        icon: Icons.map_rounded,
                        colors: [const Color(0xFF58CC02), const Color(0xFF46A302)], // เขียว
                        route: '/lessons',
                      ),
                      // ปุ่มสถิติ (ขวาล่าง)
                      _buildColorfulCard(
                        context,
                        title: "สถิติ", 
                        icon: Icons.insights_rounded,
                        colors: [const Color(0xFFFF9600), const Color(0xFFDE7A00)], // ส้ม
                        route: '/stats',
                      ),
                    ].animate(interval: 100.ms).fade().slideY(begin: 0.2, curve: Curves.easeOut),
                  ),
                  const Gap(100), // เผื่อที่ด้านล่างให้เมนูลอย
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Components ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF58CC02), width: 2),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: UserData.avatarIndex,
                  builder: (context, index, _) {
                    return CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        UserData.avatarTemplates[index.clamp(0, UserData.avatarTemplates.length - 1)]
                      ),
                    );
                  },
                ),
              ),
            ),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: UserData.name,
                  builder: (_, name, __) => Text(
                    name,
                    style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, height: 1.0, color: const Color(0xFF2B3445)),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: UserData.xp,
                  builder: (_, xp, __) => ValueListenableBuilder(
                    valueListenable: UserData.level,
                    builder: (_, level, ___) => Text(
                      "Level ${xp ~/ 100 + 1} • $level",
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              _buildStatIcon(Icons.local_fire_department_rounded, UserData.streak, Colors.orange),
              const Gap(12),
              Container(width: 1, height: 16, color: Colors.grey.shade200),
              const Gap(12),
              _buildStatIcon(Icons.star_rounded, UserData.xp, Colors.blueAccent),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatIcon(IconData icon, ValueNotifier notifier, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const Gap(4),
        ValueListenableBuilder(
          valueListenable: notifier,
          builder: (_, val, __) => Text(
            '$val',
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // 🔥 Hero Card (แก้ Progress Bar ให้ตรงกับความจริง)
  Widget _buildHeroCard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserData.lessonProgress,
      builder: (context, progressMap, _) {
        int currentLessonId = 1;
        for (int i = 1; i <= 5; i++) {
          if ((progressMap[i] ?? 0.0) < 1.0) {
            currentLessonId = i;
            break;
          }
        }
        if ((progressMap[5] ?? 0.0) >= 1.0) currentLessonId = 5;

        // ดึงค่า Progress ของบทปัจจุบันจริงๆ (ถ้า Reset จะเป็น 0.0)
        double currentProgressValue = progressMap[currentLessonId] ?? 0.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF58CC02), Color(0xFF23A036)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF58CC02).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.pushNamed(context, '/lessons'),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, bottom: -20,
                    child: Icon(Icons.play_circle_outline, size: 140, color: Colors.white.withValues(alpha: 0.1))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                        .rotate(duration: 10.seconds, begin: 0, end: 0.1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('CONTINUE LEARNING', style: GoogleFonts.kanit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                        const Gap(12),
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.targetLanguage,
                          builder: (context, targetLang, _) {
                            final langName = UserData.targetLanguageToEnglishName(targetLang);
                            return Text(
                              "Unit $currentLessonId: Basic $langName",
                              style: GoogleFonts.kanit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Gap(20),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: currentProgressValue, // ✅ ใช้ค่าจริงแล้ว
                                  backgroundColor: Colors.black.withValues(alpha: 0.1),
                                  color: Colors.white,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF58CC02)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔥 Daily Quests List (ผูกกับข้อมูลจริง)
  Widget _buildDailyQuestList() {
    return Column(
      children: [
        // ภารกิจ 1: XP
        ValueListenableBuilder(
          valueListenable: UserData.dailyXP,
          builder: (context, val, _) {
            double progress = (val / 50).clamp(0.0, 1.0); // เป้าหมาย 50 XP
            return _buildQuestItem("เก็บ XP ให้ครบ 50 แต้ม", progress, "$val/50", Colors.orange);
          }
        ),
        const Gap(12),
        // ภารกิจ 2: เพิ่มคำศัพท์
        ValueListenableBuilder(
          valueListenable: UserData.dailyVocabAdded,
          builder: (context, val, _) {
            double progress = (val / 5).clamp(0.0, 1.0); // เป้าหมาย 5 คำ
            return _buildQuestItem("เพิ่มคำศัพท์ใหม่ 5 คำ", progress, "$val/5", Colors.blue);
          }
        ),
      ],
    );
  }

  Widget _buildQuestItem(String title, double progress, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            strokeWidth: 4,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2B3445))),
                    Text(label, style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Gap(4),
                Text("${(progress * 100).toInt()}% เสร็จสิ้น", style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulCard(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> colors,
    required String route,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -15, right: -15,
              child: Icon(icon, size: 90, color: Colors.white.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.kanit(color: colors.last, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}