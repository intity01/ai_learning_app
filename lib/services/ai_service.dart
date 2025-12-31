// lib/services/ai_service.dart
// 🤖 AI Service สำหรับ Google Gemini Integration

import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import '../config/api_config.dart';
import '../user_data.dart';
import 'ai_service_mock.dart';

/// AI Service สำหรับ Google Gemini
/// ใช้ Mock Service อัตโนมัติเมื่อไม่มี API key
class AIService {
  String _apiKey; // จะตั้งค่าใน environment variables
  GenerativeModel? model;
  final AIServiceMock _mockService = AIServiceMock();
  bool _useMock = false;
  
  AIService({String? apiKey}) 
      : _apiKey = apiKey ?? ApiConfig.geminiApiKey {
    if (_apiKey.isNotEmpty) {
      try {
        _initializeModel();
      } catch (e) {
        // ถ้า initialize ไม่ได้ ให้ใช้ mock service
        _useMock = true;
      }
    } else {
      _useMock = true;
    }
  }
  
  String get apiKey => _apiKey;
  bool get useMock => _useMock;
  
  void _initializeModel() {
    // ใช้ model name ที่ถูกต้องตาม Google Generative AI package version 0.2.3
    // สำหรับ package version 0.2.x ใช้ 'gemini-pro' หรือ 'gemini-1.5-flash'
    // ไม่ต้องใส่ 'models/' prefix
    model = GenerativeModel(
      model: 'gemini-pro', // ใช้ gemini-pro สำหรับ version 0.2.3
      apiKey: _apiKey,
    );
    _useMock = false;
  }
  
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
    // ใช้ Mock Service ถ้าไม่มี API key หรือใช้ mock mode
    if (_useMock || _apiKey.isEmpty || model == null) {
      return await _mockService.sendMessage(message, history: history, language: language);
    }
    
    try {
      
      // สร้าง system prompt สำหรับ AI Tutor
      final systemPrompt = _getSystemPrompt(language);
      
      // สร้าง prompt รวม system prompt + history + message
      String fullPrompt = systemPrompt + '\n\n';
      
      // เพิ่มประวัติการสนทนา (ถ้ามี)
      if (history != null && history.isNotEmpty) {
        for (var msg in history) {
          final text = msg['text'] ?? '';
          if (text.isNotEmpty) {
            final sender = msg['sender'] == 'user' ? 'ผู้ใช้' : 'AI Tutor';
            fullPrompt += '$sender: $text\n';
          }
        }
        fullPrompt += '\n';
      }
      
      // เพิ่มข้อความปัจจุบัน
      fullPrompt += 'ผู้ใช้: $message\nAI Tutor:';
      
      // ส่ง request ไปยัง Gemini (ใช้ prompt เดียว)
      if (model == null) {
        throw Exception('Gemini model is not initialized');
      }
      final response = await model!.generateContent([Content.text(fullPrompt)]);
      
      return response.text ?? 'ขอโทษครับ ไม่สามารถสร้างคำตอบได้';
    } catch (e) {
      // ถ้า API error ให้ fallback ไปใช้ mock service
      print('AI API error: $e - Falling back to mock service');
      return await _mockService.sendMessage(message, history: history, language: language);
    }
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
    // ใช้ Mock Service ถ้าไม่มี API key หรือใช้ mock mode
    if (_useMock || _apiKey.isEmpty || model == null) {
      yield* _mockService.sendMessageStream(message, history: history, language: language, onChunk: onChunk);
      return;
    }
    
    try {
      
      // สร้าง system prompt สำหรับ AI Tutor
      final systemPrompt = _getSystemPrompt(language);
      
      // สร้าง prompt รวม system prompt + history + message
      String fullPrompt = systemPrompt + '\n\n';
      
      // เพิ่มประวัติการสนทนา (ถ้ามี)
      if (history != null && history.isNotEmpty) {
        for (var msg in history) {
          final text = msg['text'] ?? '';
          if (text.isNotEmpty) {
            final sender = msg['sender'] == 'user' ? 'ผู้ใช้' : 'AI Tutor';
            fullPrompt += '$sender: $text\n';
          }
        }
        fullPrompt += '\n';
      }
      
      // เพิ่มข้อความปัจจุบัน
      fullPrompt += 'ผู้ใช้: $message\nAI Tutor:';
      
      // ส่ง request แบบ streaming ไปยัง Gemini
      // model ถูกเช็คแล้วที่บรรทัด 111 แต่ต้องใช้ ! เพื่อบอก compiler ว่าไม่เป็น null
      final responseStream = model!.generateContentStream([Content.text(fullPrompt)]);
      
      String accumulatedText = '';
      
      await for (final response in responseStream) {
        final chunk = response.text;
        if (chunk != null && chunk.isNotEmpty) {
          accumulatedText += chunk;
          
          // เรียก callback ถ้ามี
          if (onChunk != null) {
            onChunk(chunk);
          }
          
          // yield chunk เพื่อให้ UI อัปเดตแบบ realtime
          yield chunk;
        }
      }
    } catch (e) {
      // ถ้า API error ให้ fallback ไปใช้ mock service
      print('AI API error: $e - Falling back to mock service');
      yield* _mockService.sendMessageStream(message, history: history, language: language, onChunk: onChunk);
    }
  }
  
  /// สร้าง System Prompt สำหรับ AI Tutor
  String _getSystemPrompt(String language) {
    // ดึง targetLanguage จาก UserData
    final targetLang = UserData.targetLanguage.value;
    final targetLangNameThai = UserData.targetLanguageToThaiName(targetLang);
    final targetLangNameEnglish = UserData.targetLanguageToEnglishName(targetLang);
    
    if (language == 'th') {
      return '''
คุณเป็น AI Tutor สำหรับการเรียน$targetLangNameThai
คุณเป็นผู้ช่วยสอนที่ใจดีและเข้าใจง่าย ช่วยผู้ใช้เรียนรู้ภาษาโดยการ:

1. **แก้ไขประโยคที่ผิด** - แก้ไขและอธิบายว่าทำไมผิด
2. **แปลภาษา** - แปลระหว่างภาษาไทยและ$targetLangNameThai
3. **อธิบายไวยากรณ์** - อธิบายกฎไวยากรณ์อย่างละเอียด
4. **ให้คำแนะนำในการเรียน** - แนะนำเทคนิคการเรียนภาษา
5. **สร้างแบบฝึกหัด** - สร้างคำถามและแบบฝึกหัดให้ผู้ใช้

**สไตล์การตอบ:**
- ใช้ภาษาที่เข้าใจง่าย
- ใช้ตัวอย่างที่ชัดเจน
- ให้กำลังใจและสร้างแรงบันดาลใจ
- ตอบเป็นภาษาไทย (เว้นแต่ผู้ใช้ขอภาษาอื่น)

**ตัวอย่างการตอบ:**
- "ดีมากเลยครับ! คำตอบของคุณถูกต้องแล้ว"
- "ลองดูประโยคนี้: [ตัวอย่าง]"
- "คำนี้แปลว่า [ความหมาย] และใช้ในบริบท [ตัวอย่าง]"

เริ่มสนทนากับผู้ใช้ได้เลย!
''';
    } else {
      return '''
You are an AI Tutor for learning $targetLangNameEnglish.
You are a friendly and easy-to-understand teaching assistant. Help users learn languages by:

1. **Correcting mistakes** - Fix and explain why it's wrong
2. **Translating** - Translate between Thai and $targetLangNameEnglish
3. **Explaining grammar** - Explain grammar rules in detail
4. **Giving learning tips** - Recommend language learning techniques
5. **Creating exercises** - Create questions and exercises for users

**Response style:**
- Use easy-to-understand language
- Use clear examples
- Encourage and inspire
- Respond in English (unless user requests another language)

Start the conversation with the user!
''';
    }
  }
  
  /// ตรวจสอบว่า API Key ถูกตั้งค่าหรือไม่
  bool get isConfigured => _apiKey.isNotEmpty && !_useMock;
  
  /// ตั้งค่า API Key (สำหรับ runtime configuration)
  void setApiKey(String key) {
    if (key.isNotEmpty) {
      _apiKey = key;
      try {
        _initializeModel();
      } catch (e) {
        _useMock = true;
      }
    }
  }
  
  /// เปิด/ปิด Mock Mode (สำหรับ testing)
  void setMockMode(bool enabled) {
    _useMock = enabled;
  }
}

