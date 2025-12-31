// lib/services/ai_service_mock.dart
// 🤖 Mock AI Service สำหรับ Demo (เมื่อไม่สามารถตั้งค่า billing ได้)

import 'dart:async';
import 'dart:math';
import '../user_data.dart';

/// Mock AI Service สำหรับ Demo
/// ใช้เมื่อไม่สามารถตั้งค่า billing หรือ API key ได้
class AIServiceMock {
  final Random _random = Random();
  
  /// ส่งข้อความไปยัง AI และรับคำตอบ (Non-streaming)
  /// 
  /// [message] - ข้อความจากผู้ใช้
  /// [history] - ประวัติการสนทนา (optional)
  /// [language] - ภาษาที่ต้องการใช้ (default: 'th')
  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
    String language = 'th',
  }) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    // สร้าง mock response ตามข้อความ
    return _generateMockResponse(message, language);
  }

  /// ส่งข้อความไปยัง AI และรับคำตอบแบบ Streaming (Realtime)
  /// 
  /// [message] - ข้อความจากผู้ใช้
  /// [history] - ประวัติการสนทนา (optional)
  /// [language] - ภาษาที่ต้องการใช้ (default: 'th')
  /// [onChunk] - Callback ที่จะถูกเรียกทุกครั้งที่มี chunk ใหม่
  Stream<String> sendMessageStream(
    String message, {
    List<Map<String, String>>? history,
    String language = 'th',
    Function(String chunk)? onChunk,
  }) async* {
    final response = _generateMockResponse(message, language);
    
    // Simulate streaming by yielding chunks
    final words = response.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future.delayed(Duration(milliseconds: 50 + _random.nextInt(100)));
      
      final chunk = i == 0 ? words[i] : ' ${words[i]}';
      
      if (onChunk != null) {
        onChunk(chunk);
      }
      
      yield chunk;
    }
  }
  
  /// สร้าง Mock Response ตามข้อความ
  String _generateMockResponse(String message, String language) {
    final targetLang = UserData.targetLanguage.value;
    final targetLangNameThai = UserData.targetLanguageToThaiName(targetLang);
    final lowerMessage = message.toLowerCase();
    
    // ตรวจสอบประเภทของข้อความและตอบกลับ
    if (lowerMessage.contains('แปล') || lowerMessage.contains('translate')) {
      return _getTranslationResponse(message, targetLangNameThai, language);
    } else if (lowerMessage.contains('ไวยากรณ์') || lowerMessage.contains('grammar')) {
      return _getGrammarResponse(targetLangNameThai, language);
    } else if (lowerMessage.contains('คำศัพท์') || lowerMessage.contains('vocabulary')) {
      return _getVocabularyResponse(targetLangNameThai, language);
    } else if (lowerMessage.contains('แบบฝึกหัด') || lowerMessage.contains('exercise')) {
      return _getExerciseResponse(targetLangNameThai, language);
    } else if (lowerMessage.contains('สวัสดี') || lowerMessage.contains('hello') || lowerMessage.contains('こんにちは')) {
      return _getGreetingResponse(targetLangNameThai, language);
    } else if (lowerMessage.contains('ช่วย') || lowerMessage.contains('help')) {
      return _getHelpResponse(targetLangNameThai, language);
    } else {
      return _getGeneralResponse(message, targetLangNameThai, language);
    }
  }
  
  String _getTranslationResponse(String message, String targetLang, String language) {
    if (language == 'th') {
      return 'ดีมากครับ! ผมจะช่วยแปลให้คุณ\n\n'
          'ตัวอย่างการแปล:\n'
          '• "สวัสดี" → "Hello" (อังกฤษ) หรือ "こんにちは" (ญี่ปุ่น)\n'
          '• "ขอบคุณ" → "Thank you" (อังกฤษ) หรือ "ありがとう" (ญี่ปุ่น)\n\n'
          'ลองส่งประโยคที่ต้องการแปลมาได้เลยครับ! 😊';
    } else {
      return 'Great! I can help you translate.\n\n'
          'Translation examples:\n'
          '• "Hello" → "สวัสดี" (Thai) or "こんにちは" (Japanese)\n'
          '• "Thank you" → "ขอบคุณ" (Thai) or "ありがとう" (Japanese)\n\n'
          'Send me a sentence you want to translate! 😊';
    }
  }
  
  String _getGrammarResponse(String targetLang, String language) {
    if (language == 'th') {
      return 'ดีครับ! ผมจะอธิบายไวยากรณ์$targetLangให้คุณ\n\n'
          '**ตัวอย่างไวยากรณ์:**\n'
          '• โครงสร้างประโยคพื้นฐาน\n'
          '• การใช้คำกริยา\n'
          '• การผันคำ\n\n'
          'มีส่วนไหนที่อยากรู้เพิ่มเติมไหมครับ? 📚';
    } else {
      return 'Great! I can explain $targetLang grammar.\n\n'
          '**Grammar examples:**\n'
          '• Basic sentence structure\n'
          '• Verb usage\n'
          '• Word conjugation\n\n'
          'What would you like to learn more about? 📚';
    }
  }
  
  String _getVocabularyResponse(String targetLang, String language) {
    if (language == 'th') {
      return 'เยี่ยมเลย! ผมจะแนะนำคำศัพท์$targetLangให้คุณ\n\n'
          '**คำศัพท์ที่ควรรู้:**\n'
          '• คำทักทาย\n'
          '• คำศัพท์ในชีวิตประจำวัน\n'
          '• คำศัพท์สำหรับการเดินทาง\n\n'
          'ลองไปดูที่หน้า Vocabulary ในแอปได้เลยครับ! 📖';
    } else {
      return 'Excellent! I can help you learn $targetLang vocabulary.\n\n'
          '**Important vocabulary:**\n'
          '• Greetings\n'
          '• Daily life words\n'
          '• Travel phrases\n\n'
          'Check out the Vocabulary page in the app! 📖';
    }
  }
  
  String _getExerciseResponse(String targetLang, String language) {
    if (language == 'th') {
      return 'ดีมากครับ! ผมจะสร้างแบบฝึกหัด$targetLangให้คุณ\n\n'
          '**แบบฝึกหัดที่แนะนำ:**\n'
          '1. แบบฝึกหัดการแปล\n'
          '2. แบบฝึกหัดไวยากรณ์\n'
          '3. แบบฝึกหัดคำศัพท์\n\n'
          'ลองไปดูที่หน้า Lessons ในแอปได้เลยครับ! ✏️';
    } else {
      return 'Great! I can create $targetLang exercises for you.\n\n'
          '**Recommended exercises:**\n'
          '1. Translation exercises\n'
          '2. Grammar exercises\n'
          '3. Vocabulary exercises\n\n'
          'Check out the Lessons page in the app! ✏️';
    }
  }
  
  String _getGreetingResponse(String targetLang, String language) {
    if (language == 'th') {
      return 'สวัสดีครับ! 👋\n\n'
          'ยินดีที่ได้รู้จักครับ! ผมเป็น AI Tutor ที่จะช่วยคุณเรียน$targetLang\n\n'
          'ผมสามารถช่วยคุณได้ใน:\n'
          '• แปลภาษา\n'
          '• อธิบายไวยากรณ์\n'
          '• แนะนำคำศัพท์\n'
          '• สร้างแบบฝึกหัด\n\n'
          'มีอะไรให้ผมช่วยไหมครับ? 😊';
    } else {
      return 'Hello! 👋\n\n'
          'Nice to meet you! I\'m an AI Tutor to help you learn $targetLang.\n\n'
          'I can help you with:\n'
          '• Translation\n'
          '• Grammar explanations\n'
          '• Vocabulary recommendations\n'
          '• Creating exercises\n\n'
          'How can I help you today? 😊';
    }
  }
  
  String _getHelpResponse(String targetLang, String language) {
    if (language == 'th') {
      return 'ยินดีช่วยเหลือครับ! 😊\n\n'
          'ผมสามารถช่วยคุณได้ใน:\n'
          '1. **แปลภาษา** - แปลระหว่างภาษาไทยและ$targetLang\n'
          '2. **อธิบายไวยากรณ์** - อธิบายกฎไวยากรณ์อย่างละเอียด\n'
          '3. **แนะนำคำศัพท์** - แนะนำคำศัพท์ที่ควรรู้\n'
          '4. **สร้างแบบฝึกหัด** - สร้างคำถามและแบบฝึกหัด\n'
          '5. **แก้ไขประโยค** - แก้ไขและอธิบายว่าทำไมผิด\n\n'
          'ลองพิมพ์คำถามหรือประโยคที่ต้องการความช่วยเหลือมาได้เลยครับ! 💪';
    } else {
      return 'Happy to help! 😊\n\n'
          'I can help you with:\n'
          '1. **Translation** - Translate between Thai and $targetLang\n'
          '2. **Grammar** - Explain grammar rules in detail\n'
          '3. **Vocabulary** - Recommend important words\n'
          '4. **Exercises** - Create questions and exercises\n'
          '5. **Corrections** - Fix and explain mistakes\n\n'
          'Try typing a question or sentence you need help with! 💪';
    }
  }
  
  String _getGeneralResponse(String message, String targetLang, String language) {
    if (language == 'th') {
      final responses = [
        'ดีมากครับ! ประโยค "$message" ดูดีเลยครับ 👍\n\n'
        'มีอะไรให้ผมช่วยเพิ่มเติมไหมครับ?',
        
        'เข้าใจแล้วครับ! ผมจะช่วยคุณเรียน$targetLangให้ดีขึ้น\n\n'
        'ลองถามคำถามหรือส่งประโยคมาได้เลยครับ!',
        
        'เยี่ยมเลยครับ! 💯\n\n'
        'ถ้ามีคำถามเกี่ยวกับ$targetLang หรือต้องการความช่วยเหลือ บอกผมได้เลยครับ!',
        
        'ดีครับ! ผมพร้อมช่วยคุณเรียน$targetLang\n\n'
        'ลองใช้คำสั่งเหล่านี้:\n'
        '• "แปล [ประโยค]" - สำหรับแปลภาษา\n'
        '• "ไวยากรณ์" - สำหรับอธิบายไวยากรณ์\n'
        '• "คำศัพท์" - สำหรับแนะนำคำศัพท์',
      ];
      
      return responses[_random.nextInt(responses.length)];
    } else {
      final responses = [
        'Great! The sentence "$message" looks good! 👍\n\n'
        'Is there anything else I can help with?',
        
        'I understand! I\'ll help you learn $targetLang better.\n\n'
        'Try asking a question or sending a sentence!',
        
        'Excellent! 💯\n\n'
        'If you have questions about $targetLang or need help, just let me know!',
        
        'Good! I\'m ready to help you learn $targetLang.\n\n'
        'Try these commands:\n'
        '• "translate [sentence]" - for translation\n'
        '• "grammar" - for grammar explanations\n'
        '• "vocabulary" - for vocabulary recommendations',
      ];
      
      return responses[_random.nextInt(responses.length)];
    }
  }
  
  /// ตรวจสอบว่า API Key ถูกตั้งค่าหรือไม่ (Mock จะ return false เสมอ)
  bool get isConfigured => false;
}


