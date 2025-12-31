import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'loading_plan_page.dart';
import '../user_data.dart';

/// หน้า Onboarding ที่ถามข้อมูลผู้ใช้
/// Flow: Onboarding Questions -> Loading Plan -> Sign Up/Login -> Home
class OnboardingQuestionsPage extends StatefulWidget {
  const OnboardingQuestionsPage({super.key});

  @override
  State<OnboardingQuestionsPage> createState() => _OnboardingQuestionsPageState();
}

class _OnboardingQuestionsPageState extends State<OnboardingQuestionsPage> {
  int _currentStep = 0;
  late PageController _pageController; // ✅ เพิ่ม PageController
  
  // ข้อมูลที่เก็บ
  String? _nativeLanguage;
  String? _targetLanguage;
  String? _currentLevel;
  int? _dailyGoalMinutes;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // ✅ สร้าง PageController
  }
  
  @override
  void dispose() {
    _pageController.dispose(); // ✅ Dispose PageController
    super.dispose();
  }

  final List<String> _nativeLanguages = ['ไทย', 'English', '日本語', '中文', '한국어'];
  final List<String> _targetLanguages = ['日本語 (ญี่ปุ่น)', 'English (อังกฤษ)', '中文 (จีน)', '한국어 (เกาหลี)'];
  final List<String> _levels = ['Beginner (เริ่มต้น)', 'Intermediate (ปานกลาง)', 'Advanced (ขั้นสูง)'];
  final List<int> _dailyGoals = [5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2B3445)),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                  // ✅ อัปเดต PageView ให้ไปหน้าที่ถูกต้อง
                  _pageController.animateToPage(
                    _currentStep,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? const Color(0xFF58CC02)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController, // ✅ ใช้ PageController ที่เป็น state variable
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLanguageSelection(),
                  _buildTargetLanguageSelection(),
                  _buildLevelSelection(),
                  _buildDailyGoalSelection(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                          // ✅ อัปเดต PageView ให้ไปหน้าที่ถูกต้อง
                          _pageController.animateToPage(
                            _currentStep,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "ย้อนกลับ",
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentStep == 3 ? "สร้างแผนการเรียน" : "ถัดไป",
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _nativeLanguage != null;
      case 1:
        return _targetLanguage != null;
      case 2:
        return _currentLevel != null;
      case 3:
        return _dailyGoalMinutes != null;
      default:
        return false;
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      // ✅ อัปเดต PageView ให้ไปหน้าที่ถูกต้อง
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // บันทึก targetLanguage ไปที่ UserData
      String langCode = UserData.targetLanguageFromDisplay(_targetLanguage!);
      await UserData.setTargetLanguage(langCode);
      
      // ไปหน้า Loading Plan
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingPlanPage(
              nativeLanguage: _nativeLanguage!,
              targetLanguage: _targetLanguage!,
              currentLevel: _currentLevel!,
              dailyGoalMinutes: _dailyGoalMinutes!,
            ),
          ),
        );
      }
    }
  }

  Widget _buildLanguageSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "คุณพูดภาษาอะไร?",
            style: GoogleFonts.kanit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
          const Gap(8),
          Text(
            "เลือกภาษาที่คุณใช้เป็นประจำ",
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(40),
          Expanded(
            child: ListView.builder(
              itemCount: _nativeLanguages.length,
              itemBuilder: (context, index) {
                final lang = _nativeLanguages[index];
                final isSelected = _nativeLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _nativeLanguage = lang),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF58CC02) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lang,
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF2B3445),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetLanguageSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "อยากเรียนภาษาอะไร?",
            style: GoogleFonts.kanit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
          const Gap(8),
          Text(
            "เลือกภาษาที่คุณต้องการเรียนรู้",
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(40),
          Expanded(
            child: ListView.builder(
              itemCount: _targetLanguages.length,
              itemBuilder: (context, index) {
                final lang = _targetLanguages[index];
                final isSelected = _targetLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _targetLanguage = lang),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF58CC02) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lang,
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF2B3445),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ระดับของคุณคือ?",
            style: GoogleFonts.kanit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
          const Gap(8),
          Text(
            "เลือกระดับที่เหมาะสมกับคุณ",
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(40),
          Expanded(
            child: ListView.builder(
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
                final isSelected = _currentLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _currentLevel = level),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF58CC02) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              level,
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF2B3445),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "เป้าหมายวันละกี่นาที?",
            style: GoogleFonts.kanit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
          const Gap(8),
          Text(
            "เลือกเวลาที่คุณต้องการเรียนต่อวัน",
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _dailyGoals.length,
              itemBuilder: (context, index) {
                final minutes = _dailyGoals[index];
                final isSelected = _dailyGoalMinutes == minutes;
                return InkWell(
                  onTap: () => setState(() => _dailyGoalMinutes = minutes),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF58CC02) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$minutes",
                          style: GoogleFonts.kanit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF2B3445),
                          ),
                        ),
                        Text(
                          "นาที",
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey.shade600,
                          ),
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
    );
  }
}

