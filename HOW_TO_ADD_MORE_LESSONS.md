# วิธีเพิ่มบทเรียนให้มากขึ้น

## 🎯 วิธีที่แนะนำสำหรับ Hackathon

### **วิธีที่ 1: ใช้ Jisho API (แนะนำมากที่สุด)** ⭐

#### ข้อดี:
- ✅ ฟรี 100% ไม่จำกัด
- ✅ ข้อมูลจริงจาก Jisho.org
- ✅ มีคำศัพท์มากกว่า 200,000 คำ
- ✅ มีการอ่าน (reading), ความหมาย, ตัวอย่างประโยค

#### วิธีใช้งาน:

1. **เพิ่ม http package** (มีอยู่แล้วใน `pubspec.yaml`)

2. **ใช้ VocabularyApiService**:
```dart
import 'package:your_app/services/vocabulary_api_service.dart';

// ค้นหาคำศัพท์
final wordData = await VocabularyApiService.searchJapaneseWord('こんにちは');
```

3. **สร้างบทเรียนอัตโนมัติ**:
```dart
// สร้างบทเรียนจากคำศัพท์ที่ใช้บ่อย
final commonWords = await VocabularyApiService.fetchCommonWords('JP');
final questions = await VocabularyApiService.generateLessonFromWords(
  words: commonWords.take(20).toList(),
  language: 'JP',
  level: 'Beginner',
);
```

---

### **วิธีที่ 2: ใช้ GitHub Raw Content** ⭐⭐

#### ข้อดี:
- ✅ ฟรี 100%
- ✅ ไม่ต้องมี API key
- ✅ ข้อมูลมากมาย
- ✅ ใช้ได้ทันที

#### แหล่งข้อมูลที่แนะนำ:

1. **Japanese Vocabulary (JLPT)**
   - URL: `https://raw.githubusercontent.com/scriptin/jmdict-simplified/master/data/jmdict_english.json`
   - ข้อมูล: คำศัพท์ภาษาญี่ปุ่นมากกว่า 200,000 คำ

2. **Frequency Words**
   - URL: `https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ja/ja_50k.txt`
   - ข้อมูล: คำศัพท์ที่ใช้บ่อย 50,000 คำ

3. **Chinese Vocabulary (HSK)**
   - URL: `https://raw.githubusercontent.com/mozilla/cc-cedict/master/cedict_ts.u8`
   - ข้อมูล: คำศัพท์จีน-อังกฤษ

#### วิธีใช้งาน:

```dart
// โหลดคำศัพท์จาก GitHub
Future<List<String>> loadVocabularyFromGitHub() async {
  final response = await http.get(
    Uri.parse('https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/ja/ja_50k.txt')
  );
  
  final lines = response.body.split('\n');
  return lines
      .where((line) => line.trim().isNotEmpty)
      .take(1000)
      .map((line) => line.split('\t')[0].trim())
      .toList();
}
```

---

### **วิธีที่ 3: ใช้ Tatoeba API (ตัวอย่างประโยค)** ⭐⭐⭐

#### ข้อดี:
- ✅ ฟรี 100%
- ✅ มีตัวอย่างประโยคหลายภาษา
- ✅ License: CC-BY 2.0

#### วิธีใช้งาน:

```dart
// ดึงตัวอย่างประโยค
final sentences = await VocabularyApiService.fetchExampleSentences(
  fromLang: 'jpn', // ภาษาญี่ปุ่น
  toLang: 'eng',   // แปลเป็นอังกฤษ
  query: 'こんにちは',
  limit: 10,
);
```

---

### **วิธีที่ 4: สร้างข้อมูลเองด้วย Gemini API** ⭐⭐⭐⭐

#### ข้อดี:
- ✅ ควบคุมเนื้อหาได้ 100%
- ✅ สร้างบทเรียนตามต้องการ
- ✅ มี Free tier จาก Google

#### วิธีใช้งาน:

```dart
// ใช้ Gemini API สร้างบทเรียน
final prompt = '''
สร้างบทเรียนภาษาญี่ปุ่นระดับ N5 เรื่อง "พื้นฐานการทักทาย"
ประกอบด้วย:
- คำถาม 10 ข้อแบบ multiple choice
- แต่ละคำถามมี 4 ตัวเลือก
- มีคำอธิบายภาษาไทย
''';

final response = await _aiService.sendMessage(prompt);
// Parse response เป็น JSON และสร้าง Question objects
```

---

## 📝 ตัวอย่างการเพิ่มบทเรียน

### **ตัวอย่าง 1: เพิ่มบทเรียนจาก Jisho API**

```dart
// lib/services/enhanced_lesson_service.dart
class EnhancedLessonService {
  static Future<List<Question>> generateJapaneseLesson({
    required String topic,
    required int questionCount,
  }) async {
    List<Question> questions = [];
    
    // 1. ดึงคำศัพท์ที่เกี่ยวข้อง
    final wordData = await VocabularyApiService.searchJapaneseWord(topic);
    
    if (wordData != null) {
      // 2. สร้างคำถามจากข้อมูลที่ได้
      questions.add(Question(
        question: 'คำว่า "${wordData['slug']}" หมายถึงอะไร?',
        options: _generateOptions(wordData),
        correctAnswerIndex: 0,
        explanation: _getExplanation(wordData),
      ));
    }
    
    return questions;
  }
}
```

### **ตัวอย่าง 2: เพิ่มบทเรียนจาก GitHub**

```dart
// โหลดคำศัพท์จาก GitHub
Future<Map<int, List<Question>>> loadLessonsFromGitHub() async {
  // 1. โหลดคำศัพท์
  final words = await VocabularyApiService.fetchCommonWords('JP');
  
  // 2. แบ่งเป็นบทเรียน (20 คำต่อบท)
  Map<int, List<Question>> lessons = {};
  int lessonId = 1;
  
  for (int i = 0; i < words.length; i += 20) {
    final lessonWords = words.sublist(i, i + 20);
    final questions = await _generateQuestionsFromWords(lessonWords);
    lessons[lessonId++] = questions;
  }
  
  return lessons;
}
```

---

## 🚀 Quick Start

### **Step 1: ใช้ Jisho API (ง่ายที่สุด)**

```dart
// ใน lesson_detail_page.dart
Future<void> _loadQuestions() async {
  // ใช้ Jisho API เพื่อดึงข้อมูลคำศัพท์
  final wordData = await VocabularyApiService.searchJapaneseWord('こんにちは');
  
  if (wordData != null) {
    // สร้างคำถามจากข้อมูลที่ได้
    setState(() {
      _questions = _convertToQuestions(wordData);
    });
  }
}
```

### **Step 2: เพิ่มบทเรียนใน JSON File**

```json
{
  "lessons": [
    {
      "id": 9,
      "title": "คำศัพท์พื้นฐาน N5 - Part 1",
      "description": "เรียนรู้คำศัพท์ที่ใช้บ่อยในชีวิตประจำวัน",
      "level": "N5",
      "language": "JP",
      "questions": [
        {
          "question": "คำว่า 'こんにちは' หมายถึงอะไร?",
          "options": ["สวัสดี", "ขอบคุณ", "ขอโทษ", "ลาก่อน"],
          "correctAnswerIndex": 0,
          "explanation": "こんにちは (Konnichiwa) หมายถึง 'สวัสดี' ใช้ทักทายตอนกลางวัน",
          "type": "multipleChoice"
        }
      ]
    }
  ]
}
```

---

## 📚 แหล่งข้อมูลที่แนะนำสำหรับ Hackathon

### **1. Jisho API** (แนะนำมากที่สุด)
- URL: `https://jisho.org/api/v1/search/words?keyword=`
- ฟรี 100% ไม่จำกัด
- ข้อมูล: คำศัพท์, การอ่าน, ความหมาย, ตัวอย่างประโยค

### **2. GitHub: Frequency Words**
- URL: `https://github.com/hermitdave/FrequencyWords`
- ฟรี 100%
- ข้อมูล: คำศัพท์ที่ใช้บ่อย 50,000 คำ (JP, EN, CN, KR)

### **3. GitHub: JMdict**
- URL: `https://github.com/scriptin/jmdict-simplified`
- License: CC-BY-SA 3.0
- ข้อมูล: คำศัพท์ภาษาญี่ปุ่นมากกว่า 200,000 คำ

### **4. Tatoeba API**
- URL: `https://tatoeba.org/eng/api_v0/`
- License: CC-BY 2.0
- ข้อมูล: ตัวอย่างประโยคหลายภาษา

---

## 💡 Tips สำหรับ Hackathon

1. **ใช้ Jisho API** - ง่ายที่สุด, ฟรี, ไม่จำกัด
2. **Cache ข้อมูล** - เก็บข้อมูลใน JSON files เพื่อ offline use
3. **ใช้ Gemini API** - สร้างบทเรียนอัตโนมัติ (มี free tier)
4. **Combine Sources** - ใช้หลายแหล่งข้อมูลร่วมกัน

---

## 🔧 Implementation Example

ดูไฟล์ `lib/services/vocabulary_api_service.dart` สำหรับตัวอย่างการใช้งาน APIs ฟรี
