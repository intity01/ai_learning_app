// lib/services/lesson_preloader.dart
import 'package:flutter/foundation.dart';
import 'lesson_manager.dart';
import 'auto_lesson_generator.dart';
import 'dart:convert';
import 'dart:io';

/// Service สำหรับสร้างและบันทึกบทเรียนล่วงหน้า
class LessonPreloader {
  /// สร้างบทเรียนทั้งหมดสำหรับทุกภาษาและระดับ
  static Future<void> preloadAllLessons() async {
    debugPrint('🚀 เริ่มสร้างบทเรียนทั้งหมด...');
    
    for (var language in LessonManager.languageLevels.keys) {
      final levels = LessonManager.getLevelsForLanguage(language);
      
      for (var level in levels) {
        debugPrint('📚 กำลังสร้างบทเรียน: $language - $level');
        
        try {
          await _preloadLessonsForLevel(language, level);
          debugPrint('✅ สร้างบทเรียน $language $level สำเร็จ');
        } catch (e) {
          debugPrint('❌ Error creating lessons for $language $level: $e');
        }
        
        // หน่วงเวลาระหว่างระดับ
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    debugPrint('🎉 สร้างบทเรียนทั้งหมดเสร็จสิ้น!');
  }

  /// สร้างบทเรียนสำหรับระดับและภาษาที่กำหนด
  static Future<void> _preloadLessonsForLevel(
    String language,
    String level,
  ) async {
    final topics = LessonManager.lessonTopics[language]?[level] ?? [];
    
    if (topics.isEmpty) {
      debugPrint('⚠️ ไม่มีหัวข้อสำหรับ $language $level');
      return;
    }

    List<Map<String, dynamic>> lessons = [];
    int lessonId = 1;

    for (var topic in topics) {
      debugPrint('  📝 กำลังสร้าง: $topic');
      
      try {
        final lesson = await AutoLessonGenerator.generateLessonFromCommonWords(
          language: language,
          level: level,
          topic: topic,
          wordCount: 8,
        );

        if (lesson['questions'] != null && (lesson['questions'] as List).isNotEmpty) {
          lesson['id'] = lessonId;
          lessons.add(lesson);
          lessonId++;
        }

        // หน่วงเวลาเพื่อไม่ให้ API rate limit
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        debugPrint('  ❌ Error creating lesson $topic: $e');
      }
    }

    // บันทึกเป็น JSON file
    if (lessons.isNotEmpty) {
      await _saveLessonsToFile(language, level, lessons);
    }
  }

  /// บันทึกบทเรียนเป็น JSON file
  static Future<void> _saveLessonsToFile(
    String language,
    String level,
    List<Map<String, dynamic>> lessons,
  ) async {
    try {
      final jsonString = jsonEncode({
        'language': language,
        'level': level,
        'lessons': lessons,
        'generatedAt': DateTime.now().toIso8601String(),
      }, indent: 2);

      // สร้างโฟลเดอร์ถ้ายังไม่มี
      final directory = Directory('assets/data');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // บันทึกไฟล์
      final fileName = '${language.toLowerCase()}_${level.toLowerCase()}_lessons.json';
      final file = File('assets/data/$fileName');
      await file.writeAsString(jsonString);
      
      debugPrint('  💾 บันทึกไฟล์: $fileName (${lessons.length} บทเรียน)');
    } catch (e) {
      debugPrint('  ❌ Error saving file: $e');
    }
  }

  /// สร้างบทเรียนแบบ Manual (ไม่ใช้ API)
  static Map<String, dynamic> createManualLesson({
    required int id,
    required String title,
    required String level,
    required String language,
    required List<Map<String, dynamic>> questions,
  }) {
    return {
      'id': id,
      'title': title,
      'level': level,
      'language': language,
      'questions': questions,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// สร้างบทเรียนพื้นฐานสำหรับ N5 (ภาษาญี่ปุ่น)
  static List<Map<String, dynamic>> createBasicN5Lessons() {
    return [
      {
        'id': 1,
        'title': 'คำทักทายพื้นฐาน',
        'level': 'N5',
        'language': 'JP',
        'questions': [
          {
            'question': 'คำว่า "สวัสดี" ภาษาญี่ปุ่นคือ?',
            'options': ['Sayonara', 'Konnichiwa', 'Arigatou', 'Sumimasen'],
            'correctAnswerIndex': 1,
            'explanation': 'Konnichiwa (こんにちは) แปลว่า "สวัสดี" ใช้ทักทายตอนกลางวัน',
            'type': 'multipleChoice',
          },
          {
            'question': '"Arigatou" แปลว่าอะไร?',
            'options': ['ขอโทษ', 'ลาก่อน', 'ขอบคุณ', 'อร่อย'],
            'correctAnswerIndex': 2,
            'explanation': 'Arigatou (ありがとう) แปลว่า "ขอบคุณ"',
            'type': 'multipleChoice',
          },
        ],
      },
      {
        'id': 2,
        'title': 'ตัวเลขและจำนวน',
        'level': 'N5',
        'language': 'JP',
        'questions': [
          {
            'question': 'เลข "หนึ่ง" ภาษาญี่ปุ่นคือ?',
            'options': ['Ni', 'San', 'Ichi', 'Yon'],
            'correctAnswerIndex': 2,
            'explanation': 'Ichi (一) แปลว่า "หนึ่ง"',
            'type': 'multipleChoice',
          },
        ],
      },
    ];
  }
}


