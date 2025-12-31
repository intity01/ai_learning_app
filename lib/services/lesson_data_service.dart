// lib/services/lesson_data_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../lesson_data.dart';
import 'lesson_manager.dart';

/// Service สำหรับโหลดข้อมูลบทเรียนจาก JSON File หรือ API
class LessonDataService {
  /// โหลดข้อมูลบทเรียนจาก JSON File (static method)
  static Future<Map<int, List<Question>>> loadLessonsFromJson() async {
    try {
      // โหลด JSON file จาก assets
      final String jsonString = await rootBundle.loadString('assets/data/japanese_lessons.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      Map<int, List<Question>> questions = {};
      
      // Parse ข้อมูลบทเรียน
      for (var lesson in jsonData['lessons']) {
        int lessonId = lesson['id'] as int;
        List<Question> lessonQuestions = [];
        
        // Parse คำถามแต่ละข้อ
        for (var q in lesson['questions']) {
          // ตรวจสอบ type ของคำถาม (ถ้าไม่มีให้ default เป็น multipleChoice)
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
      // ถ้าโหลด JSON ไม่ได้ ให้ใช้ข้อมูล default
      print('Error loading lessons from JSON: $e');
      return LessonData.questions; // Fallback to hardcoded data
    }
  }
  
  /// โหลดข้อมูลบทเรียนจาก API (ใช้ Jisho API สำหรับภาษาญี่ปุ่น)
  static Future<List<Question>> loadQuestionsFromAPI(int lessonId, String language) async {
    try {
      // ใช้ VocabularyApiService เพื่อดึงข้อมูลคำศัพท์
      // แล้วแปลงเป็นคำถาม
      // TODO: Implement based on lessonId and language
      
      // สำหรับตอนนี้ return empty list
      return [];
    } catch (e) {
      debugPrint('Error loading questions from API: $e');
      return [];
    }
  }
  
  /// โหลดคำศัพท์จาก API และสร้างคำถามอัตโนมัติ
  static Future<List<Question>> generateQuestionsFromVocabulary({
    required List<String> words,
    required String language,
  }) async {
    List<Question> questions = [];
    
    for (var word in words) {
      // ใช้ VocabularyApiService เพื่อดึงข้อมูลคำศัพท์
      // แล้วสร้างคำถาม
      // TODO: Implement
    }
    
    return questions;
  }
  
  /// โหลดข้อมูลบทเรียนทั้งหมด (JSON + API)
  static Future<Map<int, List<Question>>> loadAllLessons() async {
    // ลองโหลดจาก JSON ก่อน
    final jsonLessons = await loadLessonsFromJson();
    
    // ถ้ามีข้อมูลจาก JSON ใช้ข้อมูลนั้น
    if (jsonLessons.isNotEmpty) {
      return jsonLessons;
    }
    
    // ถ้าไม่มี ใช้ข้อมูล default
    return LessonData.questions;
  }

  /// โหลดบทเรียนตามภาษาและระดับ
  static Future<Map<int, List<Question>>> loadLessonsByLanguageAndLevel({
    required String language,
    required String level,
  }) async {
    return await LessonManager.loadLessonsByLanguageAndLevel(
      language: language,
      level: level,
    );
  }
}

