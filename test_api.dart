// test_api.dart - Script สำหรับทดสอบ API และสร้างบทเรียนอัตโนมัติ
// รันด้วย: dart test_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// ทดสอบ Jisho API
Future<void> testJishoAPI() async {
  print('🔍 ทดสอบ Jisho API...\n');
  
  final testWords = ['こんにちは', 'ありがとう', 'すみません', 'さようなら'];
  
  for (var word in testWords) {
    try {
      final response = await http.get(
        Uri.parse('https://jisho.org/api/v1/search/words?keyword=${Uri.encodeComponent(word)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final wordData = data['data'][0];
          final japanese = wordData['japanese']?[0];
          final senses = wordData['senses']?[0];
          
          print('✅ คำ: $word');
          print('   Kanji: ${japanese?['word'] ?? 'N/A'}');
          print('   Reading: ${japanese?['reading'] ?? 'N/A'}');
          print('   Meaning: ${senses?['english_definitions']?[0] ?? 'N/A'}');
          print('');
        } else {
          print('❌ ไม่พบข้อมูลสำหรับ: $word\n');
        }
      } else {
        print('❌ Error: ${response.statusCode} สำหรับ: $word\n');
      }
    } catch (e) {
      print('❌ Exception สำหรับ $word: $e\n');
    }
    
    // หน่วงเวลาเล็กน้อย
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// ทดสอบ Frequency Words API
Future<void> testFrequencyWords() async {
  print('📚 ทดสอบ Frequency Words (GitHub)...\n');
  
  try {
    final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ja/ja_50k.txt'),
    );
    
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      final words = lines
          .where((line) => line.trim().isNotEmpty)
          .take(20)
          .map((line) => line.split('\t')[0].trim())
          .toList();
      
      print('✅ ดึงคำศัพท์ที่ใช้บ่อย 20 คำแรก:');
      for (var i = 0; i < words.length; i++) {
        print('   ${i + 1}. ${words[i]}');
      }
      print('');
    } else {
      print('❌ Error: ${response.statusCode}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// ทดสอบ Tatoeba API
Future<void> testTatoebaAPI() async {
  print('📝 ทดสอบ Tatoeba API...\n');
  
  try {
    final response = await http.get(
      Uri.parse('https://tatoeba.org/eng/api_v0/search?from=jpn&to=eng&query=こんにちは&trans_to=eng'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List?;
      
      if (results != null && results.isNotEmpty) {
        print('✅ พบตัวอย่างประโยค ${results.length} ข้อ:');
        for (var i = 0; i < results.length.take(3); i++) {
          final result = results[i];
          print('   ${i + 1}. ${result['text']}');
          if (result['translations'] != null && (result['translations'] as List).isNotEmpty) {
            print('      → ${result['translations'][0]['text']}');
          }
        }
        print('');
      } else {
        print('❌ ไม่พบตัวอย่างประโยค\n');
      }
    } else {
      print('❌ Error: ${response.statusCode}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// สร้างบทเรียนอัตโนมัติ
Future<void> generateAutoLesson() async {
  print('🎓 สร้างบทเรียนอัตโนมัติ...\n');
  
  // 1. ดึงคำศัพท์ที่ใช้บ่อย
  print('📥 กำลังดึงคำศัพท์ที่ใช้บ่อย...');
  List<String> commonWords = [];
  
  try {
    final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ja/ja_50k.txt'),
    );
    
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      commonWords = lines
          .where((line) => line.trim().isNotEmpty)
          .take(10) // ใช้ 10 คำแรก
          .map((line) => line.split('\t')[0].trim())
          .toList();
      
      print('✅ ดึงคำศัพท์ ${commonWords.length} คำ\n');
    }
  } catch (e) {
    print('❌ Error ดึงคำศัพท์: $e\n');
    return;
  }
  
  // 2. สร้างคำถามจากคำศัพท์
  print('🔨 กำลังสร้างคำถาม...\n');
  List<Map<String, dynamic>> questions = [];
  
  for (var i = 0; i < commonWords.length; i++) {
    final word = commonWords[i];
    print('   [${i + 1}/${commonWords.length}] กำลังดึงข้อมูล: $word');
    
    try {
      final response = await http.get(
        Uri.parse('https://jisho.org/api/v1/search/words?keyword=${Uri.encodeComponent(word)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final wordData = data['data'][0];
          final japanese = wordData['japanese']?[0];
          final senses = wordData['senses']?[0];
          
          String? kanji = japanese?['word'];
          String? reading = japanese?['reading'];
          List<String>? meanings = senses?['english_definitions'] != null
              ? List<String>.from(senses['english_definitions'])
              : null;
          
          if (meanings != null && meanings.isNotEmpty) {
            // สร้างคำถาม
            String questionText = reading != null && reading != kanji
                ? 'คำว่า "$kanji" ($reading) หมายถึงอะไร?'
                : 'คำว่า "$word" หมายถึงอะไร?';
            
            List<String> options = [meanings[0]]; // คำตอบที่ถูก
            options.addAll(['คำตอบผิด 1', 'คำตอบผิด 2', 'คำตอบผิด 3']);
            options.shuffle();
            final correctIndex = options.indexOf(meanings[0]);
            
            questions.add({
              'question': questionText,
              'options': options,
              'correctAnswerIndex': correctIndex,
              'explanation': '${kanji ?? word}${reading != null && reading != kanji ? " ($reading)" : ""} หมายถึง "${meanings.join(", ")}"',
              'type': 'multipleChoice',
            });
            
            print('      ✅ สร้างคำถามสำเร็จ');
          } else {
            print('      ⚠️ ไม่พบความหมาย');
          }
        }
      }
    } catch (e) {
      print('      ❌ Error: $e');
    }
    
    // หน่วงเวลาเพื่อไม่ให้ API rate limit
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // 3. สร้างบทเรียน
  if (questions.isNotEmpty) {
    final lesson = {
      'id': 9, // ใช้ ID ถัดจากบทเรียนที่มีอยู่
      'title': 'คำศัพท์ที่ใช้บ่อย - Auto Generated',
      'level': 'N5',
      'questions': questions,
    };
    
    // 4. บันทึกเป็น JSON
    final jsonString = jsonEncode({'lessons': [lesson]}, indent: 2);
    
    // 5. แสดงผลลัพธ์
    print('\n✅ สร้างบทเรียนสำเร็จ!');
    print('📊 สรุป:');
    print('   - จำนวนคำถาม: ${questions.length}');
    print('   - หัวข้อ: ${lesson['title']}');
    print('\n📄 JSON Output:');
    print(jsonString);
    
    // 6. บันทึกลงไฟล์ (optional)
    try {
      final file = File('generated_lesson.json');
      await file.writeAsString(jsonString);
      print('\n💾 บันทึกเป็นไฟล์: generated_lesson.json');
    } catch (e) {
      print('\n⚠️ ไม่สามารถบันทึกไฟล์ได้: $e');
    }
  } else {
    print('\n❌ ไม่สามารถสร้างคำถามได้');
  }
}

/// Main function
Future<void> main() async {
  print('🚀 เริ่มทดสอบ APIs...\n');
  print('==================================================');
  print('');
  
  // ทดสอบ APIs
  await testJishoAPI();
  print('==================================================');
  print('');
  
  await testFrequencyWords();
  print('==================================================');
  print('');
  
  await testTatoebaAPI();
  print('==================================================');
  print('');
  
  // สร้างบทเรียนอัตโนมัติ
  await generateAutoLesson();
  print('\n==================================================');
  print('✅ ทดสอบเสร็จสิ้น!');
}

