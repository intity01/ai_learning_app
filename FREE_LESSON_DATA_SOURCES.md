# แหล่งข้อมูลบทเรียนฟรีสำหรับแอป Language Learning

## 📚 แหล่งข้อมูลฟรีที่แนะนำ

### 1. **GitHub Repositories** (แนะนำมากที่สุด)

#### 1.1 **Japanese Language Learning Data**
- **jisho.org API** - API ฟรีสำหรับค้นหาคำศัพท์ภาษาญี่ปุ่น
  - URL: `https://jisho.org/api/v1/search/words?keyword=`
  - License: Free to use
  - ข้อมูล: คำศัพท์, การอ่าน, ความหมาย, ตัวอย่างประโยค

- **Japanese Vocabulary Lists (GitHub)**
  - Repository: `https://github.com/scriptin/jmdict-simplified`
  - License: CC-BY-SA 3.0
  - ข้อมูล: คำศัพท์ภาษาญี่ปุ่นมากกว่า 200,000 คำ

- **JLPT Vocabulary Lists**
  - Repository: `https://github.com/scriptin/jmdict-simplified`
  - ข้อมูล: คำศัพท์แบ่งตามระดับ N5-N1

#### 1.2 **English Language Learning Data**
- **WordNet** - Database คำศัพท์ภาษาอังกฤษ
  - URL: `https://wordnet.princeton.edu/`
  - License: Free for research/education
  - ข้อมูล: คำศัพท์, ความหมาย, ความสัมพันธ์ระหว่างคำ

- **Oxford Dictionaries API** (มี free tier)
  - URL: `https://developer.oxforddictionaries.com/`
  - Free tier: 3,000 requests/month
  - ข้อมูล: คำศัพท์, ความหมาย, ตัวอย่างประโยค, การออกเสียง

#### 1.3 **Chinese Language Learning Data**
- **CC-CEDICT** - Chinese-English Dictionary
  - Repository: `https://github.com/mozilla/cc-cedict`
  - License: CC-BY-SA 3.0
  - ข้อมูล: คำศัพท์จีน-อังกฤษมากกว่า 100,000 คำ

- **HSK Vocabulary Lists**
  - Repository: `https://github.com/lazywinadmin/HSK`
  - ข้อมูล: คำศัพท์แบ่งตามระดับ HSK 1-6

#### 1.4 **Korean Language Learning Data**
- **Korean Vocabulary Lists**
  - Repository: `https://github.com/garfieldnate/kengdic`
  - License: CC-BY-SA 3.0
  - ข้อมูล: คำศัพท์เกาหลี-อังกฤษ

- **TOPIK Vocabulary Lists**
  - Repository: `https://github.com/garfieldnate/kengdic`
  - ข้อมูล: คำศัพท์แบ่งตามระดับ TOPIK

### 2. **Open Datasets**

#### 2.1 **Tatoeba** - ตัวอย่างประโยคหลายภาษา
- URL: `https://tatoeba.org/`
- License: CC-BY 2.0
- ข้อมูล: ตัวอย่างประโยคหลายภาษา (JP, EN, CN, KR, TH)
- API: `https://tatoeba.org/eng/api_v0/`

#### 2.2 **OpenSubtitles** - บทสนทนาจากหนัง/ซีรี่ส์
- URL: `https://www.opensubtitles.org/`
- License: Various (ต้องตรวจสอบ)
- ข้อมูล: บทสนทนาจากหนัง/ซีรี่ส์หลายภาษา

#### 2.3 **Common Voice (Mozilla)** - ข้อมูลเสียงพูด
- URL: `https://commonvoice.mozilla.org/`
- License: CC-0
- ข้อมูล: ข้อมูลเสียงพูดหลายภาษา

### 3. **Free APIs**

#### 3.1 **Jisho API** (Japanese)
```dart
// ตัวอย่างการใช้งาน
Future<Map<String, dynamic>> fetchJapaneseWord(String word) async {
  final response = await http.get(
    Uri.parse('https://jisho.org/api/v1/search/words?keyword=$word')
  );
  return json.decode(response.body);
}
```

#### 3.2 **Tatoeba API**
```dart
// ดึงตัวอย่างประโยค
Future<List<Map<String, dynamic>>> fetchExampleSentences(String lang) async {
  final response = await http.get(
    Uri.parse('https://tatoeba.org/eng/api_v0/search?from=$lang&to=eng&query=hello')
  );
  return json.decode(response.body)['results'];
}
```

#### 3.3 **WordsAPI** (English)
- URL: `https://www.wordsapi.com/`
- Free tier: 2,500 requests/day
- ข้อมูล: คำศัพท์, ความหมาย, ตัวอย่างประโยค, คำพ้องความหมาย

### 4. **GitHub Repositories ที่แนะนำ**

#### 4.1 **Language Learning Data Collections**
- `https://github.com/hermitdave/FrequencyWords` - คำศัพท์ที่ใช้บ่อยในแต่ละภาษา
- `https://github.com/words/an-array-of-english-words` - รายการคำศัพท์ภาษาอังกฤษ
- `https://github.com/kanjivg/kanjivg` - ข้อมูล Kanji ภาษาญี่ปุ่น

#### 4.2 **Vocabulary Lists**
- `https://github.com/scriptin/jmdict-simplified` - Japanese Dictionary
- `https://github.com/mozilla/cc-cedict` - Chinese Dictionary
- `https://github.com/garfieldnate/kengdic` - Korean Dictionary

### 5. **วิธีนำข้อมูลมาใช้**

#### 5.1 **สร้าง JSON File สำหรับบทเรียน**
```json
{
  "lessons": [
    {
      "id": 1,
      "title": "พื้นฐานการทักทาย",
      "description": "เรียนรู้คำทักทายพื้นฐาน",
      "level": "Beginner",
      "language": "JP",
      "questions": [
        {
          "question": "คำว่า 'สวัสดี' ในภาษาญี่ปุ่นคืออะไร?",
          "options": ["こんにちは", "ありがとう", "すみません", "さようなら"],
          "correctAnswerIndex": 0,
          "explanation": "こんにちは (Konnichiwa) หมายถึง สวัสดี",
          "type": "multipleChoice"
        }
      ]
    }
  ]
}
```

#### 5.2 **ใช้ API แบบ Real-time**
```dart
// lib/services/vocabulary_api_service.dart
class VocabularyApiService {
  static Future<List<Map<String, dynamic>>> fetchJapaneseVocabulary(String level) async {
    // ใช้ Jisho API หรือ GitHub data
  }
  
  static Future<List<Map<String, dynamic>>> fetchExampleSentences(String word, String lang) async {
    // ใช้ Tatoeba API
  }
}
```

### 6. **ตัวอย่างการใช้งาน**

#### 6.1 **โหลดข้อมูลจาก GitHub**
```dart
Future<List<String>> loadVocabularyFromGitHub() async {
  final response = await http.get(
    Uri.parse('https://raw.githubusercontent.com/user/repo/main/vocabulary.json')
  );
  final data = json.decode(response.body);
  return List<String>.from(data['words']);
}
```

#### 6.2 **ใช้ Jisho API สำหรับคำศัพท์**
```dart
Future<Map<String, dynamic>> searchJapaneseWord(String word) async {
  final response = await http.get(
    Uri.parse('https://jisho.org/api/v1/search/words?keyword=$word')
  );
  final data = json.decode(response.body);
  return data['data'][0]; // แสดงผลลัพธ์แรก
}
```

### 7. **คำแนะนำสำหรับ Hackathon**

#### 7.1 **ใช้ข้อมูลจาก GitHub (แนะนำ)**
- ง่ายที่สุด: Clone repository และใช้ JSON files
- ไม่ต้องมี API key
- ใช้ได้ทันที

#### 7.2 **ใช้ Free APIs**
- Jisho API - สำหรับภาษาญี่ปุ่น (ไม่มี rate limit)
- Tatoeba API - สำหรับตัวอย่างประโยค
- WordsAPI - สำหรับภาษาอังกฤษ (มี free tier)

#### 7.3 **สร้างข้อมูลเองด้วย AI**
- ใช้ Gemini API (มี free tier)
- สร้างบทเรียนอัตโนมัติ
- สร้างคำถามอัตโนมัติ

### 8. **โครงสร้างข้อมูลที่แนะนำ**

```dart
// lib/models/lesson_content.dart
class LessonContent {
  final int id;
  final String title;
  final String description;
  final String level; // Beginner, Intermediate, Advanced
  final String language; // JP, EN, CN, KR
  final List<Question> questions;
  final List<Vocabulary> vocabulary;
  final List<String> grammarPoints;
  
  LessonContent({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.language,
    required this.questions,
    required this.vocabulary,
    required this.grammarPoints,
  });
}

class Vocabulary {
  final String word;
  final String reading; // สำหรับ JP/CN/KR
  final String meaning;
  final String exampleSentence;
  final String? audioUrl;
  
  Vocabulary({
    required this.word,
    required this.reading,
    required this.meaning,
    required this.exampleSentence,
    this.audioUrl,
  });
}
```

### 9. **Resources ที่แนะนำสำหรับ Hackathon**

1. **Jisho.org** - Japanese Dictionary API (ฟรี, ไม่จำกัด)
2. **Tatoeba** - Example Sentences (ฟรี, CC-BY)
3. **GitHub: jmdict-simplified** - Japanese Vocabulary (CC-BY-SA)
4. **GitHub: cc-cedict** - Chinese Dictionary (CC-BY-SA)
5. **WordsAPI** - English Dictionary (Free tier: 2,500/day)

### 10. **Next Steps**

1. เลือกแหล่งข้อมูลที่ต้องการ (แนะนำ: Jisho API + GitHub vocab lists)
2. สร้าง Service สำหรับดึงข้อมูล
3. แปลงข้อมูลเป็นรูปแบบที่แอปใช้ได้
4. เพิ่ม Caching เพื่อลด API calls
5. เพิ่ม Offline Support ด้วย JSON files

---

## 📝 หมายเหตุ

- **License**: ตรวจสอบ license ของแต่ละแหล่งข้อมูลก่อนใช้งาน
- **Rate Limits**: ตรวจสอบ rate limits ของ APIs
- **Caching**: ควร cache ข้อมูลเพื่อลด API calls
- **Offline Support**: เก็บข้อมูลใน JSON files สำหรับ offline use


