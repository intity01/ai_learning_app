import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import 'lesson_detail_page.dart';
import '../services/lesson_manager.dart';

class LessonListPage extends StatelessWidget {
  const LessonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: UserData.targetLanguage,
      builder: (context, selectedLang, _) {
        // แสดงเฉพาะภาษาที่เลือก (ไม่มี tabs)
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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
              ),
            ),
          title: Column(
            children: [
              Text(
                'แผนที่การเรียนรู้',
                style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
              ),
              // แสดงชื่อภาษาที่เลือก
              Text(
                _getLanguageDisplay(selectedLang),
                style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          ),
          body: _buildLessonPath(context, selectedLang),
        );
      },
    );
  }

  String _getLanguageDisplay(String langCode) {
    switch (langCode) {
      case 'JP':
        return '🇯🇵 ภาษาญี่ปุ่น';
      case 'EN':
        return '🇬🇧 ภาษาอังกฤษ';
      case 'CN':
        return '🇨🇳 ภาษาจีน';
      case 'KR':
        return '🇰🇷 ภาษาเกาหลี';
      default:
        return '🇯🇵 ภาษาญี่ปุ่น';
    }
  }

  /// ดึงระดับสำหรับภาษาที่เลือก
  String _getLevelForLanguage(String language) {
    // TODO: ดึงระดับจาก UserData.level หรือใช้ default
    // สำหรับตอนนี้ใช้ default ตามภาษา
    switch (language) {
      case 'JP':
        return 'N5';
      case 'EN':
        return 'Beginner';
      case 'CN':
        return 'HSK1';
      case 'KR':
        return 'TOPIK1';
      default:
        return 'N5';
    }
  }

  /// ดึง icon ตามหัวข้อบทเรียน
  IconData _getIconForTopic(String topic) {
    if (topic.contains('ทักทาย') || topic.contains('Greeting')) {
      return Icons.waving_hand_rounded;
    } else if (topic.contains('ตัวเลข') || topic.contains('Number')) {
      return Icons.numbers_rounded;
    } else if (topic.contains('สี') || topic.contains('Color')) {
      return Icons.palette_rounded;
    } else if (topic.contains('ครอบครัว') || topic.contains('Family')) {
      return Icons.family_restroom_rounded;
    } else if (topic.contains('อาหาร') || topic.contains('Food')) {
      return Icons.restaurant_menu_rounded;
    } else {
      return Icons.book_rounded;
    }
  }


  Widget _buildLessonPath(BuildContext context, String lang) {
    // ✅ แสดงบทเรียนทั้งหมดตามภาษาและระดับ
    final level = _getLevelForLanguage(lang);
    final lessonList = LessonManager.getLessonList(
      language: lang,
      level: level,
    );
    
    // แปลงเป็นรูปแบบที่ใช้ได้
    List<Map<String, dynamic>> lessons;
    if (lessonList.isNotEmpty) {
      lessons = lessonList.map((lesson) {
        return {
          'id': lesson['id'] as int,
          'title': lesson['title'] as String,
          'desc': lesson['description'] as String? ?? '',
          'icon': _getIconForTopic(lesson['title'] as String),
        };
      }).toList();
    } else {
      // Fallback: แสดงบทเรียน default
      lessons = [
        {'id': 1, 'title': 'พื้นฐานการทักทาย', 'desc': 'สวัสดี, ขอบคุณ, ขอโทษ', 'icon': Icons.waving_hand_rounded},
        {'id': 2, 'title': 'แนะนำตัวเอง', 'desc': 'ชื่อ, อายุ, อาชีพ, งานอดิเรก', 'icon': Icons.person_pin_rounded},
        {'id': 3, 'title': 'ตัวเลขและราคา', 'desc': 'นับเลข, ซื้อของ, ต่อราคา', 'icon': Icons.shopping_bag_rounded},
        {'id': 4, 'title': 'ร้านอาหาร', 'desc': 'สั่งอาหาร, รสชาติ, เช็คบิล', 'icon': Icons.restaurant_menu_rounded},
        {'id': 5, 'title': 'การเดินทาง', 'desc': 'รถไฟ, แท็กซี่, ถามทาง', 'icon': Icons.train_rounded},
      ];
    }

    return ValueListenableBuilder(
      valueListenable: UserData.lessonProgress,
      builder: (context, progressMap, _) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            int id = lesson['id'] as int;
            
            // ใช้ระบบ lock - ต้องทำบทเรียนก่อนหน้าจบก่อน
            bool isLocked = false;
            if (id > 1) {
              double prevProgress = progressMap[id - 1] ?? 0.0;
              if (prevProgress < 1.0) isLocked = true;
            }
            double myProgress = progressMap[id] ?? 0.0;
            bool isCompleted = myProgress >= 1.0;
            bool isLast = index == lessons.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. เส้น Timeline
                  Column(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isLocked 
                              ? Colors.white 
                              : (isCompleted ? const Color(0xFF58CC02) : Colors.white),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLocked ? Colors.grey.shade300 : const Color(0xFF58CC02),
                            width: 3,
                          ),
                          boxShadow: isLocked ? [] : [
                            BoxShadow(color: const Color(0xFF58CC02).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Center(
                          child: isCompleted 
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
                              : Text(
                                  "$id",
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isLocked ? Colors.grey.shade400 : const Color(0xFF58CC02),
                                  ),
                                ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 4,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? const Color(0xFF58CC02).withValues(alpha: 0.3) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),

                  // 2. การ์ดบทเรียน
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildLessonCard(
                        context,
                        id: id,
                        title: lesson['title'] as String,
                        desc: lesson['desc'] as String? ?? lesson['description'] as String? ?? '',
                        icon: lesson['icon'] as IconData? ?? Icons.book_rounded,
                        isLocked: isLocked,
                        isCompleted: isCompleted,
                        progress: myProgress,
                        color: _getThemeColor(id),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, end: 0, delay: (100 * index).ms, duration: 400.ms, curve: Curves.easeOutQuad).fade();
          },
        );
      },
    );
  }


  Color _getThemeColor(int index) {
    List<Color> colors = [
      const Color(0xFF58CC02), // เขียว
      const Color(0xFF1CB0F6), // ฟ้า
      const Color(0xFFCE82FF), // ม่วง
      const Color(0xFFFF9600), // ส้ม
    ];
    return colors[(index - 1) % colors.length];
  }

  Widget _buildLessonCard(
    BuildContext context, {
    required int id, required String title, required String desc, required IconData icon,
    required bool isLocked, required bool isCompleted, required double progress, required Color color,
  }) {
    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🔒 เคลียร์ด่านก่อนหน้าให้จบก่อนนะ!", style: GoogleFonts.kanit()),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } : () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LessonDetailPage(
          lessonId: id, 
          title: title,
        )));
      },
      child: Container(
        height: 110, // เพิ่มความสูงนิดนึงเผื่อบรรทัด Progress
        decoration: BoxDecoration(
          color: isLocked ? Colors.white : color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.grey.withValues(alpha: 0.05) : color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: isLocked ? null : LinearGradient(
            colors: [color, color.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10, bottom: -15,
              child: Icon(icon, size: 90, color: isLocked ? Colors.grey.shade50 : Colors.white.withValues(alpha: 0.15)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade100 : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : icon,
                      color: isLocked ? Colors.grey.shade400 : Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.kanit(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: isLocked ? Colors.grey.shade700 : Colors.white,
                            height: 1.1
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          desc,
                          style: GoogleFonts.kanit(
                            fontSize: 12, 
                            color: isLocked ? Colors.grey.shade400 : Colors.white.withValues(alpha: 0.9)
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // 🔥 เพิ่มส่วน Progress พร้อมตัวเลข % ตรงนี้
                        if (!isLocked && !isCompleted) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.black.withValues(alpha: 0.1),
                                    color: Colors.white,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // แสดงตัวเลข % สีขาว
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: GoogleFonts.kanit(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),

                  // ปุ่ม Play/Refresh
                  if (!isLocked && isCompleted) 
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]
                      ),
                      child: Icon(Icons.refresh_rounded, color: color, size: 20),
                    )
                  else if (!isLocked && !isCompleted) 
                    // ถ้ากำลังเรียนอยู่ ไม่ต้องโชว์ปุ่ม Play ซ้ำ (มี Progress Bar แล้ว)
                    const SizedBox.shrink()
                  else if (!isLocked) 
                     Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: color, size: 20),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}