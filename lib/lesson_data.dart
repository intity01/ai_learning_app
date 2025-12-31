// lib/lesson_data.dart

// Enum สำหรับประเภทคำถาม
enum QuestionType {
  multipleChoice, // แบบเลือกตอบ (default)
  speaking,      // ฝึกพูด
  reading,        // ฝึกอ่าน
  writing,        // ฝึกเขียน
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionType type; // ✅ เพิ่ม field สำหรับประเภทคำถาม
  final String? correctText; // สำหรับ writing/speaking mode
  final String? readingText; // สำหรับ reading mode
  final String? audioUrl; // สำหรับ speaking mode

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.type = QuestionType.multipleChoice, // ✅ default เป็น multiple choice
    this.correctText,
    this.readingText,
    this.audioUrl,
  });
}

// ข้อมูลบทเรียนจำลอง (Database)
class LessonData {
  // ✅ ข้อมูล default (fallback ถ้าโหลด JSON ไม่ได้)
  static Map<int, List<Question>> questions = {
    // บทที่ 1
    1: [
      Question(
        question: "คำว่า 'สวัสดี' ภาษาญี่ปุ่นคือ?",
        options: ["Sayonara", "Konnichiwa", "Arigatou", "Sumimasen"],
        correctAnswerIndex: 1,
        explanation: "Konnichiwa (こんにちは) แปลว่า 'สวัสดี' ใช้ทักทายตอนกลางวัน ส่วน Sayonara คือ 'ลาก่อน', Arigatou คือ 'ขอบคุณ', และ Sumimasen คือ 'ขอโทษ'",
      ),
      Question(
        question: "คำว่า 'แมว' (Neko) คือข้อใด?",
        options: ["🐱", "🐶", "🐰", "🐻"],
        correctAnswerIndex: 0,
        explanation: "🐱 คือแมว (Neko - ねこ) ส่วน 🐶 คือหมา (Inu), 🐰 คือกระต่าย (Usagi), และ 🐻 คือหมี (Kuma)",
      ),
      Question(
        question: "'Arigatou' แปลว่าอะไร?",
        options: ["ขอโทษ", "ลาก่อน", "ขอบคุณ", "อร่อย"],
        correctAnswerIndex: 2,
        explanation: "Arigatou (ありがとう) แปลว่า 'ขอบคุณ' เป็นคำขอบคุณแบบไม่เป็นทางการ ส่วน 'ขอโทษ' คือ Sumimasen, 'ลาก่อน' คือ Sayonara, และ 'อร่อย' คือ Oishii",
      ),
    ],
    // บทที่ 2 (จะเล่นได้ต้องผ่านบท 1 ก่อน)
    2: [
      Question(
        question: "เลข 'หนึ่ง' ภาษาญี่ปุ่นคือ?",
        options: ["Ni", "San", "Ichi", "Yon"],
        correctAnswerIndex: 2,
        explanation: "Ichi (一) แปลว่า 'หนึ่ง' ส่วน Ni (二) คือ 'สอง', San (三) คือ 'สาม', และ Yon (四) คือ 'สี่'",
      ),
      Question(
        question: "'Watashi' แปลว่า?",
        options: ["คุณ", "ฉัน", "เขา", "พวกเรา"],
        correctAnswerIndex: 1,
        explanation: "Watashi (私) แปลว่า 'ฉัน' หรือ 'ผม' เป็นคำสรรพนามบุรุษที่ 1 แบบสุภาพ ส่วน 'คุณ' คือ Anata, 'เขา' คือ Kare, และ 'พวกเรา' คือ Watashitachi",
      ),
    ],
    // บทที่ 3
    3: [
      Question(
        question: "สี 'แดง' คือ?",
        options: ["Aka", "Ao", "Shiro", "Kuro"],
        correctAnswerIndex: 0,
        explanation: "Aka (赤) แปลว่า 'แดง' ส่วน Ao (青) คือ 'น้ำเงิน', Shiro (白) คือ 'ขาว', และ Kuro (黒) คือ 'ดำ'",
      ),
    ]
  };
  
  // ✅ โหลดข้อมูลจาก JSON File (ใช้แทนข้อมูล hardcoded)
  // Note: ควรเรียกใช้ LessonDataService.loadLessonsFromJson() โดยตรงใน lesson_detail_page
  // เพื่อหลีกเลี่ยง circular dependency
  static Future<Map<int, List<Question>>> loadFromJson() async {
    // ใช้ static method โดยตรง
    // Import จะทำใน lesson_detail_page แทน
    return await _loadFromJsonHelper();
  }
  
  static Future<Map<int, List<Question>>> _loadFromJsonHelper() async {
    try {
      // ใช้ static method โดยตรง
      // Import จะทำใน lesson_detail_page
      final LessonDataService = await _getServiceClass();
      return await LessonDataService.loadLessonsFromJson();
    } catch (e) {
      print('Error loading from JSON, using default data: $e');
      return questions; // Fallback to hardcoded data
    }
  }
  
  static Future<dynamic> _getServiceClass() async {
    // ใช้ import แบบ conditional
    // แต่ Dart ไม่รองรับ dynamic import
    // ดังนั้นให้เรียกใช้โดยตรงใน lesson_detail_page
    throw UnimplementedError('Call LessonDataService.loadLessonsFromJson() directly in lesson_detail_page');
  }
}