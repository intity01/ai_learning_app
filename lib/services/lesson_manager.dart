// lib/services/lesson_manager.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../lesson_data.dart';
import 'lesson_data_service.dart';
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
      // 1. ลองโหลดจาก JSON file ก่อน
      final jsonLessons = await _loadLessonsFromJson(language, level);
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

  /// โหลดบทเรียนจาก JSON file
  static Future<Map<int, List<Question>>> _loadLessonsFromJson(
    String language,
    String level,
  ) async {
    try {
      // ลองโหลดไฟล์ตามภาษาและระดับ
      final fileName = 'assets/data/${language.toLowerCase()}_${level.toLowerCase()}_lessons.json';
      final String jsonString = await rootBundle.loadString(fileName);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
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
    } catch (e) {
      debugPrint('No JSON file found for $language $level: $e');
      return {};
    }
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

  /// ดึงรายการบทเรียนตามภาษาและระดับ (สำหรับแสดงใน UI)
  static List<Map<String, dynamic>> getLessonList({
    required String language,
    required String level,
  }) {
    final topics = lessonTopics[language]?[level] ?? [];
    
    return topics.asMap().entries.map((entry) {
      int index = entry.key;
      String topic = entry.value;
      
      return {
        'id': index + 1,
        'title': topic,
        'level': level,
        'language': language,
        'description': _getLessonDescription(language, level, topic),
      };
    }).toList();
  }

  /// สร้างคำอธิบายบทเรียน
  static String _getLessonDescription(String language, String level, String topic) {
    if (language == 'JP') {
      return 'เรียนรู้$topic สำหรับระดับ $level';
    } else if (language == 'EN') {
      return 'Learn $topic for $level level';
    } else if (language == 'CN') {
      return '学习$topic - $level级别';
    } else if (language == 'KR') {
      return '$topic 배우기 - $level';
    }
    return 'บทเรียน$topic';
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


