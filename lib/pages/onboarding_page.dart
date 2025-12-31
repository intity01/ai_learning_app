import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'onboarding_questions_page.dart'; // ✅ Import OnboardingQuestionsPage

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "เรียนรู้ง่ายๆ\nด้วย AI อัจฉริยะ",
      "desc": "ฝึกสนทนาภาษาญี่ปุ่นและอังกฤษกับ AI Tutor ที่พร้อมดูแลคุณตลอด 24 ชั่วโมง",
      "icon": "🤖"
    },
    {
      "title": "ติดตามผล\nได้ทุกวัน",
      "desc": "ดูสถิติการเรียน เก็บ XP และรักษาระดับ Streak ของคุณให้ต่อเนื่อง",
      "icon": "📈"
    },
    {
      "title": "เก่งภาษา\nในแบบของคุณ",
      "desc": "บทเรียนที่ออกแบบมาเพื่อคุณโดยเฉพาะ เริ่มต้นเส้นทางสู่ระดับเซียนได้เลย",
      "icon": "🚀"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(20),
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToHome,
                child: Text("ข้าม", style: GoogleFonts.kanit(color: Colors.grey, fontSize: 16)),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon ใหญ่ๆ (แทนรูปภาพ)
                      Text(
                        _pages[index]["icon"]!,
                        style: const TextStyle(fontSize: 120),
                      )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fade(duration: 400.ms),
                      
                      const Gap(40),
                      
                      Text(
                        _pages[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          height: 1.2,
                          color: const Color(0xFF2B3445)
                        ),
                      ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutQuad).fade(),
                      
                      const Gap(16),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _pages[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            fontSize: 16, 
                            color: Colors.grey.shade600,
                            height: 1.5
                          ),
                        ).animate().slideY(begin: 0.5, end: 0, delay: 200.ms, duration: 500.ms).fade(),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF58CC02) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const Gap(40),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _goToHome();
                    } else {
                      _controller.nextPage(duration: 300.ms, curve: Curves.easeOut);
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1 ? "เริ่มต้นใช้งาน" : "ถัดไป",
                    style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.elasticOut),
            ),
          ],
        ),
      ),
    );
  }

  void _goToHome() {
    // ✅ ไปหน้า Onboarding Questions แทน MainScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingQuestionsPage()),
    );
  }
}