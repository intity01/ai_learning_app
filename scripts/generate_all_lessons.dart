// scripts/generate_all_lessons.dart
// Script สำหรับสร้างบทเรียนทั้งหมดล่วงหน้า
// รันด้วย: dart scripts/generate_all_lessons.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// สร้างบทเรียนทั้งหมดสำหรับทุกภาษาและระดับ
Future<void> main() async {
  print('🚀 เริ่มสร้างบทเรียนทั้งหมด...\n');

  final languages = ['JP', 'EN', 'CN', 'KR'];
  final levels = {
    'JP': ['N5', 'N4', 'N3'],
    'EN': ['Beginner', 'Intermediate', 'Advanced'],
    'CN': ['HSK1', 'HSK2', 'HSK3'],
    'KR': ['TOPIK1', 'TOPIK2', 'TOPIK3'],
  };

  final topics = {
    'JP': {
      'N5': ['คำทักทายพื้นฐาน', 'ตัวเลขและจำนวน', 'สีและคำศัพท์พื้นฐาน', 'ครอบครัวและคน'],
      'N4': ['ประโยคที่ซับซ้อนขึ้น', 'คำกริยารูป te-form', 'คำช่วย (Particles)'],
      'N3': ['คำศัพท์ระดับกลาง', 'ไวยากรณ์ระดับกลาง'],
    },
    'EN': {
      'Beginner': ['Basic Greetings', 'Numbers and Colors', 'Family and Friends'],
      'Intermediate': ['Past Tense', 'Future Tense', 'Conditional Sentences'],
      'Advanced': ['Complex Grammar', 'Business English'],
    },
    'CN': {
      'HSK1': ['คำทักทาย', 'ตัวเลข', 'สี'],
      'HSK2': ['คำกริยาพื้นฐาน', 'คำคุณศัพท์'],
      'HSK3': ['ประโยคที่ซับซ้อน'],
    },
    'KR': {
      'TOPIK1': ['คำทักทาย', 'ตัวเลข', 'สี'],
      'TOPIK2': ['คำกริยาพื้นฐาน', 'คำคุณศัพท์'],
      'TOPIK3': ['ประโยคที่ซับซ้อน'],
    },
  };

  for (var language in languages) {
    print('📚 ภาษา: $language');
    final languageLevels = levels[language] ?? [];
    
    for (var level in languageLevels) {
      print('  📖 ระดับ: $level');
      final levelTopics = topics[language]?[level] ?? [];
      
      List<Map<String, dynamic>> lessons = [];
      int lessonId = 1;

      for (var topic in levelTopics) {
        print('    📝 กำลังสร้าง: $topic');
        
        try {
          // สร้างบทเรียน (ใช้ mock data สำหรับตอนนี้)
          final lesson = await _createMockLesson(
            id: lessonId,
            title: topic,
            level: level,
            language: language,
          );
          
          lessons.add(lesson);
          lessonId++;
          
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          print('    ❌ Error: $e');
        }
      }

      // บันทึกเป็น JSON
      if (lessons.isNotEmpty) {
        await _saveToFile(language, level, lessons);
        print('    ✅ บันทึก ${lessons.length} บทเรียน\n');
      }
    }
  }

  print('🎉 สร้างบทเรียนทั้งหมดเสร็จสิ้น!');
}

/// สร้างบทเรียนแบบ Mock (สำหรับทดสอบ)
Future<Map<String, dynamic>> _createMockLesson({
  required int id,
  required String title,
  required String level,
  required String language,
}) async {
  // สร้างคำถาม mock
  List<Map<String, dynamic>> questions = [];
  
  for (int i = 0; i < 5; i++) {
    questions.add({
      'question': 'คำถามตัวอย่าง $i สำหรับ $title?',
      'options': ['ตัวเลือก 1', 'ตัวเลือก 2', 'ตัวเลือก 3', 'ตัวเลือก 4'],
      'correctAnswerIndex': i % 4,
      'explanation': 'คำอธิบายสำหรับคำถาม $i',
      'type': 'multipleChoice',
    });
  }

  return {
    'id': id,
    'title': title,
    'level': level,
    'language': language,
    'questions': questions,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

/// บันทึกเป็น JSON file
Future<void> _saveToFile(
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

    // สร้างโฟลเดอร์
    final directory = Directory('assets/data');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // บันทึกไฟล์
    final fileName = '${language.toLowerCase()}_${level.toLowerCase()}_lessons.json';
    final file = File('assets/data/$fileName');
    await file.writeAsString(jsonString);
  } catch (e) {
    print('Error saving file: $e');
  }
}


