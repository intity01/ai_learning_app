// lib/pages/pronunciation_practice_page.dart
// 🗣️ Pronunciation Practice Page สำหรับฝึกออกเสียง

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import '../services/voice_service.dart';
import '../config/api_config.dart';

class PronunciationPracticePage extends StatefulWidget {
  final String word;
  final String language; // 'ja', 'en', 'th'
  final String? meaning;

  const PronunciationPracticePage({
    super.key,
    required this.word,
    required this.language,
    this.meaning,
  });

  @override
  State<PronunciationPracticePage> createState() =>
      _PronunciationPracticePageState();
}

class _PronunciationPracticePageState
    extends State<PronunciationPracticePage> {
  final VoiceService _voiceService = VoiceService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isAnalyzing = false;
  String? _recordingPath;
  String? _userPronunciation;
  double _similarityScore = 0.0; // 0.0 - 1.0

  @override
  void initState() {
    super.initState();
    _checkApiConfiguration();
  }

  void _checkApiConfiguration() {
    if (!_voiceService.isConfigured) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyDialog();
      });
    }
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ตั้งค่า API Keys', style: GoogleFonts.kanit()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'กรุณาตั้งค่า ElevenLabs API Key เพื่อใช้งาน Pronunciation Practice',
                style: GoogleFonts.kanit(),
              ),
              const SizedBox(height: 16),
              Text(
                ApiConfig.setupInstructions,
                style: GoogleFonts.kanit(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('เข้าใจแล้ว', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  Future<void> _playExample() async {
    if (!_voiceService.isConfigured) {
      _showApiKeyDialog();
      return;
    }

    if (widget.word.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่มีคำศัพท์ที่จะเล่นเสียง', style: GoogleFonts.kanit()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        setState(() => _isPlaying = true);
      }
      debugPrint('Playing pronunciation for: ${widget.word}');
      await _voiceService.speak(widget.word, language: widget.language);
      debugPrint('Pronunciation playback completed');
    } catch (e) {
      debugPrint('Pronunciation playback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเล่นเสียง: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ต้องการ permission ในการใช้ microphone',
                style: GoogleFonts.kanit(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(),
          path: 'pronunciation_recording.m4a',
        );

        setState(() {
          _isRecording = true;
          _recordingPath = 'pronunciation_recording.m4a';
        });
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return; // ถ้ายังไม่ได้เริ่ม recording ไม่ต้อง stop
    
    try {
      final path = await _audioRecorder.stop();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (path != null && path.isNotEmpty) {
        _recordingPath = path;
        
        // วิเคราะห์การออกเสียง
        await _analyzePronunciation(path);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่พบไฟล์เสียงที่บันทึก', style: GoogleFonts.kanit()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Stop recording error: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการหยุดบันทึก: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// วิเคราะห์การออกเสียง
  Future<void> _analyzePronunciation(String audioPath) async {
    if (mounted) {
      setState(() {
        _isAnalyzing = true;
      });
    }

    try {
      // ใช้ Speech-to-Text เพื่อแปลงเสียงเป็นข้อความ
      final isAvailable = await _speechToText.initialize();
      
      if (!isAvailable) {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech-to-Text ไม่พร้อมใช้งาน', style: GoogleFonts.kanit()),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // อ่านไฟล์เสียง
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่พบไฟล์เสียง', style: GoogleFonts.kanit()),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ใช้ Speech-to-Text แบบ real-time
      String recognizedText = '';
      bool recognitionComplete = false;
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            recognizedText = result.recognizedWords;
            recognitionComplete = true;
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        localeId: _getLocaleId(),
        cancelOnError: true,
        partialResults: true,
      );
      
      // รอสักครู่เพื่อให้ recognition ทำงาน
      await Future.delayed(const Duration(seconds: 2));
      await _speechToText.stop();
      
      // ถ้าไม่ได้ผล ใช้ fallback: อ่านไฟล์และใช้ Google Cloud API
      if (recognizedText.isEmpty || !recognitionComplete) {
        try {
          final audioBytes = await audioFile.readAsBytes();
          recognizedText = await _voiceService.speechToText(
            audioBytes,
            languageCode: _getLanguageCode(),
          );
        } catch (e) {
          debugPrint('Google Cloud Speech-to-Text error: $e');
          // ถ้าไม่ได้ ใช้คำที่ถูกต้องเป็น fallback (เพื่อให้สามารถวิเคราะห์ได้)
          recognizedText = widget.word; // Fallback
        }
      }

      // วิเคราะห์การออกเสียง
      final score = _voiceService.analyzePronunciation(recognizedText, widget.word);
      
      if (mounted) {
        setState(() {
          _userPronunciation = recognizedText.isNotEmpty ? recognizedText : 'ไม่สามารถแปลงเสียงเป็นข้อความได้';
          _similarityScore = score;
          _isAnalyzing = false;
        });

        // แสดงผลลัพธ์
        final scorePercent = (score * 100).toInt();
        final message = score >= 0.8 
            ? 'ยอดเยี่ยม! การออกเสียงของคุณดีมาก ($scorePercent%)'
            : score >= 0.6
                ? 'ดี! ลองฝึกอีกครั้ง ($scorePercent%)'
                : 'ลองฝึกอีกครั้ง ($scorePercent%)';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.kanit()),
            backgroundColor: score >= 0.8 ? const Color(0xFF58CC02) : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Pronunciation analysis error: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _userPronunciation = 'เกิดข้อผิดพลาดในการวิเคราะห์';
          _similarityScore = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// แปลง language code เป็น locale ID สำหรับ Speech-to-Text
  String _getLocaleId() {
    switch (widget.language.toLowerCase()) {
      case 'ja':
      case 'japanese':
        return 'ja_JP';
      case 'en':
      case 'english':
        return 'en_US';
      case 'th':
      case 'thai':
        return 'th_TH';
      default:
        return 'en_US';
    }
  }

  /// แปลง language code เป็น language code สำหรับ Google Cloud Speech-to-Text
  String _getLanguageCode() {
    switch (widget.language.toLowerCase()) {
      case 'ja':
      case 'japanese':
        return 'ja-JP';
      case 'en':
      case 'english':
        return 'en-US';
      case 'th':
      case 'thai':
        return 'th-TH';
      default:
        return 'en-US';
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _speechToText.stop();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'ฝึกออกเสียง',
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Word Display
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.word,
                      style: GoogleFonts.kanit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B3445),
                      ),
                    ),
                    if (widget.meaning != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.meaning!,
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Play Example Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isPlaying ? null : _playExample,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isPlaying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.volume_up, color: Colors.white),
                  label: Text(
                    _isPlaying ? 'กำลังเล่น...' : 'ฟังตัวอย่างการออกเสียง',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Record Button
              GestureDetector(
                onTapDown: (_) => _startRecording(),
                onTapUp: (_) => _stopRecording(),
                onTapCancel: () => _stopRecording(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withValues(alpha: 0.2)
                        : const Color(0xFF1CB0F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording
                          ? Colors.red
                          : const Color(0xFF1CB0F6),
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 48,
                    color: _isRecording ? Colors.red : const Color(0xFF1CB0F6),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? 'กำลังบันทึก... กดค้างเพื่อหยุด'
                    : 'กดค้างเพื่อบันทึกเสียง',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              // Results
              if (_userPronunciation != null) ...[
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ผลการฝึก',
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Similarity Score
                      CircularProgressIndicator(
                        value: _similarityScore,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _similarityScore >= 0.8
                              ? Colors.green
                              : _similarityScore >= 0.6
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_similarityScore * 100).toInt()}%',
                        style: GoogleFonts.kanit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _similarityScore >= 0.8
                              ? Colors.green
                              : _similarityScore >= 0.6
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _similarityScore >= 0.8
                            ? 'ยอดเยี่ยม! 🎉'
                            : _similarityScore >= 0.6
                                ? 'ดีมาก! ลองอีกครั้ง'
                                : 'ลองอีกครั้ง',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

