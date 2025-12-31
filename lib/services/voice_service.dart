// lib/services/voice_service.dart
// 🎤 Voice Service สำหรับ ElevenLabs Integration

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/api_config.dart';

/// Voice Service สำหรับ ElevenLabs Text-to-Speech
class VoiceService {
  final String apiKey; // จะตั้งค่าใน environment variables
  final String baseUrl = 'https://api.elevenlabs.io/v1';
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Voice IDs สำหรับแต่ละภาษา
  static const String englishVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel - English
  static const String japaneseVoiceId = 'pNInz6obpgDQGcFmaJgB'; // Adam - Multilingual (Japanese)
  static const String thaiVoiceId = 'EXAVITQu4vr4xnSDxMaL'; // Bella - Multilingual (Thai)
  
  VoiceService({String? apiKey}) 
      : apiKey = apiKey ?? ApiConfig.elevenLabsApiKey;
  
  /// Text-to-Speech ด้วย ElevenLabs
  /// 
  /// [text] - ข้อความที่ต้องการแปลงเป็นเสียง
  /// [language] - ภาษา ('en', 'ja', 'th')
  /// [voiceId] - Voice ID ที่ต้องการใช้ (optional)
  Future<Uint8List> textToSpeech(
    String text, {
    String language = 'en',
    String? voiceId,
  }) async {
    try {
      // เลือก voice ID ตามภาษา
      String selectedVoiceId = voiceId ?? _getVoiceIdForLanguage(language);
      
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-speech/$selectedVoiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_multilingual_v2', // รองรับหลายภาษา
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          debugPrint('TTS returned empty audio data');
          throw Exception('TTS returned empty audio data');
        }
        debugPrint('TTS API call successful, received ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        debugPrint('TTS API error: ${response.statusCode} - ${response.body}');
        throw Exception('TTS failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      throw Exception('TTS error: $e');
    }
  }
  
  /// เล่นเสียงจาก audio data
  Future<void> playAudio(Uint8List audioData) async {
    try {
      // ตั้งค่า audio player mode
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      // เล่นเสียงจาก bytes (ไม่ต้องรอให้เล่นเสร็จ)
      await _audioPlayer.play(BytesSource(audioData));
      debugPrint('Audio playback started successfully');
      
      // ไม่ต้องรอให้เสียงเล่นเสร็จ - ให้เล่นใน background
      // ถ้าต้องการรอให้เล่นเสร็จ สามารถใช้ onPlayerComplete listener ได้
    } catch (e) {
      debugPrint('Play audio error: $e');
      throw Exception('Play audio error: $e');
    }
  }
  
  /// เล่นเสียงจาก text โดยตรง (Text-to-Speech + Play)
  Future<void> speak(String text, {String language = 'en'}) async {
    try {
      if (text.isEmpty) {
        debugPrint('Text is empty, skipping TTS');
        return;
      }
      
      debugPrint('Starting TTS for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      final audioData = await textToSpeech(text, language: language);
      
      if (audioData.isEmpty) {
        throw Exception('TTS returned empty audio data');
      }
      
      debugPrint('TTS successful, audio data size: ${audioData.length} bytes');
      await playAudio(audioData);
      debugPrint('Audio playback completed');
    } catch (e) {
      debugPrint('Speak error: $e');
      throw Exception('Speak error: $e');
    }
  }
  
  /// หยุดการเล่นเสียง
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  /// หยุดชั่วคราว
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  /// เล่นต่อ
  Future<void> resume() async {
    await _audioPlayer.resume();
  }
  
  /// เลือก Voice ID ตามภาษา
  String _getVoiceIdForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'ja':
      case 'japanese':
        return japaneseVoiceId;
      case 'th':
      case 'thai':
        return thaiVoiceId;
      case 'en':
      case 'english':
      default:
        return englishVoiceId;
    }
  }
  
  /// Speech-to-Text ด้วย Google Cloud Speech-to-Text API
  /// 
  /// [audioData] - Audio data ที่ต้องการแปลงเป็นข้อความ
  /// [languageCode] - รหัสภาษา ('th-TH', 'ja-JP', 'en-US')
  /// 
  /// หมายเหตุ: ฟังก์ชันนี้ต้องการ Google Cloud API Key แยกต่างหาก
  /// หากไม่สามารถใช้ Google Cloud ได้ สามารถใช้ speech_to_text package แทนได้
  Future<String> speechToText(
    Uint8List audioData, {
    String languageCode = 'th-TH',
    String? googleCloudApiKey, // ต้องส่ง Google Cloud API Key แยกต่างหาก
  }) async {
    try {
      // ใช้ Google Cloud Speech-to-Text API
      // ต้องมี Google Cloud API Key และเปิดใช้งาน Speech-to-Text API
      // หมายเหตุ: ต้องใช้ Google Cloud API Key แยกต่างหาก (ไม่ใช่ OpenAI key)
      if (googleCloudApiKey == null || googleCloudApiKey.isEmpty) {
        throw Exception('Google Cloud API Key is required for Speech-to-Text. Please use speech_to_text package as an alternative.');
      }
      
      final response = await http.post(
        Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=$googleCloudApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'config': {
            'encoding': 'LINEAR16', // หรือ 'MP3', 'M4A' ตาม audio format
            'sampleRateHertz': 16000,
            'languageCode': languageCode,
            'enableAutomaticPunctuation': true,
          },
          'audio': {
            'content': base64Encode(audioData), // Encode audio เป็น base64
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final transcript = data['results'][0]['alternatives'][0]['transcript'] ?? '';
          debugPrint('Speech-to-Text successful: $transcript');
          return transcript;
        } else {
          debugPrint('Speech-to-Text: No results found');
          return '';
        }
      } else {
        debugPrint('Speech-to-Text API error: ${response.statusCode} - ${response.body}');
        throw Exception('Speech-to-Text failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Speech-to-Text error: $e');
      // ถ้า Google Cloud Speech-to-Text ไม่ได้ ใช้ fallback
      throw Exception('Speech-to-Text error: $e');
    }
  }

  /// วิเคราะห์การออกเสียง (Pronunciation Analysis)
  /// 
  /// [userText] - ข้อความที่ผู้ใช้พูด
  /// [correctWord] - คำที่ถูกต้อง
  /// 
  /// คืนค่า similarity score (0.0 - 1.0)
  double analyzePronunciation(String userText, String correctWord) {
    if (userText.isEmpty || correctWord.isEmpty) {
      return 0.0;
    }
    
    // Normalize text (ลบช่องว่าง, แปลงเป็นตัวพิมพ์เล็ก)
    final normalizedUser = userText.trim().toLowerCase();
    final normalizedCorrect = correctWord.trim().toLowerCase();
    
    // ถ้าตรงกัน 100%
    if (normalizedUser == normalizedCorrect) {
      return 1.0;
    }
    
    // คำนวณ Levenshtein distance (edit distance)
    final distance = _levenshteinDistance(normalizedUser, normalizedCorrect);
    final maxLength = normalizedUser.length > normalizedCorrect.length 
        ? normalizedUser.length 
        : normalizedCorrect.length;
    
    if (maxLength == 0) {
      return 0.0;
    }
    
    // คำนวณ similarity score
    final similarity = 1.0 - (distance / maxLength);
    
    // เพิ่ม bonus ถ้ามีส่วนที่ตรงกัน
    final commonChars = _countCommonCharacters(normalizedUser, normalizedCorrect);
    final charSimilarity = commonChars / maxLength;
    
    // รวม similarity (weighted average)
    return (similarity * 0.6 + charSimilarity * 0.4).clamp(0.0, 1.0);
  }
  
  /// คำนวณ Levenshtein distance (edit distance)
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );
    
    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,        // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// นับจำนวนตัวอักษรที่เหมือนกัน
  int _countCommonCharacters(String a, String b) {
    final aChars = a.split('');
    final bChars = b.split('');
    int count = 0;
    
    for (final char in aChars) {
      if (bChars.contains(char)) {
        count++;
        bChars.remove(char);
      }
    }
    
    return count;
  }

  /// ตรวจสอบว่า API Key ถูกตั้งค่าหรือไม่
  bool get isConfigured => apiKey.isNotEmpty;
}

