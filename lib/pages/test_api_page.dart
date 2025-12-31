// lib/pages/test_api_page.dart
// หน้า UI สำหรับทดสอบ API และสร้างบทเรียนอัตโนมัติ
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/vocabulary_api_service.dart';
import '../services/auto_lesson_generator.dart';
import 'dart:convert';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _testResult = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _generatedLessons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('ทดสอบ API & สร้างบทเรียน', style: GoogleFonts.kanit()),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ปุ่มทดสอบ APIs
            _buildSection(
              title: 'ทดสอบ APIs',
              children: [
                _buildButton(
                  'ทดสอบ Jisho API',
                  Icons.search,
                  Colors.blue,
                  _testJishoAPI,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  'ทดสอบ Frequency Words',
                  Icons.book,
                  Colors.green,
                  _testFrequencyWords,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  'ทดสอบ Tatoeba API',
                  Icons.translate,
                  Colors.purple,
                  _testTatoebaAPI,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // ปุ่มสร้างบทเรียน
            _buildSection(
              title: 'สร้างบทเรียนอัตโนมัติ',
              children: [
                _buildButton(
                  'สร้างบทเรียนจากคำศัพท์ที่ใช้บ่อย',
                  Icons.auto_awesome,
                  Colors.orange,
                  _generateLessonFromCommonWords,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  'สร้างบทเรียนหลายบท',
                  Icons.library_books,
                  Colors.teal,
                  _generateMultipleLessons,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // ผลลัพธ์
            if (_testResult.isNotEmpty || _isLoading)
              _buildResultSection(),
            
            // แสดงบทเรียนที่สร้าง
            if (_generatedLessons.isNotEmpty)
              _buildLessonsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(label, style: GoogleFonts.kanit()),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ผลลัพธ์',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Text(
              _testResult,
              style: GoogleFonts.kanit(fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'บทเรียนที่สร้าง (${_generatedLessons.length} บท)',
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        const SizedBox(height: 12),
        ..._generatedLessons.map((lesson) => _buildLessonCard(lesson)),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    final questions = lesson['questions'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson['title'] ?? 'Untitled',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'คำถาม: ${questions.length} ข้อ',
            style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showLessonDetails(lesson),
            child: Text('ดูรายละเอียด', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showLessonDetails(Map<String, dynamic> lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson['title'] ?? 'Lesson', style: GoogleFonts.kanit()),
        content: SingleChildScrollView(
          child: Text(
            const JsonEncoder.withIndent('  ').convert(lesson),
            style: GoogleFonts.kanit(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Future<void> _testJishoAPI() async {
    setState(() {
      _isLoading = true;
      _testResult = 'กำลังทดสอบ Jisho API...\n';
    });

    try {
      final wordData = await VocabularyApiService.searchJapaneseWord('こんにちは');
      
      if (wordData != null) {
        final japanese = wordData['japanese']?[0];
        final senses = wordData['senses']?[0];
        
        setState(() {
          _testResult = '''
✅ ทดสอบ Jisho API สำเร็จ!

คำ: こんにちは
Kanji: ${japanese?['word'] ?? 'N/A'}
Reading: ${japanese?['reading'] ?? 'N/A'}
Meaning: ${senses?['english_definitions']?[0] ?? 'N/A'}
''';
          _isLoading = false;
        });
      } else {
        setState(() {
          _testResult = '❌ ไม่พบข้อมูล';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFrequencyWords() async {
    setState(() {
      _isLoading = true;
      _testResult = 'กำลังดึงคำศัพท์ที่ใช้บ่อย...\n';
    });

    try {
      final words = await VocabularyApiService.fetchCommonWords('JP');
      
      setState(() {
        _testResult = '''
✅ ดึงคำศัพท์สำเร็จ!

จำนวนคำ: ${words.length}
10 คำแรก:
${words.take(10).map((w) => '  - $w').join('\n')}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testTatoebaAPI() async {
    setState(() {
      _isLoading = true;
      _testResult = 'กำลังทดสอบ Tatoeba API...\n';
    });

    try {
      final sentences = await VocabularyApiService.fetchExampleSentences(
        fromLang: 'jpn',
        toLang: 'eng',
        query: 'こんにちは',
        limit: 5,
      );
      
      setState(() {
        _testResult = '''
✅ ทดสอบ Tatoeba API สำเร็จ!

พบตัวอย่างประโยค: ${sentences.length} ข้อ
${sentences.take(3).map((s) => '  - ${s['text']}').join('\n')}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateLessonFromCommonWords() async {
    setState(() {
      _isLoading = true;
      _testResult = 'กำลังสร้างบทเรียน...\n';
    });

    try {
      final lesson = await AutoLessonGenerator.generateLessonFromCommonWords(
        language: 'JP',
        level: 'N5',
        topic: 'คำศัพท์ที่ใช้บ่อย - Auto Generated',
        wordCount: 10,
      );

      setState(() {
        final questions = lesson['questions'] as List? ?? [];
        _testResult = '''
✅ สร้างบทเรียนสำเร็จ!

หัวข้อ: ${lesson['title']}
จำนวนคำถาม: ${questions.length}
''';
        _generatedLessons = [lesson];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateMultipleLessons() async {
    setState(() {
      _isLoading = true;
      _testResult = 'กำลังสร้างบทเรียนหลายบท...\n';
    });

    try {
      final lessons = await AutoLessonGenerator.generateMultipleLessons(
        language: 'JP',
        level: 'N5',
        topics: [
          'คำทักทาย',
          'ตัวเลข',
          'สี',
        ],
        wordsPerLesson: 5,
      );

      setState(() {
        _testResult = '''
✅ สร้างบทเรียนสำเร็จ!

จำนวนบทเรียน: ${lessons.length}
${lessons.map((l) => '  - ${l['title']} (${(l['questions'] as List).length} คำถาม)').join('\n')}
''';
        _generatedLessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }
}


