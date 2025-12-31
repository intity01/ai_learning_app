# 📚 แหล่งข้อมูลสำหรับบทเรียนภาษา

## 🔍 ปัญหาปัจจุบัน

**ข้อมูลที่มีอยู่:**
- ❌ มีแค่ **3 บทเรียน**
- ❌ แต่ละบทมี **2-3 คำถาม** เท่านั้น
- ❌ ข้อมูลถูก hardcode ในโค้ด
- ❌ ไม่สามารถเพิ่มข้อมูลได้ง่าย

---

## 🎯 แหล่งข้อมูลที่แนะนำ

### **Option 1: ใช้ API ฟรี** (แนะนำที่สุด) 🚀

#### 1.1 **Tatoeba API** (ฟรี, เปิด source)
- **URL:** `https://tatoeba.org/en/api`
- **ข้อมูล:** ประโยคตัวอย่างหลายภาษา (รวมญี่ปุ่น, อังกฤษ)
- **ข้อดี:** ฟรี, มีข้อมูลเยอะมาก
- **ข้อเสีย:** ไม่มีคำถามพร้อมคำตอบ

**ตัวอย่าง:**
```dart
// GET https://tatoeba.org/en/api/v0/sentences?query=hello&lang=jpn
{
  "data": [
    {
      "id": 123,
      "text": "こんにちは",
      "lang": "jpn"
    }
  ]
}
```

#### 1.2 **Jisho API** (Japanese Dictionary)
- **URL:** `https://jisho.org/api/v1/search/words?keyword=hello`
- **ข้อมูล:** คำศัพท์ภาษาญี่ปุ่น + ความหมาย + ตัวอย่างประโยค
- **ข้อดี:** ข้อมูลละเอียด, มี romaji
- **ข้อเสีย:** เฉพาะภาษาญี่ปุ่น

**ตัวอย่าง:**
```dart
// GET https://jisho.org/api/v1/search/words?keyword=こんにちは
{
  "data": [{
    "japanese": [{"word": "こんにちは", "reading": "こんにちは"}],
    "senses": [{
      "english_definitions": ["hello", "good afternoon"]
    }]
  }]
}
```

#### 1.3 **Free Dictionary API**
- **URL:** `https://api.dictionaryapi.dev/api/v2/entries/en/hello`
- **ข้อมูล:** คำศัพท์ภาษาอังกฤษ + ความหมาย + ตัวอย่าง
- **ข้อดี:** ฟรี, ข้อมูลละเอียด
- **ข้อเสีย:** เฉพาะภาษาอังกฤษ

---

### **Option 2: ใช้ Dataset/JSON Files** 📁

#### 2.1 **Japanese Vocabulary Dataset**
- **แหล่ง:** GitHub repositories
- **ตัวอย่าง:**
  - `https://github.com/kanjialive/kanji-data-media`
  - `https://github.com/mifunetoshiro/kanjium`

#### 2.2 **English Vocabulary Dataset**
- **แหล่ง:** 
  - `https://github.com/dwyl/english-words`
  - `https://github.com/words/an-array-of-english-words`

#### 2.3 **สร้าง JSON File เอง**
```json
// assets/data/japanese_lessons.json
{
  "lessons": [
    {
      "id": 1,
      "title": "พื้นฐานภาษาญี่ปุ่น 1",
      "level": "N5",
      "questions": [
        {
          "question": "คำว่า 'สวัสดี' ภาษาญี่ปุ่นคือ?",
          "options": ["Sayonara", "Konnichiwa", "Arigatou", "Sumimasen"],
          "correctAnswerIndex": 1,
          "explanation": "Konnichiwa (こんにちは) แปลว่า 'สวัสดี'"
        }
      ]
    }
  ]
}
```

---

### **Option 3: ใช้ AI สร้างข้อมูล** 🤖

#### 3.1 **ใช้ OpenAI/Gemini API**
- สร้างคำถามอัตโนมัติจากหัวข้อ
- สร้างคำอธิบายอัตโนมัติ
- สร้างคำศัพท์อัตโนมัติ

**ตัวอย่าง Prompt:**
```
สร้างคำถาม 10 ข้อสำหรับบทเรียน "พื้นฐานภาษาญี่ปุ่น N5" 
แต่ละคำถามต้องมี:
- คำถามภาษาไทย
- 4 ตัวเลือก (1 ถูก, 3 ผิด)
- คำอธิบายภาษาไทย
```

#### 3.2 **ใช้ Claude/GPT-4**
- สร้างบทเรียนครบชุด
- สร้างคำถามหลากหลาย
- สร้างคำอธิบายละเอียด

---

### **Option 4: ใช้ Firebase/Firestore** 🔥

#### 4.1 **เก็บข้อมูลใน Firestore**
- สร้าง Collection `lessons`
- สร้าง Collection `questions`
- Admin สามารถเพิ่มข้อมูลได้ง่าย

**โครงสร้าง:**
```
lessons/
  {lessonId}/
    title: "พื้นฐานภาษาญี่ปุ่น 1"
    level: "N5"
    questions: [
      {
        question: "...",
        options: [...],
        correctAnswerIndex: 1,
        explanation: "..."
      }
    ]
```

---

## 🛠️ วิธีใช้งาน

### **วิธีที่ 1: โหลดจาก JSON File** (ง่ายที่สุด)

#### Step 1: สร้าง JSON File
```bash
# สร้างโฟลเดอร์
mkdir -p assets/data

# สร้างไฟล์
touch assets/data/japanese_lessons.json
```

#### Step 2: เพิ่ม JSON ใน pubspec.yaml
```yaml
flutter:
  assets:
    - assets/data/japanese_lessons.json
```

#### Step 3: สร้าง Service โหลดข้อมูล
```dart
// lib/services/lesson_data_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class LessonDataService {
  static Future<Map<int, List<Question>>> loadLessonsFromJson() async {
    final String jsonString = await rootBundle.loadString('assets/data/japanese_lessons.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    Map<int, List<Question>> questions = {};
    
    for (var lesson in jsonData['lessons']) {
      int lessonId = lesson['id'];
      List<Question> lessonQuestions = [];
      
      for (var q in lesson['questions']) {
        lessonQuestions.add(Question(
          question: q['question'],
          options: List<String>.from(q['options']),
          correctAnswerIndex: q['correctAnswerIndex'],
          explanation: q['explanation'],
        ));
      }
      
      questions[lessonId] = lessonQuestions;
    }
    
    return questions;
  }
}
```

---

### **วิธีที่ 2: โหลดจาก API** (ยืดหยุ่นที่สุด)

#### Step 1: สร้าง API Service
```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://api.yourapp.com';
  
  Future<List<Question>> getLessonQuestions(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId/questions'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((q) => Question.fromJson(q)).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
```

#### Step 2: ใช้ใน LessonDetailPage
```dart
// lib/pages/lesson_detail_page.dart
final apiService = ApiService();

@override
void initState() {
  super.initState();
  _loadQuestions();
}

Future<void> _loadQuestions() async {
  setState(() => isLoading = true);
  try {
    _questions = await apiService.getLessonQuestions(widget.lessonId);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => isLoading = false);
  }
}
```

---

### **วิธีที่ 3: ใช้ AI สร้างข้อมูล** (เร็วที่สุด)

#### Step 1: สร้าง AI Data Generator
```dart
// lib/services/ai_data_generator.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIDataGenerator {
  final String apiKey = 'YOUR_OPENAI_API_KEY';
  
  Future<List<Question>> generateQuestions({
    required String topic,
    required int count,
    required String level,
  }) async {
    final prompt = '''
สร้างคำถาม $count ข้อสำหรับบทเรียน "$topic" ระดับ $level
แต่ละคำถามต้องมี:
- question: คำถามภาษาไทย
- options: 4 ตัวเลือก (1 ถูก, 3 ผิด)
- correctAnswerIndex: 0-3
- explanation: คำอธิบายภาษาไทย

ตอบในรูปแบบ JSON array
''';
    
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );
    
    // Parse response and return questions
    // ...
  }
}
```

---

## 📊 เปรียบเทียบแต่ละวิธี

| วิธี | ข้อดี | ข้อเสีย | เหมาะกับ |
|------|------|--------|---------|
| **JSON File** | ง่าย, เร็ว, ไม่ต้องใช้ internet | ต้องอัปเดตแอปใหม่ | MVP, Prototype |
| **API** | ยืดหยุ่น, อัปเดตได้ทันที | ต้องมี backend, ใช้ internet | Production |
| **Firebase** | ง่าย, มี admin panel | ต้องจ่ายเงิน (ถ้ามาก) | Production |
| **AI Generate** | เร็ว, สร้างได้เยอะ | ต้องจ่าย API, คุณภาพไม่แน่นอน | Prototype |

---

## 🎯 แนะนำสำหรับโปรเจกต์นี้

### **Phase 1: MVP (ตอนนี้)**
- ✅ ใช้ **JSON File** - สร้างข้อมูล 10-20 บทเรียน
- ✅ เก็บใน `assets/data/lessons.json`
- ✅ โหลดตอนเริ่มแอป

### **Phase 2: Production**
- ✅ ใช้ **Firebase Firestore** - เก็บข้อมูลใน cloud
- ✅ Admin สามารถเพิ่มข้อมูลได้
- ✅ Sync อัตโนมัติ

### **Phase 3: Advanced**
- ✅ ใช้ **AI Generate** - สร้างคำถามอัตโนมัติ
- ✅ ใช้ **API** - โหลดข้อมูลจากแหล่งภายนอก

---

## 📝 Next Steps

1. **สร้าง JSON File** - สร้างข้อมูล 10-20 บทเรียน
2. **สร้าง Service** - โหลดข้อมูลจาก JSON
3. **ทดสอบ** - ตรวจสอบว่าโหลดข้อมูลได้
4. **เพิ่มข้อมูล** - เพิ่มบทเรียนและคำถาม

---

**ต้องการให้ช่วยสร้าง JSON File และ Service โหลดข้อมูลไหม?** 🚀


