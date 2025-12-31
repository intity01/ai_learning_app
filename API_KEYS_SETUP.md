# 🔑 คู่มือตั้งค่า API Keys สำหรับ Hackathon

## 🎯 Overview

แอปนี้ใช้ 2 API services หลัก:
1. **ElevenLabs** - สำหรับ Text-to-Speech และ Voice features
2. **Google Gemini** - สำหรับ AI Tutor responses

---

## 📋 Step 1: รับ ElevenLabs API Key

### 1.1 สร้าง Account
1. ไปที่ [ElevenLabs](https://elevenlabs.io/)
2. คลิก **"Sign Up"** หรือ **"Log In"**
3. สร้าง account (มีฟรี trial)

### 1.2 รับ API Key
1. หลังจาก login แล้ว ไปที่ **Profile** → **API Keys**
2. คลิก **"Create API Key"**
3. ตั้งชื่อ key (เช่น "Flutter AI Learning App")
4. **Copy API Key** (จะแสดงแค่ครั้งเดียว!)

### 1.3 ตัวอย่าง API Key
```
sk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 📋 Step 2: รับ Google Gemini API Key

### 2.1 ไปที่ Google AI Studio
1. ไปที่ [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Login ด้วย Google Account

### 2.2 สร้าง API Key
1. คลิก **"Create API Key"**
2. เลือก Google Cloud Project (หรือสร้างใหม่)
3. **Copy API Key**

### 2.3 ตัวอย่าง API Key
```
AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## 🛠️ Step 3: ตั้งค่า API Keys ใน Flutter

### วิธีที่ 1: ใช้ Environment Variables (แนะนำ)

#### สำหรับ Windows (PowerShell):
```powershell
flutter run --dart-define=ELEVENLABS_API_KEY=sk_xxx --dart-define=GEMINI_API_KEY=AIzaSy_xxx
```

#### สำหรับ macOS/Linux:
```bash
flutter run --dart-define=ELEVENLABS_API_KEY=sk_xxx --dart-define=GEMINI_API_KEY=AIzaSy_xxx
```

### วิธีที่ 2: ใช้ .env file (ต้องติดตั้ง flutter_dotenv)

1. ติดตั้ง package:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. สร้างไฟล์ `.env` ใน root directory:
```
ELEVENLABS_API_KEY=sk_xxx
GEMINI_API_KEY=AIzaSy_xxx
```

3. เพิ่ม `.env` ใน `pubspec.yaml`:
```yaml
flutter:
  assets:
    - .env
```

4. โหลดใน `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  // ...
}
```

### วิธีที่ 3: ตั้งค่าใน Code (ไม่แนะนำ - สำหรับทดสอบเท่านั้น)

แก้ไข `lib/config/api_config.dart`:
```dart
static const String elevenLabsApiKey = 'sk_xxx'; // ใส่ key ที่นี่
static const String geminiApiKey = 'AIzaSy_xxx'; // ใส่ key ที่นี่
```

**⚠️ อย่าลืม:** อย่า commit API keys ลง Git! ใช้ `.gitignore` เพื่อซ่อนไฟล์ `.env`

---

## ✅ Step 4: ตรวจสอบการตั้งค่า

### 4.1 ตรวจสอบในแอป
1. เปิดแอป
2. ไปที่ **AI Tutor** page
3. ถ้ายังไม่ได้ตั้งค่า จะมี dialog แสดงขึ้นมา

### 4.2 ตรวจสอบใน Code
```dart
import '../config/api_config.dart';

print('ElevenLabs configured: ${ApiConfig.elevenLabsApiKey.isNotEmpty}');
print('Gemini configured: ${ApiConfig.geminiApiKey.isNotEmpty}');
```

---

## 🧪 Step 5: ทดสอบ

### 5.1 ทดสอบ Voice Service
```dart
final voiceService = VoiceService();
await voiceService.speak('Hello, world!', language: 'en');
```

### 5.2 ทดสอบ AI Service
```dart
final aiService = AIService();
final response = await aiService.sendMessage('สวัสดี');
print(response);
```

---

## 🔒 Security Best Practices

### ✅ DO:
- ใช้ environment variables
- ใช้ `.env` file (และเพิ่มใน `.gitignore`)
- ใช้ Firebase Remote Config สำหรับ production
- หมุนเวียน API keys เป็นประจำ

### ❌ DON'T:
- Commit API keys ลง Git
- แชร์ API keys ใน public repositories
- ใช้ hardcode API keys ใน production code
- แชร์ API keys กับคนอื่น

---

## 🐛 Troubleshooting

### ปัญหา: "API Key is not configured"
**แก้ไข:** ตรวจสอบว่าได้ตั้งค่า API keys แล้วตาม Step 3

### ปัญหา: "TTS failed: 401"
**แก้ไข:** API key ไม่ถูกต้อง หรือหมดอายุ - ตรวจสอบใน ElevenLabs dashboard

### ปัญหา: "AI error: API key not valid"
**แก้ไข:** Gemini API key ไม่ถูกต้อง - ตรวจสอบใน Google AI Studio

### ปัญหา: "Permission denied"
**แก้ไข:** ตรวจสอบว่าได้ให้ permission สำหรับ microphone แล้ว

---

## 📚 Resources

- [ElevenLabs Documentation](https://docs.elevenlabs.io/)
- [Google Gemini Documentation](https://ai.google.dev/docs)
- [Flutter Environment Variables](https://docs.flutter.dev/deployment/environment-variables)

---

## 🎯 สำหรับ Hackathon Submission

เมื่อ submit hackathon:
1. **อย่า** include API keys ใน code repository
2. ใช้ environment variables หรือ `.env.example` file
3. สร้าง README.md ที่อธิบายวิธีตั้งค่า API keys
4. ใช้ placeholder values ใน demo video

---

**พร้อมแล้ว!** 🚀

