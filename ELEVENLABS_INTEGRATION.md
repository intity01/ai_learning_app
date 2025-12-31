# 🎤 ElevenLabs Integration Guide

## 🎯 Challenge: ElevenLabs + Google Cloud AI

**Goal:** ทำให้แอปเป็น **voice-driven, conversational, intelligent** language learning app

---

## 📋 Features ที่ต้องทำ

### **1. Voice Tutor (AI + Voice)** 🤖🎤
- ผู้ใช้สามารถ **พูดกับ AI Tutor** ได้
- AI ตอบกลับด้วย **natural voice**
- ใช้ **Gemini API** สำหรับ AI responses
- ใช้ **ElevenLabs TTS** สำหรับเสียงพูด

### **2. Pronunciation Practice** 🗣️
- ใช้ **ElevenLabs Speech-to-Text** สำหรับตรวจสอบการออกเสียง
- ใช้ **ElevenLabs TTS** สำหรับตัวอย่างการออกเสียง
- แสดง feedback ว่าออกเสียงถูกต้องหรือไม่

### **3. Vocabulary Pronunciation** 📚
- เพิ่มปุ่ม Play Sound ใน Vocabulary Page
- ใช้ **ElevenLabs TTS** สำหรับออกเสียงคำศัพท์
- รองรับหลายภาษา (ญี่ปุ่น, อังกฤษ)

---

## 🛠️ Implementation

### **Step 1: Get ElevenLabs API Key**

1. ไปที่ [ElevenLabs](https://elevenlabs.io/)
2. สร้าง account (ฟรี trial)
3. ไปที่ API Keys section
4. Copy API Key

### **Step 2: Install Dependencies**

```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0  # มีอยู่แล้ว
  google_generative_ai: ^0.2.0  # สำหรับ Gemini
  record: ^5.0.4  # สำหรับ Speech-to-Text
  permission_handler: ^11.0.0  # สำหรับ permissions
```

### **Step 3: Create Voice Service**

```dart
// lib/services/voice_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class VoiceService {
  final String apiKey = 'YOUR_ELEVENLABS_API_KEY';
  final String baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Text-to-Speech
  Future<Uint8List> textToSpeech(String text, {String voiceId = '21m00Tcm4TlvDq8ikWAM'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-speech/$voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('TTS failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('TTS error: $e');
    }
  }
  
  // Speech-to-Text (ใช้ ElevenLabs Speech-to-Text หรือ Google Speech-to-Text)
  Future<String> speechToText(Uint8List audioData) async {
    // TODO: Implement Speech-to-Text
    // สามารถใช้ Google Cloud Speech-to-Text API แทนได้
    return '';
  }
}
```

### **Step 4: Create AI Service (Gemini)**

```dart
// lib/services/ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final String apiKey = 'YOUR_GEMINI_API_KEY';
  late final GenerativeModel model;
  
  AIService() {
    model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }
  
  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    try {
      final prompt = '''
คุณเป็น AI Tutor สำหรับการเรียนภาษาญี่ปุ่นและอังกฤษ
ช่วยผู้ใช้เรียนรู้ภาษาโดยการ:
- แก้ไขประโยคที่ผิด
- แปลภาษา
- อธิบายไวยากรณ์
- ให้คำแนะนำในการเรียน

ประวัติการสนทนา:
${history.map((h) => '${h['sender']}: ${h['text']}').join('\n')}

ผู้ใช้: $message
AI Tutor:''';
      
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'ขอโทษครับ ไม่สามารถสร้างคำตอบได้';
    } catch (e) {
      throw Exception('AI error: $e');
    }
  }
}
```

### **Step 5: Update AI Tutor Page**

```dart
// lib/pages/ai_tutor_page.dart
import '../services/ai_service.dart';
import '../services/voice_service.dart';

class AITutorPage extends StatefulWidget {
  // ...
  
  final AIService aiService = AIService();
  final VoiceService voiceService = VoiceService();
  bool isListening = false;
  
  Future<void> _sendMessage(String text) async {
    // Add user message
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    
    // Get AI response
    try {
      final response = await aiService.sendMessage(text, _messages);
      
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': response,
          'time': _getCurrentTime(),
        });
      });
      
      // Play AI response with voice
      await _playVoice(response);
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> _playVoice(String text) async {
    try {
      final audioData = await voiceService.textToSpeech(text);
      // Play audio using audio player
      // ...
    } catch (e) {
      print('Voice error: $e');
    }
  }
  
  Future<void> _startListening() async {
    // Start recording
    // ...
  }
  
  Future<void> _stopListening() async {
    // Stop recording and convert to text
    // ...
    final text = await voiceService.speechToText(audioData);
    if (text.isNotEmpty) {
      _sendMessage(text);
    }
  }
}
```

---

## 🎯 ElevenLabs Challenge Requirements Checklist

- [ ] ใช้ **ElevenLabs Agents** + **Google Cloud Vertex AI/Gemini**
- [ ] ให้แอปมี **natural, human voice** และ **personality**
- [ ] ผู้ใช้สามารถ **interact ผ่าน speech** ได้
- [ ] ใช้ **React SDK** หรือ **server-side calls** บน Google Cloud
- [ ] Deploy บน Google Cloud
- [ ] สร้าง Demo Video (3 minutes)

---

## 📝 Next Steps

1. **Get API Keys** - ElevenLabs + Google Cloud
2. **Implement Services** - VoiceService + AIService
3. **Update UI** - เพิ่ม voice features
4. **Test** - ทดสอบ voice interaction
5. **Deploy** - Deploy บน Google Cloud

---

**พร้อมเริ่มแล้ว!** 🚀


