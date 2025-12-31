// lib/services/vocabulary_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service สำหรับดึงข้อมูลคำศัพท์จาก APIs ฟรี
class VocabularyApiService {
  // Jisho API - ฟรี, ไม่จำกัด
  static const String _jishoApiUrl = 'https://jisho.org/api/v1/search/words';
  
  // Tatoeba API - ตัวอย่างประโยค
  static const String _tatoebaApiUrl = 'https://tatoeba.org/eng/api_v0/search';
  
  // GitHub Raw Content URLs
  static const String _japaneseVocabUrl = 'https://raw.githubusercontent.com/scriptin/jmdict-simplified/master/data/jmdict_english.json';
  
  /// ค้นหาคำศัพท์ภาษาญี่ปุ่นจาก Jisho API
  static Future<Map<String, dynamic>?> searchJapaneseWord(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$_jishoApiUrl?keyword=${Uri.encodeComponent(word)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          return data['data'][0];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching from Jisho API: $e');
      return null;
    }
  }
  
  /// ดึงตัวอย่างประโยคจาก Tatoeba
  static Future<List<Map<String, dynamic>>> fetchExampleSentences({
    required String fromLang, // 'jpn', 'eng', 'cmn', 'kor'
    required String toLang,
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_tatoebaApiUrl?from=$fromLang&to=$toLang&query=${Uri.encodeComponent(query)}&trans_to=eng'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching from Tatoeba API: $e');
      return [];
    }
  }
  
  /// ดึงคำศัพท์ที่ใช้บ่อย (Frequency Words)
  static Future<List<String>> fetchCommonWords(String language) async {
    try {
      // ใช้ GitHub raw content
      String url = '';
      switch (language) {
        case 'JP':
          url = 'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ja/ja_50k.txt';
          break;
        case 'EN':
          url = 'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/en/en_50k.txt';
          break;
        case 'CN':
          url = 'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/zh/zh_50k.txt';
          break;
        case 'KR':
          url = 'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ko/ko_50k.txt';
          break;
        default:
          return [];
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        return lines
            .where((line) => line.trim().isNotEmpty)
            .take(1000) // เอาแค่ 1000 คำแรก
            .map((line) => line.split('\t')[0].trim())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching common words: $e');
      return [];
    }
  }
  
  /// สร้างบทเรียนอัตโนมัติจากคำศัพท์
  static Future<List<Map<String, dynamic>>> generateLessonFromWords({
    required List<String> words,
    required String language,
    required String level,
  }) async {
    List<Map<String, dynamic>> questions = [];
    
    for (var word in words.take(10)) { // สร้าง 10 คำถาม
      Map<String, dynamic>? wordData;
      
      if (language == 'JP') {
        wordData = await searchJapaneseWord(word);
      }
      
      if (wordData != null) {
        questions.add({
          'question': 'คำว่า "$word" หมายถึงอะไร?',
          'options': _generateOptions(wordData),
          'correctAnswerIndex': 0,
          'explanation': _getExplanation(wordData),
          'type': 'multipleChoice',
        });
      }
    }
    
    return questions;
  }
  
  static List<String> _generateOptions(Map<String, dynamic> wordData) {
    // สร้างตัวเลือกจากข้อมูลที่ได้
    List<String> options = [];
    if (wordData['senses'] != null && (wordData['senses'] as List).isNotEmpty) {
      final sense = wordData['senses'][0];
      if (sense['english_definitions'] != null) {
        options.add(sense['english_definitions'][0]);
      }
    }
    // เพิ่มตัวเลือกอื่นๆ (mock)
    options.addAll(['Option 2', 'Option 3', 'Option 4']);
    return options;
  }
  
  static String _getExplanation(Map<String, dynamic> wordData) {
    if (wordData['senses'] != null && (wordData['senses'] as List).isNotEmpty) {
      final sense = wordData['senses'][0];
      if (sense['english_definitions'] != null) {
        return sense['english_definitions'].join(', ');
      }
    }
    return 'คำอธิบาย';
  }
}

