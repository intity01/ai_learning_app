import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_data.dart'; // ดึงระบบบันทึก (UserData)
import '../app_strings.dart';
import '../lesson_data.dart'; // ✅ ใช้ Question จาก LessonData
import '../services/lesson_data_service.dart'; // ✅ Service สำหรับโหลดข้อมูลจาก JSON
import '../services/lesson_manager.dart'; // ✅ Service สำหรับจัดการบทเรียนตามระดับและภาษา
class LessonDetailPage extends StatefulWidget {
  final int lessonId;
  final String title;

  const LessonDetailPage({
    super.key, 
    required this.lessonId, 
    required this.title,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  // ✅ ใช้ Question จาก LessonData แทน hardcoded
  List<Question> _questions = [];
  List<Question> _wrongQuestions = []; // เก็บข้อที่ตอบผิด
  List<Question> _originalQuestions = []; // เก็บข้อเดิมทั้งหมด
  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;      // ข้อปัจจุบัน
  int? _selectedOption;       // ช้อยส์ที่เลือก
  bool _isChecked = false;    // ตรวจคำตอบหรือยัง
  bool _isCorrect = false;    // ตอบถูกไหม
  bool _hasShownExplanation = false; // ✅ แสดง explanation dialog แล้วหรือยัง
  final TextEditingController _writingController = TextEditingController(); // ✅ สำหรับ writing mode
  
  int _wrongCount = 0; // จำนวนข้อที่ตอบผิด
  int _correctCount = 0; // จำนวนข้อที่ตอบถูก

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }
  
  @override
  void dispose() {
    _writingController.dispose();
    super.dispose();
  }
  
  // ✅ ดึงระดับสำหรับภาษาที่เลือก
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

  // ✅ โหลดคำถามจาก JSON File หรือใช้ข้อมูล default
  Future<void> _loadQuestions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ✅ โหลดบทเรียนตามภาษาและระดับ
      final language = UserData.targetLanguage.value;
      final level = _getLevelForLanguage(language); // ดึงระดับจาก UserData หรือใช้ default
      
      // ลองโหลดจาก LessonManager ก่อน (รองรับหลายภาษาและระดับ)
      final allQuestions = await LessonDataService.loadLessonsByLanguageAndLevel(
        language: language,
        level: level,
      );
      List<Question> loadedQuestions = allQuestions[widget.lessonId] ?? [];
      
      // ถ้าไม่มี ให้ลองโหลดจาก JSON แบบเดิม
      if (loadedQuestions.isEmpty) {
        final jsonQuestions = await LessonDataService.loadLessonsFromJson();
        loadedQuestions = jsonQuestions[widget.lessonId] ?? [];
      }
      
      // ถ้ายังไม่มี ให้ใช้ข้อมูล default
      if (loadedQuestions.isEmpty) {
        loadedQuestions = LessonData.questions[widget.lessonId] ?? [];
      }
      
      _questions = loadedQuestions;
      _originalQuestions = List.from(loadedQuestions); // เก็บข้อเดิม
      
      // ถ้ายังไม่มี ให้ใช้ fallback
      if (_questions.isEmpty) {
        final appLang = UserData.appLanguage.value;
        _questions = [
          Question(
            question: appLang == 'th' 
                ? 'คำว่า "สวัสดี" ในภาษาญี่ปุ่นคือ?'
                : 'What is the Japanese word for "Hello"?',
            options: ['Konnichiwa', 'Sayounara', 'Arigatou'],
            correctAnswerIndex: 0,
            explanation: appLang == 'th'
                ? 'Konnichiwa (こんにちは) แปลว่า "สวัสดี" ใช้ทักทายตอนกลางวัน'
                : 'Konnichiwa (こんにちは) means "Hello" and is used to greet during the day',
          ),
        ];
        _originalQuestions = List.from(_questions); // เก็บข้อเดิม
      }
      
      // 🔥 โหลดตำแหน่งล่าสุดที่เคยเรียนไว้
      int savedIndex = UserData.lessonCurrentIndex.value[widget.lessonId] ?? 0;
      
      // ป้องกัน Error กรณี savedIndex เกินจำนวนข้อ
      if (savedIndex >= _questions.length) savedIndex = 0;
      
      if (mounted) {
        setState(() {
          _currentIndex = savedIndex;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading questions: $e');
      // ใช้ข้อมูล default ถ้าโหลด JSON ไม่ได้
      _questions = LessonData.questions[widget.lessonId] ?? [];
      
      if (mounted) {
        setState(() {
          _currentIndex = 0;
          _isLoading = false;
          _errorMessage = 'ไม่สามารถโหลดคำถามได้ ใช้ข้อมูลสำรอง';
        });
      }
    }
  }


  // ฟังก์ชันตรวจคำตอบ
  void _checkAnswer() {
    final currentQuestion = _questions[_currentIndex];
    
    // ✅ ตรวจสอบตาม type ของคำถาม
    if (currentQuestion.type == QuestionType.multipleChoice) {
      if (_selectedOption == null) return;
      final isCorrect = _selectedOption == currentQuestion.correctAnswerIndex;
      
      setState(() {
        _isChecked = true;
        _isCorrect = isCorrect;
        _hasShownExplanation = false;
      });

      if (!isCorrect) {
        // เก็บข้อที่ตอบผิดไว้เพื่อทำซ้ำ
        if (!_wrongQuestions.any((q) => q.question == currentQuestion.question)) {
          _wrongQuestions.add(currentQuestion);
          _wrongCount++;
        }
        _showExplanationDialog(currentQuestion);
      } else {
        _correctCount++;
      }
    }
    // สำหรับ speaking, reading, writing จะตรวจใน UI component ของแต่ละ mode
  }

  // ✅ แสดง Dialog พร้อม Explanation เมื่อตอบผิด
  void _showExplanationDialog(Question question) {
    // ✅ ป้องกันการแสดง dialog ซ้ำ
    if (_hasShownExplanation) return;
    
    setState(() {
      _hasShownExplanation = true; // ✅ บันทึกว่าแสดงแล้ว
    });
    
    showModalBottomSheet(
      context: context,
      isDismissible: false, // บังคับกดปุ่มก่อนถึงจะปิดได้
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('answer_incorrect'),
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('see_explanation'),
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // คำตอบที่ถูกต้อง
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF58CC02), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, lang, _) => Text(
                            AppStrings.t('correct_answer'),
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.options[question.correctAnswerIndex],
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF58CC02),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // คำอธิบาย
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('explanation'),
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      color: const Color(0xFF2B3445),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ปุ่มไปต่อ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                  _nextQuestion(); // ไปข้อต่อไป
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: UserData.appLanguage,
                  builder: (context, lang, _) => Text(
                    AppStrings.t('understood_continue'),
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันไปข้อต่อไป
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      // 🔥 2. ก่อนไปข้อหน้า บันทึกตำแหน่งปัจจุบันลงเครื่อง
      int nextIndex = _currentIndex + 1;
      UserData.updateLessonProgress(widget.lessonId, nextIndex, _questions.length);

      setState(() {
        _currentIndex = nextIndex;
        _selectedOption = null;
        _isChecked = false;
        _isCorrect = false;
        _hasShownExplanation = false; // ✅ รีเซ็ต state
        _writingController.clear(); // ✅ ล้างข้อความใน writing mode
      });
    } else {
      // ถ้าหมดข้อแล้ว ตรวจสอบว่ามีข้อที่ผิดหรือไม่
      if (_wrongQuestions.isNotEmpty) {
        // มีข้อที่ผิด ให้ทำซ้ำ
        _retryWrongQuestions();
      } else {
        // ไม่มีข้อผิด ให้จบเกม
        _finishLesson();
      }
    }
  }
  
  // ทำข้อที่ผิดซ้ำ
  void _retryWrongQuestions() {
    setState(() {
      _questions = List.from(_wrongQuestions); // ใช้ข้อที่ผิด
      _wrongQuestions = []; // ล้างรายการข้อผิด
      _currentIndex = 0;
      _selectedOption = null;
      _isChecked = false;
      _isCorrect = false;
      _hasShownExplanation = false;
      _writingController.clear();
    });
  }

  // ✅ สร้าง UI ตาม type ของคำถาม
  Widget _buildQuestionContent(Question question) {
    switch (question.type) {
      case QuestionType.speaking:
        return _buildSpeakingQuestion(question);
      case QuestionType.reading:
        return _buildReadingQuestion(question);
      case QuestionType.writing:
        return _buildWritingQuestion(question);
      case QuestionType.multipleChoice:
      default:
        return _buildMultipleChoiceQuestion(question);
    }
  }

  // ✅ UI สำหรับ Multiple Choice
  Widget _buildMultipleChoiceQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // โจทย์
        Text(
          question.question,
          style: GoogleFonts.kanit(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: const Color(0xFF2B3445)
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // ช้อยส์
        ...List.generate(question.options.length, (index) {
          bool isSelected = _selectedOption == index;
          bool isCorrect = index == question.correctAnswerIndex;
          
          Color borderColor = Colors.grey.shade300;
          Color bgColor = Colors.white;

          if (_isChecked) {
            if (isCorrect) {
              borderColor = const Color(0xFF58CC02); // ถูก
              bgColor = const Color(0xFF58CC02).withValues(alpha: 0.1);
            } else if (isSelected && !_isCorrect) {
              borderColor = Colors.red; // ผิด
              bgColor = Colors.red.withValues(alpha: 0.1);
            }
          } else if (isSelected) {
            borderColor = Colors.blueAccent;
            bgColor = Colors.blue.withValues(alpha: 0.05);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _isChecked ? null : () => setState(() => _selectedOption = index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected && !_isChecked ? [
                     BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _isChecked && isCorrect
                              ? const Color(0xFF58CC02) 
                              : const Color(0xFF2B3445),
                        ),
                      ),
                    ),
                    if (_isChecked && isCorrect)
                      const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 24),
                    if (_isChecked && isSelected && !_isCorrect)
                      const Icon(Icons.cancel, color: Colors.red, size: 24),
                  ],
                ),
              ),
            ),
          );
        }),
        
        const Spacer(),
      ],
    );
  }

  // ✅ Method สำหรับจบบทเรียน
  void _finishLesson() {
    // คำนวณ XP ตามจำนวนข้อที่ผิด
    final totalQuestions = _originalQuestions.length;
    final baseXP = 50;
    final wrongPenalty = 5; // ลด XP 5 ต่อข้อผิด
    final correctBonus = 2; // เพิ่ม XP 2 ต่อข้อถูก
    
    // สูตร: baseXP - (wrongCount * wrongPenalty) / totalQuestions + (correctCount * correctBonus) / totalQuestions
    // แล้วคูณด้วย totalQuestions เพื่อให้ได้ XP ที่เหมาะสม
    final xpGain = ((baseXP - (wrongPenalty * _wrongCount / totalQuestions) + (correctBonus * _correctCount / totalQuestions)) * totalQuestions / totalQuestions).round();
    final finalXP = xpGain.clamp(10, 100); // จำกัด XP ระหว่าง 10-100
    
    // บันทึกว่าเรียนจบแล้ว พร้อม XP ที่คำนวณได้
    UserData.completeLessonWithXP(widget.lessonId, widget.title, finalXP);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 60),
            const SizedBox(height: 10),
            ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(
                AppStrings.t('lesson_completed'),
                style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) {
            final totalQuestions = _originalQuestions.isEmpty ? _questions.length : _originalQuestions.length;
            final baseXP = 50;
            final wrongPenalty = 5;
            final correctBonus = 2;
            final xpGain = ((baseXP - (wrongPenalty * _wrongCount / totalQuestions) + (correctBonus * _correctCount / totalQuestions)) * totalQuestions / totalQuestions).round();
            final finalXP = xpGain.clamp(10, 100);
            
            final message = AppStrings.t('lesson_completed_message');
            final parts = message.split('\n');
            String finalMessage = message;
            if (parts.length >= 2) {
              finalMessage = '${parts[0]}\n${parts[1].replaceAll('+50 XP', '+$finalXP XP')}';
              if (parts.length >= 3) {
                finalMessage += '\n${parts[2]}';
              }
            }
            
            return Text(
              finalMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(fontSize: 16),
            );
          },
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                // ตรวจสอบว่ามี route ให้ pop หรือไม่ก่อนจะ pop
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // กลับไปหน้าเลือกบทเรียน
                } else {
                  // ถ้าไม่มี route ให้ pop ให้ navigate ไปหน้าแรกแทน
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
              child: ValueListenableBuilder<String>(
                valueListenable: UserData.appLanguage,
                builder: (context, lang, _) => Text(
                  AppStrings.t('acknowledged'),
                  style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // แสดง loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
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
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // แสดง error state
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'ไม่พบคำถามสำหรับบทเรียนนี้',
                style: GoogleFonts.kanit(fontSize: 18),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _loadQuestions();
                },
                child: Text('ลองใหม่', style: GoogleFonts.kanit()),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    // คำนวณ Progress (เช่น ข้อ 1/5 = 0.2)
    double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      
      // --- AppBar (ปุ่มปิด + Progress Bar + เลข %) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
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
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            // หลอด Progress
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF58CC02), // สีเขียว
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 🔥 3. ตัวเลขเปอร์เซ็นต์
            Text(
              "${(progress * 100).toInt()}%",
              style: GoogleFonts.kanit(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey.shade600
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      // --- เนื้อหาคำถาม (รองรับทุกโหมด) ---
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // ✅ แสดง UI ตาม type ของคำถาม
            Expanded(
              child: _buildQuestionContent(question),
            ),
          ],
        ),
      ),

      // --- ปุ่มด้านล่าง ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
        ),
        child: SafeArea(
          child: _buildBottomButton(),
        ),
      ),
    );
  }

  // ✅ UI สำหรับ Speaking (ฝึกพูด)
  Widget _buildSpeakingQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // คำแนะนำ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.mic, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ฝึกออกเสียงคำนี้ให้ถูกต้อง',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // คำที่ต้องออกเสียง
        Center(
          child: Text(
            question.correctText ?? question.question,
            style: GoogleFonts.kanit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3445),
            ),
          ),
        ),
        
        if (question.explanation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              question.explanation,
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        
        const Spacer(),
        
        // ปุ่มฟังเสียงตัวอย่าง (ถ้ามี)
        if (question.audioUrl != null || true) // ใช้ TTS แทน
          ElevatedButton.icon(
            onPressed: () async {
              // TODO: ใช้ VoiceService เพื่อเล่นเสียง
            },
            icon: const Icon(Icons.volume_up),
            label: Text('ฟังเสียงตัวอย่าง', style: GoogleFonts.kanit()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        
        const SizedBox(height: 20),
        
        // ปุ่มบันทึกเสียง
        ElevatedButton.icon(
          onPressed: () {
            // TODO: เปิดหน้า pronunciation practice
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ฟีเจอร์นี้กำลังพัฒนา', style: GoogleFonts.kanit()),
              ),
            );
          },
          icon: const Icon(Icons.mic),
          label: Text('กดเพื่อบันทึกเสียง', style: GoogleFonts.kanit()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  // ✅ UI สำหรับ Reading (ฝึกอ่าน)
  Widget _buildReadingQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // คำแนะนำ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.menu_book, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'อ่านข้อความและตอบคำถาม',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // ข้อความที่ต้องอ่าน
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            question.readingText ?? question.question,
            style: GoogleFonts.kanit(
              fontSize: 18,
              height: 1.8,
              color: const Color(0xFF2B3445),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // คำถาม
        Text(
          question.question,
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // ช้อยส์ (ถ้ามี)
        if (question.options.isNotEmpty)
          ...List.generate(question.options.length, (index) {
            bool isSelected = _selectedOption == index;
            bool isCorrect = index == question.correctAnswerIndex;
            
            Color borderColor = Colors.grey.shade300;
            Color bgColor = Colors.white;

            if (_isChecked) {
              if (isCorrect) {
                borderColor = const Color(0xFF58CC02);
                bgColor = const Color(0xFF58CC02).withValues(alpha: 0.1);
              } else if (isSelected && !_isCorrect) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.1);
              }
            } else if (isSelected) {
              borderColor = Colors.blueAccent;
              bgColor = Colors.blue.withValues(alpha: 0.05);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _isChecked ? null : () => setState(() => _selectedOption = index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            color: _isChecked && isCorrect
                                ? const Color(0xFF58CC02) 
                                : const Color(0xFF2B3445),
                          ),
                        ),
                      ),
                      if (_isChecked && isCorrect)
                        const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 24),
                      if (_isChecked && isSelected && !_isCorrect)
                        const Icon(Icons.cancel, color: Colors.red, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        
        const Spacer(),
      ],
    );
  }

  // ✅ UI สำหรับ Writing (ฝึกเขียน)
  Widget _buildWritingQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // คำแนะนำ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'เขียนคำตอบตามที่โจทย์ถาม',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // โจทย์
        Text(
          question.question,
          style: GoogleFonts.kanit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        
        if (question.explanation.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'คำใบ้: ${question.explanation}',
            style: GoogleFonts.kanit(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        const SizedBox(height: 30),
        
        // ช่องเขียนคำตอบ
        Expanded(
          child: TextField(
            controller: _writingController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'เขียนคำตอบของคุณที่นี่...',
              hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF58CC02), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: GoogleFonts.kanit(fontSize: 18),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // แสดงคำตอบที่ถูกต้อง (ถ้าตรวจแล้ว)
        if (_isChecked && question.correctText != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect 
                  ? const Color(0xFF58CC02).withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCorrect ? const Color(0xFF58CC02) : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? const Color(0xFF58CC02) : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: UserData.appLanguage,
                      builder: (context, lang, _) => Text(
                        _isCorrect ? AppStrings.t('answer_correct') : AppStrings.t('correct_answer'),
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? const Color(0xFF58CC02) : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.correctText!,
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    color: const Color(0xFF2B3445),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ✅ สร้างปุ่มด้านล่างตาม type ของคำถาม
  Widget _buildBottomButton() {
    final question = _questions[_currentIndex];
    
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.reading:
        return ElevatedButton(
          onPressed: _selectedOption == null 
              ? null 
              : (_isChecked 
                  ? (_isCorrect 
                      ? _nextQuestion 
                      : (_hasShownExplanation 
                          ? () {
                              Navigator.pop(context);
                              _nextQuestion();
                            }
                          : () => _showExplanationDialog(question)))
                  : _checkAnswer),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isChecked 
                ? (_isCorrect ? const Color(0xFF58CC02) : Colors.red) 
                : const Color(0xFF58CC02),
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => Text(
              _isChecked 
                  ? (_isCorrect 
                      ? AppStrings.t('continue_next')
                      : (_hasShownExplanation ? AppStrings.t('understood_continue') : AppStrings.t('see_explanation'))) 
                  : AppStrings.t('check_answer'),
              style: GoogleFonts.kanit(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
          ),
        );
      
      case QuestionType.writing:
        return ElevatedButton(
          onPressed: () {
            // ตรวจคำตอบจากการเขียน
            final userAnswer = _writingController.text.trim().toLowerCase();
            final correctAnswer = question.correctText?.trim().toLowerCase() ?? '';
            
            setState(() {
              _isChecked = true;
              // ตรวจสอบความถูกต้อง (ง่ายๆ ด้วย string matching)
              _isCorrect = userAnswer == correctAnswer || 
                          userAnswer.contains(correctAnswer) ||
                          correctAnswer.contains(userAnswer);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => Text(
              _isChecked ? AppStrings.t('continue_next') : AppStrings.t('check_answer'),
              style: GoogleFonts.kanit(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
          ),
        );
      
      case QuestionType.speaking:
        return ElevatedButton(
          onPressed: () {
            // TODO: ตรวจการออกเสียง
            _nextQuestion();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            "ข้ามไปข้อถัดไป",
            style: GoogleFonts.kanit(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
        );
    }
  }
}