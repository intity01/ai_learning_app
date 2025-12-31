import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import 'add_vocabulary_page.dart';
import 'lesson_vocab_list_page.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: Text(
            'คลังคำศัพท์',
            style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              height: 55,
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              padding: const EdgeInsets.all(4), // Padding เล็กน้อยเพื่อให้ Indicator ไม่ชิดขอบเกิน
              decoration: BoxDecoration(
                color: Colors.white, // พื้นหลังราง Tab สีขาว
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: TabBar(
                // 🔥 แก้ไข: Indicator แบบถมสีเต็ม (Solid Capsule)
                indicator: BoxDecoration(
                  color: const Color(0xFF1CB0F6), // สีฟ้าสด
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1CB0F6).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))
                  ],
                ),
                labelColor: Colors.white, // ตัวหนังสือตอนเลือกเป็นสีขาว
                unselectedLabelColor: Colors.grey.shade500, // ตัวหนังสือตอนไม่เลือกเป็นสีเทา
                labelStyle: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16),
                indicatorSize: TabBarIndicatorSize.tab, // ขยายสีให้เต็มช่อง
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(child: Text("📚 บทเรียน")),
                  Tab(child: Text("✏️ ของฉัน")),
                ],
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: UserData.vocabList,
          builder: (context, vocabList, _) {
            final myVocab = vocabList.where((v) => v['isCustom'] == true).toList();

            return TabBarView(
              children: [
                // Tab 1: เลือกบทเรียน (มีระบบล็อค)
                _buildLessonSelector(context), 
                
                // Tab 2: ศัพท์ของฉัน
                _buildMyVocabList(context, myVocab),      
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddVocabularyPage())
            );
          },
          label: Text('เพิ่มคำศัพท์', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF58CC02),
        ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }

  // 🔥 Widget เลือกบทเรียน (มีระบบล็อค + สีเต็ม)
  Widget _buildLessonSelector(BuildContext context) {
    final Map<int, String> lessonNames = {
      1: "การทักทาย",
      2: "แนะนำตัวเอง",
      3: "ตัวเลข & เวลา",
      4: "อาหาร & เครื่องดื่ม",
      5: "การเดินทาง",
    };

    // ต้องฟังค่า lessonProgress เพื่อเช็คว่าบทไหนล็อค
    return ValueListenableBuilder(
      valueListenable: UserData.lessonProgress,
      builder: (context, progressMap, _) {
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            int lessonId = index + 1;
            
            // --- Logic การล็อค ---
            bool isLocked = false;
            if (lessonId > 1) {
              // ถ้าบทก่อนหน้า (id-1) ยังไม่จบ (progress < 1.0) -> ล็อค
              double prevProgress = progressMap[lessonId - 1] ?? 0.0;
              if (prevProgress < 1.0) isLocked = true;
            }

            // สีของแต่ละบท (วนลูป)
            List<Color> colors = [
              const Color(0xFF58CC02), // เขียว
              const Color(0xFF1CB0F6), // ฟ้า
              const Color(0xFFCE82FF), // ม่วง
              const Color(0xFFFF9600), // ส้ม
            ];
            Color themeColor = colors[(index) % colors.length];

            return GestureDetector(
              onTap: isLocked ? () {
                // ถ้าล็อค ให้แจ้งเตือน
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🔒 ต้องเรียนบทก่อนหน้าให้จบก่อนนะ!", style: GoogleFonts.kanit()),
                    backgroundColor: Colors.grey.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } : () {
                // ถ้าไม่ล็อค ไปหน้าศัพท์
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonVocabListPage(
                      lessonId: lessonId, 
                      title: lessonNames[lessonId] ?? ""
                    )
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  // ถ้าล็อค: สีเทาอ่อน / ถ้าไม่ล็อค: สีขาว
                  color: isLocked ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isLocked ? [] : [
                    BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                  border: isLocked 
                      ? Border.all(color: Colors.grey.shade300) 
                      : Border.all(color: Colors.transparent), // ล็อคมีขอบเทา
                ),
                child: Row(
                  children: [
                    // วงกลมเลขบท
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        // ถ้าล็อค: พื้นเทาเข้ม / ถ้าไม่ล็อค: สีธีมจางๆ
                        color: isLocked ? Colors.grey.shade300 : themeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLocked 
                          ? const Icon(Icons.lock_rounded, color: Colors.grey)
                          : Text(
                              "$lessonId",
                              style: GoogleFonts.kanit(fontSize: 28, fontWeight: FontWeight.bold, color: themeColor),
                            ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // เนื้อหา
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UNIT $lessonId",
                            style: GoogleFonts.kanit(
                              fontSize: 12, 
                              color: isLocked ? Colors.grey : themeColor, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            lessonNames[lessonId] ?? "Unit $lessonId",
                            style: GoogleFonts.kanit(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: isLocked ? Colors.grey.shade500 : const Color(0xFF2B3445)
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // ไอคอนลูกศร
                    if (!isLocked)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios_rounded, color: themeColor, size: 16),
                      ),
                  ],
                ),
              ),
            ).animate().slideX(begin: 0.1, end: 0, delay: (100 * index).ms, duration: 400.ms, curve: Curves.easeOut);
          },
        );
      }
    );
  }

  // Widget ลิสต์ศัพท์ของฉัน (คงเดิม แต่ปรับสีนิดหน่อย)
  Widget _buildMyVocabList(BuildContext context, List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_note_rounded, size: 60, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 15),
            Text(
              "ยังไม่ได้เพิ่มคำศัพท์",
              style: GoogleFonts.kanit(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                offset: const Offset(0, 4),
                blurRadius: 15,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.orange),
            ),
            title: Text(
              item['word']!,
              style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF2B3445)),
            ),
            subtitle: Text(
              "${item['romaji']} • ${item['meaning']}",
              style: GoogleFonts.kanit(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () {
                _showDeleteDialog(context, item['word']);
              },
            ),
          ),
        ).animate().slideX(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms, curve: Curves.easeOutQuad);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ลบคำศัพท์?", style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text("คุณต้องการลบคำว่า \"$word\" ใช่ไหม?", style: GoogleFonts.kanit()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก", style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              UserData.deleteVocabulary(word);
              Navigator.pop(context);
            },
            child: Text("ลบ", style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}