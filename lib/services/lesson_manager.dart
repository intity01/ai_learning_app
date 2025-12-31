// lib/services/lesson_manager.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../lesson_data.dart';
import '../user_data.dart';
import '../app_strings.dart';
import 'auto_lesson_generator.dart';

/// Service สำหรับจัดการบทเรียนตามระดับและภาษา
class LessonManager {
  // ระดับที่รองรับสำหรับแต่ละภาษา
  static const Map<String, List<String>> languageLevels = {
    'JP': ['N5', 'N4', 'N3', 'N2', 'N1'], // ภาษาญี่ปุ่น
    'EN': ['Beginner', 'Intermediate', 'Advanced'], // ภาษาอังกฤษ
    'CN': ['HSK1', 'HSK2', 'HSK3', 'HSK4', 'HSK5', 'HSK6'], // ภาษาจีน
    'KR': ['TOPIK1', 'TOPIK2', 'TOPIK3', 'TOPIK4', 'TOPIK5', 'TOPIK6'], // ภาษาเกาหลี
  };

  // หัวข้อบทเรียนสำหรับแต่ละระดับและภาษา
  static const Map<String, Map<String, List<String>>> lessonTopics = {
    'JP': {
      'N5': [
        'คำทักทายพื้นฐาน',
        'ตัวเลขและจำนวน',
        'สีและคำศัพท์พื้นฐาน',
        'ครอบครัวและคน',
        'อาหารและเครื่องดื่ม',
        'วันและเวลา',
        'คำกริยาพื้นฐาน',
        'คำคุณศัพท์พื้นฐาน',
      ],
      'N4': [
        'ประโยคที่ซับซ้อนขึ้น',
        'คำกริยารูป te-form',
        'คำกริยารูป ta-form',
        'คำช่วย (Particles)',
        'การแสดงความต้องการ',
        'การเปรียบเทียบ',
      ],
      'N3': [
        'คำศัพท์ระดับกลาง',
        'ไวยากรณ์ระดับกลาง',
        'การอ่านบทความสั้น',
        'การเขียนอีเมล',
      ],
    },
    'EN': {
      'Beginner': [
        'Basic Greetings',
        'Numbers and Colors',
        'Family and Friends',
        'Daily Activities',
        'Food and Drinks',
        'Time and Dates',
      ],
      'Intermediate': [
        'Past Tense',
        'Future Tense',
        'Conditional Sentences',
        'Phrasal Verbs',
        'Idioms and Expressions',
      ],
      'Advanced': [
        'Complex Grammar',
        'Business English',
        'Academic Writing',
        'Advanced Vocabulary',
      ],
    },
    'CN': {
      'HSK1': [
        'คำทักทาย',
        'ตัวเลข',
        'สี',
        'ครอบครัว',
      ],
      'HSK2': [
        'คำกริยาพื้นฐาน',
        'คำคุณศัพท์',
        'ประโยคง่าย',
      ],
    },
    'KR': {
      'TOPIK1': [
        'คำทักทาย',
        'ตัวเลข',
        'สี',
        'ครอบครัว',
      ],
      'TOPIK2': [
        'คำกริยาพื้นฐาน',
        'คำคุณศัพท์',
        'ประโยคง่าย',
      ],
    },
  };

  /// โหลดบทเรียนทั้งหมดตามภาษาและระดับ
  static Future<Map<int, List<Question>>> loadLessonsByLanguageAndLevel({
    required String language,
    required String level,
  }) async {
    try {
      // 1. ลองโหลดจาก JSON file ก่อน (ลองทั้ง targetLanguage และ appLanguage)
      final appLang = UserData.appLanguage.value;
      
      // ลองโหลดจาก targetLanguage ก่อน
      var jsonLessons = await _loadLessonsFromJson(language, level);
      
      // ถ้าไม่มี และ appLanguage เป็นภาษาอังกฤษ แต่ targetLanguage ไม่ใช่ EN
      // ลองโหลดจาก EN lessons แทน (ถ้ามี)
      if (jsonLessons.isEmpty && appLang == 'en' && language != 'EN') {
        // ลองโหลดจาก en_beginner_lessons.json แทน
        try {
          final String jsonString = await rootBundle.loadString('assets/data/en_beginner_lessons.json');
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          jsonLessons = _parseJsonLessons(jsonData);
        } catch (e) {
          debugPrint('Could not load EN lessons: $e');
        }
      }
      
      if (jsonLessons.isNotEmpty) {
        return jsonLessons;
      }

      // 2. ถ้าไม่มีใน JSON ให้สร้างอัตโนมัติ
      final autoLessons = await _generateLessonsForLevel(language, level);
      if (autoLessons.isNotEmpty) {
        return autoLessons;
      }

      // 3. Fallback to default
      return LessonData.questions;
    } catch (e) {
      debugPrint('Error loading lessons: $e');
      return LessonData.questions;
    }
  }
  
  /// Parse JSON lessons data
  static Map<int, List<Question>> _parseJsonLessons(Map<String, dynamic> jsonData) {
    Map<int, List<Question>> questions = {};
    
    for (var lesson in jsonData['lessons']) {
      int lessonId = lesson['id'] as int;
      List<Question> lessonQuestions = [];
      
      for (var q in lesson['questions']) {
        QuestionType questionType = QuestionType.multipleChoice;
        if (q['type'] != null) {
          switch (q['type'] as String) {
            case 'speaking':
              questionType = QuestionType.speaking;
              break;
            case 'reading':
              questionType = QuestionType.reading;
              break;
            case 'writing':
              questionType = QuestionType.writing;
              break;
            default:
              questionType = QuestionType.multipleChoice;
          }
        }
        
        lessonQuestions.add(Question(
          question: q['question'] as String,
          options: List<String>.from(q['options'] as List? ?? []),
          correctAnswerIndex: q['correctAnswerIndex'] as int? ?? 0,
          explanation: q['explanation'] as String,
          type: questionType,
          correctText: q['correctText'] as String?,
          readingText: q['readingText'] as String?,
          audioUrl: q['audioUrl'] as String?,
        ));
      }
      
      questions[lessonId] = lessonQuestions;
    }
    
    return questions;
  }

  /// โหลดบทเรียนจาก JSON file
  static Future<Map<int, List<Question>>> _loadLessonsFromJson(
    String language,
    String level,
  ) async {
    try {
      final appLang = UserData.appLanguage.value;
      
      // ลองโหลดไฟล์ตามภาษาและระดับ
      final fileName = 'assets/data/${language.toLowerCase()}_${level.toLowerCase()}_lessons.json';
      final String jsonString = await rootBundle.loadString(fileName);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // ถ้า appLanguage เป็นภาษาอังกฤษ แต่ JSON มีคำถามเป็นภาษาไทย ให้แปลคำถาม
      if (appLang == 'en') {
        return _parseJsonLessonsWithTranslation(jsonData, language);
      }
      
      return _parseJsonLessons(jsonData);
    } catch (e) {
      debugPrint('No JSON file found for $language $level: $e');
      return {};
    }
  }
  
  /// Parse JSON lessons และแปลคำถามตาม appLanguage
  static Map<int, List<Question>> _parseJsonLessonsWithTranslation(
    Map<String, dynamic> jsonData,
    String targetLanguage,
  ) {
    Map<int, List<Question>> questions = {};
    
    for (var lesson in jsonData['lessons']) {
      int lessonId = lesson['id'] as int;
      List<Question> lessonQuestions = [];
      
      for (var q in lesson['questions']) {
        QuestionType questionType = QuestionType.multipleChoice;
        if (q['type'] != null) {
          switch (q['type'] as String) {
            case 'speaking':
              questionType = QuestionType.speaking;
              break;
            case 'reading':
              questionType = QuestionType.reading;
              break;
            case 'writing':
              questionType = QuestionType.writing;
              break;
            default:
              questionType = QuestionType.multipleChoice;
          }
        }
        
        // แปลคำถามและตัวเลือก
        String questionText = _translateQuestion(q['question'] as String, targetLanguage);
        List<String> options = (q['options'] as List? ?? []).map((opt) => 
          _translateOption(opt as String, targetLanguage)
        ).toList();
        String explanation = _translateExplanation(q['explanation'] as String, targetLanguage);
        
        lessonQuestions.add(Question(
          question: questionText,
          options: options,
          correctAnswerIndex: q['correctAnswerIndex'] as int? ?? 0,
          explanation: explanation,
          type: questionType,
          correctText: q['correctText'] as String?,
          readingText: q['readingText'] as String?,
          audioUrl: q['audioUrl'] as String?,
        ));
      }
      
      questions[lessonId] = lessonQuestions;
    }
    
    return questions;
  }
  
  /// แปลคำถามจากภาษาไทยเป็นภาษาอังกฤษ
  static String _translateQuestion(String question, String targetLanguage) {
    // Mapping คำถามภาษาไทย -> ภาษาอังกฤษ (เฉพาะคำถามที่แปลยาก)
    final translations = {
      "คำว่า 'สวัสดี' ภาษาญี่ปุ่นคือ?": "What is the Japanese word for 'Hello'?",
      "'Arigatou' แปลว่าอะไร?": "What does 'Arigatou' mean?",
      "คำว่า 'ลาก่อน' ภาษาญี่ปุ่นคือ?": "What is the Japanese word for 'Goodbye'?",
      "'Sumimasen' แปลว่าอะไร?": "What does 'Sumimasen' mean?",
      "'Ogenki desu ka?' แปลว่าอะไร?": "What does 'Ogenki desu ka?' mean?",
      "เลข 'หนึ่ง' ภาษาญี่ปุ่นคือ?": "What is the Japanese word for 'one'?",
      "'Watashi' แปลว่า?": "What does 'Watashi' mean?",
      "คำว่า 'แมว' (Neko) คือข้อใด?": "Which one is the word for 'cat' (Neko)?",
      "สี 'แดง' คือ?": "What is the color 'red'?",
      "สี 'น้ำเงิน' คือ?": "What is the color 'blue'?",
      "สี 'ขาว' คือ?": "What is the color 'white'?",
      "สี 'ดำ' คือ?": "What is the color 'black'?",
      "สี 'เขียว' คือ?": "What is the color 'green'?",
      "'Okaasan' แปลว่าอะไร?": "What does 'Okaasan' mean?",
      "'Otousan' แปลว่าอะไร?": "What does 'Otousan' mean?",
      "'Tomodachi' แปลว่าอะไร?": "What does 'Tomodachi' mean?",
      "'Oniisan' แปลว่าอะไร?": "What does 'Oniisan' mean?",
      "'Oneesan' แปลว่าอะไร?": "What does 'Oneesan' mean?",
      "'Gohan' แปลว่าอะไร?": "What does 'Gohan' mean?",
      "'Mizu' แปลว่าอะไร?": "What does 'Mizu' mean?",
      "'Oishii' แปลว่าอะไร?": "What does 'Oishii' mean?",
      "'Ocha' แปลว่าอะไร?": "What does 'Ocha' mean?",
      "'Namae' แปลว่าอะไร?": "What does 'Namae' mean?",
      "คำว่า 'สวัสดี' ภาษาจีนคือ?": "What is the Chinese word for 'Hello'?",
      "'谢谢' แปลว่าอะไร?": "What does '谢谢' mean?",
      "คำว่า 'สวัสดี' ภาษาเกาหลีคือ?": "What is the Korean word for 'Hello'?",
      "'감사합니다' แปลว่าอะไร?": "What does '감사합니다' mean?",
    };
    
    // ถ้าเจอ mapping ให้ใช้
    if (translations.containsKey(question)) {
      return translations[question]!;
    }
    
    // ถ้าไม่มี mapping ให้แปลแบบ pattern matching
    // Pattern: "คำว่า 'X' ภาษาญี่ปุ่นคือ?"
    if (question.contains("คำว่า '") && question.contains("' ภาษาญี่ปุ่นคือ?")) {
      final match = RegExp(r"คำว่า '(.+?)' ภาษาญี่ปุ่นคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Japanese word for '$translatedWord'?";
      }
    }
    
    // Pattern: "'X' แปลว่าอะไร?"
    if (question.contains("'") && question.contains("' แปลว่าอะไร?")) {
      final match = RegExp(r"'(.+?)' แปลว่าอะไร\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        return "What does '$word' mean?";
      }
    }
    
    // Pattern: "เลข 'X' ภาษาญี่ปุ่นคือ?"
    if (question.contains("เลข '") && question.contains("' ภาษาญี่ปุ่นคือ?")) {
      final match = RegExp(r"เลข '(.+?)' ภาษาญี่ปุ่นคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Japanese word for '$translatedWord'?";
      }
    }
    
    // Pattern: "สี 'X' คือ?"
    if (question.contains("สี '") && question.contains("' คือ?")) {
      final match = RegExp(r"สี '(.+?)' คือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the color '$translatedWord'?";
      }
    }
    
    // Pattern: "คำว่า 'X' ภาษาจีนคือ?"
    if (question.contains("คำว่า '") && question.contains("' ภาษาจีนคือ?")) {
      final match = RegExp(r"คำว่า '(.+?)' ภาษาจีนคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Chinese word for '$translatedWord'?";
      }
    }
    
    // Pattern: "คำว่า 'X' ภาษาเกาหลีคือ?"
    if (question.contains("คำว่า '") && question.contains("' ภาษาเกาหลีคือ?")) {
      final match = RegExp(r"คำว่า '(.+?)' ภาษาเกาหลีคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Korean word for '$translatedWord'?";
      }
    }
    
    // Pattern: "เลข 'X' ภาษาจีนคือ?"
    if (question.contains("เลข '") && question.contains("' ภาษาจีนคือ?")) {
      final match = RegExp(r"เลข '(.+?)' ภาษาจีนคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Chinese word for '$translatedWord'?";
      }
    }
    
    // Pattern: "เลข 'X' ภาษาเกาหลีคือ?"
    if (question.contains("เลข '") && question.contains("' ภาษาเกาหลีคือ?")) {
      final match = RegExp(r"เลข '(.+?)' ภาษาเกาหลีคือ\?").firstMatch(question);
      if (match != null && match.group(1) != null) {
        final word = match.group(1)!;
        final translatedWord = _translateOption(word, targetLanguage);
        return "What is the Korean word for '$translatedWord'?";
      }
    }
    
    return question;
  }
  
  /// แปลตัวเลือกจากภาษาไทยเป็นภาษาอังกฤษ
  static String _translateOption(String option, String targetLanguage) {
    // ถ้าตัวเลือกเป็นภาษาอังกฤษอยู่แล้ว (เช่น "Konnichiwa", "Sayonara") ไม่ต้องแปล
    if (!_containsThai(option)) {
      return option;
    }
    
    // Mapping ตัวเลือกภาษาไทย -> ภาษาอังกฤษ
    final translations = {
      "สวัสดี": "Hello",
      "ขอโทษ": "Sorry",
      "ลาก่อน": "Goodbye",
      "ขอบคุณ": "Thank you",
      "อร่อย": "Delicious",
      "คุณ": "You",
      "ฉัน": "I/Me",
      "เขา": "He/Him",
      "พวกเรา": "We/Us",
      "คุณสบายดีไหม?": "How are you?",
      "คุณชื่ออะไร?": "What is your name?",
      "คุณอายุเท่าไหร่?": "How old are you?",
      "คุณมาจากไหน?": "Where are you from?",
      "หนึ่ง": "One",
      "สอง": "Two",
      "สาม": "Three",
      "สี่": "Four",
      "ห้า": "Five",
      "หก": "Six",
      "เจ็ด": "Seven",
      "แปด": "Eight",
      "เก้า": "Nine",
      "สิบ": "Ten",
      "แดง": "Red",
      "น้ำเงิน": "Blue",
      "เขียว": "Green",
      "เหลือง": "Yellow",
      "ขาว": "White",
      "ดำ": "Black",
      "พ่อ": "Father",
      "แม่": "Mother",
      "พี่ชาย": "Older brother",
      "น้องสาว": "Younger sister",
      "พี่สาว": "Older sister",
      "น้องชาย": "Younger brother",
      "เพื่อน": "Friend",
      "ครู": "Teacher",
      "นักเรียน": "Student",
      "หมอ": "Doctor",
      "ข้าว": "Rice",
      "น้ำ": "Water",
      "ขนม": "Snack",
      "ผลไม้": "Fruit",
      "ชา": "Tea",
      "กาแฟ": "Coffee",
      "ไม่อร่อย": "Not delicious",
      "ร้อน": "Hot",
      "เย็น": "Cold",
      "ชื่อ": "Name",
      "นามสกุล": "Surname",
      "อายุ": "Age",
      "ที่อยู่": "Address",
      "น้ำอัดลม": "Soda",
      "น้ำผลไม้": "Fruit juice",
      "การทักทาย": "Greeting",
      "การแนะนำตัว": "Introduction",
      "การซื้อของ": "Shopping",
      "การเดินทาง": "Travel",
    };
    
    return translations[option] ?? option;
  }
  
  /// แปลคำอธิบายจากภาษาไทยเป็นภาษาอังกฤษ
  static String _translateExplanation(String explanation, String targetLanguage) {
    // ถ้าคำอธิบายเป็นภาษาอังกฤษอยู่แล้ว ไม่ต้องแปล
    if (!_containsThai(explanation)) {
      return explanation;
    }
    
    // แปลคำอธิบายแบบง่ายๆ
    String translated = explanation;
    
    // แปลคำสำคัญ
    translated = translated.replaceAll('แปลว่า', 'means');
    translated = translated.replaceAll('ใช้', 'used to');
    translated = translated.replaceAll('ทักทาย', 'greet');
    translated = translated.replaceAll('ตอนกลางวัน', 'during the day');
    translated = translated.replaceAll('เป็นคำ', 'is a word');
    translated = translated.replaceAll('แบบไม่เป็นทางการ', 'informal');
    translated = translated.replaceAll('หรือ', 'or');
    translated = translated.replaceAll('อาหาร', 'food');
    translated = translated.replaceAll('ส่วน', 'while');
    translated = translated.replaceAll('คือ', 'is');
    translated = translated.replaceAll('และ', 'and');
    translated = translated.replaceAll('เมื่อ', 'when');
    translated = translated.replaceAll('จะ', 'will');
    translated = translated.replaceAll('จากกัน', 'parting');
    translated = translated.replaceAll('ทำผิด', 'make a mistake');
    translated = translated.replaceAll('ต้องการ', 'need');
    translated = translated.replaceAll('ความช่วยเหลือ', 'help');
    translated = translated.replaceAll('ขออภัย', 'excuse me');
    
    // แปลคำศัพท์ที่พบบ่อยในคำอธิบาย
    final wordTranslations = {
      'สวัสดี': 'Hello',
      'ลาก่อน': 'Goodbye',
      'ขอบคุณ': 'Thank you',
      'ขอโทษ': 'Sorry',
      'หนึ่ง': 'one',
      'สอง': 'two',
      'สาม': 'three',
      'สี่': 'four',
      'ห้า': 'five',
      'หก': 'six',
      'เจ็ด': 'seven',
      'แปด': 'eight',
      'เก้า': 'nine',
      'สิบ': 'ten',
      'แดง': 'red',
      'น้ำเงิน': 'blue',
      'เขียว': 'green',
      'เหลือง': 'yellow',
      'ขาว': 'white',
      'ดำ': 'black',
      'พ่อ': 'father',
      'แม่': 'mother',
      'พี่ชาย': 'older brother',
      'น้องสาว': 'younger sister',
      'พี่สาว': 'older sister',
      'น้องชาย': 'younger brother',
      'เพื่อน': 'friend',
      'ครู': 'teacher',
      'นักเรียน': 'student',
      'หมอ': 'doctor',
      'ข้าว': 'rice',
      'น้ำ': 'water',
      'ขนม': 'snack',
      'ผลไม้': 'fruit',
      'ชา': 'tea',
      'กาแฟ': 'coffee',
      'อร่อย': 'delicious',
      'ไม่อร่อย': 'not delicious',
      'ร้อน': 'hot',
      'เย็น': 'cold',
      'ชื่อ': 'name',
      'นามสกุล': 'surname',
      'อายุ': 'age',
      'ที่อยู่': 'address',
    };
    
    // แปลคำศัพท์ในคำอธิบาย (ต้องแปลแบบระวังเพื่อไม่ให้แปลซ้ำ)
    wordTranslations.forEach((thai, english) {
      // แปลเฉพาะเมื่ออยู่ใน quotes หรือเป็นคำเดี่ยว
      translated = translated.replaceAll("'$thai'", "'$english'");
      translated = translated.replaceAll(' "$thai"', ' "$english"');
    });
    
    return translated;
  }
  
  /// ตรวจสอบว่าข้อความมีตัวอักษรภาษาไทยหรือไม่
  static bool _containsThai(String text) {
    return text.contains(RegExp(r'[ก-๙]'));
  }

  /// สร้างบทเรียนอัตโนมัติสำหรับระดับและภาษาที่กำหนด
  static Future<Map<int, List<Question>>> _generateLessonsForLevel(
    String language,
    String level,
  ) async {
    Map<int, List<Question>> allLessons = {};
    
    // ดึงหัวข้อบทเรียนสำหรับระดับนี้
    final topics = lessonTopics[language]?[level] ?? [];
    
    if (topics.isEmpty) {
      debugPrint('No topics found for $language $level');
      return {};
    }

    int lessonId = 1;
    
    for (var topic in topics) {
      try {
        // สร้างบทเรียนจากหัวข้อ
        final lesson = await AutoLessonGenerator.generateLessonFromCommonWords(
          language: language,
          level: level,
          topic: topic,
          wordCount: 8, // 8 คำถามต่อบทเรียน
        );

        if (lesson['questions'] != null && (lesson['questions'] as List).isNotEmpty) {
          // แปลงเป็น Question objects
          List<Question> questions = [];
          for (var q in lesson['questions'] as List) {
            questions.add(Question(
              question: q['question'] as String,
              options: List<String>.from(q['options'] as List),
              correctAnswerIndex: q['correctAnswerIndex'] as int,
              explanation: q['explanation'] as String,
            ));
          }
          
          allLessons[lessonId] = questions;
          lessonId++;
        }

        // หน่วงเวลาเพื่อไม่ให้ API rate limit
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error generating lesson for $topic: $e');
      }
    }

    return allLessons;
  }

  /// แปลง topic เป็น localized string
  static String _getLocalizedTopic(String topic) {
    final appLang = UserData.appLanguage.value;
    
    // Mapping จาก topic ไทย/อังกฤษ ไปยัง AppStrings key
    final topicMap = {
      'คำทักทายพื้นฐาน': 'topic_basic_greetings',
      'Basic Greetings': 'topic_basic_greetings',
      'ตัวเลขและจำนวน': 'topic_numbers_quantity',
      'Numbers and Quantity': 'topic_numbers_quantity',
      'สีและคำศัพท์พื้นฐาน': 'topic_colors_vocab',
      'Colors and Basic Vocabulary': 'topic_colors_vocab',
      'ครอบครัวและคน': 'topic_family_people',
      'Family and People': 'topic_family_people',
      'อาหารและเครื่องดื่ม': 'topic_food_drinks',
      'Food and Drinks': 'topic_food_drinks',
      'วันและเวลา': 'topic_days_time',
      'Days and Time': 'topic_days_time',
      'คำกริยาพื้นฐาน': 'topic_basic_verbs',
      'Basic Verbs': 'topic_basic_verbs',
      'คำคุณศัพท์พื้นฐาน': 'topic_basic_adjectives',
      'Basic Adjectives': 'topic_basic_adjectives',
      'คำทักทาย': 'topic_greetings',
      'Greetings': 'topic_greetings',
      'ตัวเลข': 'topic_numbers',
      'Numbers': 'topic_numbers',
      'สี': 'topic_colors',
      'Colors': 'topic_colors',
      'ครอบครัว': 'topic_family',
      'Family': 'topic_family',
      'ประโยคที่ซับซ้อนขึ้น': 'topic_complex_sentences',
      'Complex Sentences': 'topic_complex_sentences',
      'คำกริยารูป te-form': 'topic_te_form',
      'Te-form Verbs': 'topic_te_form',
      'คำกริยารูป ta-form': 'topic_ta_form',
      'Ta-form Verbs': 'topic_ta_form',
      'คำช่วย (Particles)': 'topic_particles',
      'Particles': 'topic_particles',
      'การแสดงความต้องการ': 'topic_desires',
      'Expressing Desires': 'topic_desires',
      'การเปรียบเทียบ': 'topic_comparison',
      'Comparison': 'topic_comparison',
      'คำศัพท์ระดับกลาง': 'topic_intermediate_vocab',
      'Intermediate Vocabulary': 'topic_intermediate_vocab',
      'ไวยากรณ์ระดับกลาง': 'topic_intermediate_grammar',
      'Intermediate Grammar': 'topic_intermediate_grammar',
      'การอ่านบทความสั้น': 'topic_short_articles',
      'Reading Short Articles': 'topic_short_articles',
      'การเขียนอีเมล': 'topic_email_writing',
      'Email Writing': 'topic_email_writing',
    };
    
    final key = topicMap[topic];
    if (key != null) {
      return AppStrings.t(key);
    }
    
    // ถ้าไม่เจอ key ให้ return topic เดิม
    return topic;
  }

  /// ดึงรายการบทเรียนตามภาษาและระดับ (สำหรับแสดงใน UI)
  static List<Map<String, dynamic>> getLessonList({
    required String language,
    required String level,
  }) {
    final topics = lessonTopics[language]?[level] ?? [];
    
    return topics.asMap().entries.map((entry) {
      int index = entry.key;
      String topic = entry.value;
      String localizedTitle = _getLocalizedTopic(topic);
      
      return {
        'id': index + 1,
        'title': localizedTitle,
        'level': level,
        'language': language,
        'description': _getLessonDescription(language, level, localizedTitle),
      };
    }).toList();
  }

  /// สร้างคำอธิบายบทเรียน
  static String _getLessonDescription(String language, String level, String topic) {
    // ใช้ AppStrings สำหรับภาษาไทยและอังกฤษ
    final appLang = UserData.appLanguage.value;
    if (appLang == 'th') {
      return 'เรียนรู้$topic สำหรับระดับ $level';
    } else {
      return 'Learn $topic for $level level';
    }
  }

  /// ตรวจสอบว่ามีบทเรียนสำหรับภาษาและระดับนี้หรือไม่
  static bool hasLessonsForLevel(String language, String level) {
    return lessonTopics[language]?[level] != null && 
           (lessonTopics[language]![level]?.isNotEmpty ?? false);
  }

  /// ดึงระดับทั้งหมดสำหรับภาษา
  static List<String> getLevelsForLanguage(String language) {
    return languageLevels[language] ?? [];
  }
}


