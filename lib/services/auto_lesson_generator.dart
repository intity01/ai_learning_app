// lib/services/auto_lesson_generator.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../lesson_data.dart';
import 'vocabulary_api_service.dart';

/// Service สำหรับสร้างบทเรียนอัตโนมัติจาก APIs ฟรี
class AutoLessonGenerator {
  /// สร้างบทเรียนจากคำศัพท์ที่ใช้บ่อย
  static Future<Map<String, dynamic>> generateLessonFromCommonWords({
    required String language,
    required String level,
    required String topic,
    int wordCount = 10,
  }) async {
    try {
      // 1. ดึงคำศัพท์ที่ใช้บ่อย
      final commonWords = await VocabularyApiService.fetchCommonWords(language);
      
      if (commonWords.isEmpty) {
        debugPrint('No common words found');
        return _createEmptyLesson(topic, level);
      }
      
      // 2. เลือกคำศัพท์ตามจำนวนที่ต้องการ
      final selectedWords = commonWords.take(wordCount).toList();
      
      // 3. สร้างคำถามจากคำศัพท์
      List<Map<String, dynamic>> questions = [];
      
      for (var word in selectedWords) {
        Map<String, dynamic>? wordData;
        
        // ดึงข้อมูลคำศัพท์จาก API
        if (language == 'JP') {
          wordData = await VocabularyApiService.searchJapaneseWord(word);
        }
        
        if (wordData != null) {
          // สร้างคำถามจากข้อมูลที่ได้
          final question = _createQuestionFromWordData(wordData, language);
          if (question != null) {
            questions.add(question);
          }
        }
        
        // หน่วงเวลาเล็กน้อยเพื่อไม่ให้ API rate limit
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // 4. สร้างบทเรียน
      return {
        'id': DateTime.now().millisecondsSinceEpoch, // ใช้ timestamp เป็น ID ชั่วคราว
        'title': topic,
        'description': 'บทเรียนอัตโนมัติจากคำศัพท์ที่ใช้บ่อย',
        'level': level,
        'language': language,
        'questions': questions,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating lesson: $e');
      return _createEmptyLesson(topic, level);
    }
  }
  
  /// สร้างคำถามจากข้อมูลคำศัพท์
  static Map<String, dynamic>? _createQuestionFromWordData(
    Map<String, dynamic> wordData,
    String language,
  ) {
    try {
      // ดึงข้อมูลจาก wordData
      String? word;
      String? reading;
      List<String> meanings = [];
      
      if (wordData['slug'] != null) {
        word = wordData['slug'] as String;
      } else if (wordData['japanese'] != null && (wordData['japanese'] as List).isNotEmpty) {
        final japanese = wordData['japanese'][0];
        word = japanese['word'] as String? ?? japanese['reading'] as String?;
        reading = japanese['reading'] as String?;
      }
      
      if (wordData['senses'] != null && (wordData['senses'] as List).isNotEmpty) {
        final sense = wordData['senses'][0];
        if (sense['english_definitions'] != null) {
          meanings = List<String>.from(sense['english_definitions']);
        }
      }
      
      if (word == null || meanings.isEmpty) {
        return null;
      }
      
      // สร้างตัวเลือก (ใช้ความหมายจริง + ตัวเลือกปลอม)
      List<String> options = [meanings[0]]; // คำตอบที่ถูก
      
      // เพิ่มตัวเลือกปลอม (ใช้ความหมายจากคำอื่นๆ หรือสร้างขึ้นมา)
      options.addAll([
        'คำตอบผิด 1',
        'คำตอบผิด 2',
        'คำตอบผิด 3',
      ]);
      
      // สลับลำดับตัวเลือก
      options.shuffle();
      final correctIndex = options.indexOf(meanings[0]);
      
      // สร้างคำถาม
      String questionText;
      if (language == 'JP') {
        questionText = reading != null && reading != word
            ? 'คำว่า "$word" ($reading) หมายถึงอะไร?'
            : 'คำว่า "$word" หมายถึงอะไร?';
      } else {
        questionText = 'คำว่า "$word" หมายถึงอะไร?';
      }
      
      return {
        'question': questionText,
        'options': options,
        'correctAnswerIndex': correctIndex,
        'explanation': '${word}${reading != null && reading != word ? " ($reading)" : ""} หมายถึง "${meanings.join(", ")}"',
        'type': 'multipleChoice',
      };
    } catch (e) {
      debugPrint('Error creating question from word data: $e');
      return null;
    }
  }
  
  /// สร้างบทเรียนว่าง (fallback)
  static Map<String, dynamic> _createEmptyLesson(String topic, String level) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': topic,
      'description': 'บทเรียนอัตโนมัติ',
      'level': level,
      'language': 'JP',
      'questions': [],
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// สร้างบทเรียนหลายบทจากหัวข้อต่างๆ
  static Future<List<Map<String, dynamic>>> generateMultipleLessons({
    required String language,
    required String level,
    required List<String> topics,
    int wordsPerLesson = 10,
  }) async {
    List<Map<String, dynamic>> lessons = [];
    
    for (var topic in topics) {
      final lesson = await generateLessonFromCommonWords(
        language: language,
        level: level,
        topic: topic,
        wordCount: wordsPerLesson,
      );
      
      if (lesson['questions'] != null && (lesson['questions'] as List).isNotEmpty) {
        lessons.add(lesson);
      }
      
      // หน่วงเวลาระหว่างบทเรียน
      await Future.delayed(const Duration(seconds: 1));
    }
    
    return lessons;
  }
  
  /// สร้างบทเรียนจากคำศัพท์ที่กำหนดเอง
  static Future<Map<String, dynamic>> generateLessonFromCustomWords({
    required String language,
    required String level,
    required String topic,
    required List<String> words,
  }) async {
    List<Map<String, dynamic>> questions = [];
    
    for (var word in words) {
      Map<String, dynamic>? wordData;
      
      if (language == 'JP') {
        wordData = await VocabularyApiService.searchJapaneseWord(word);
      }
      
      if (wordData != null) {
        final question = _createQuestionFromWordData(wordData, language);
        if (question != null) {
          questions.add(question);
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': topic,
      'description': 'บทเรียนอัตโนมัติจากคำศัพท์ที่กำหนด',
      'level': level,
      'language': language,
      'questions': questions,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// แปลงบทเรียนเป็น JSON string
  static String lessonToJson(Map<String, dynamic> lesson) {
    return jsonEncode(lesson);
  }
  
  /// แปลงบทเรียนหลายบทเป็น JSON string
  static String lessonsToJson(List<Map<String, dynamic>> lessons) {
    return jsonEncode({'lessons': lessons});
  }
}


