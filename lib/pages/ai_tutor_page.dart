import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../config/api_config.dart';
import '../user_data.dart';

class AITutorPage extends StatefulWidget {
  const AITutorPage({super.key});

  @override
  State<AITutorPage> createState() => _AITutorPageState();
}

class _AITutorPageState extends State<AITutorPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final VoiceService _voiceService = VoiceService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  
  List<Map<String, dynamic>> _getInitialMessages() {
    final targetLang = UserData.targetLanguage.value;
    final langName = UserData.targetLanguageToThaiName(targetLang);
    return [
      {
        'sender': 'ai',
        'text': 'สวัสดีครับ! 👋 \nวันนี้อยากฝึกแต่งประโยค$langName หรือให้ผมช่วยแปลคำไหนบอกได้เลยนะครับ!',
        'time': _getCurrentTime(),
      },
    ];
  }
  
  late List<Map<String, dynamic>> _messages = _getInitialMessages();
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isPlayingVoice = false;
  String? _currentRecordingPath;
  String _streamingText = ''; // สำหรับเก็บข้อความที่กำลัง stream

  @override
  void initState() {
    super.initState();
    _messages = _getInitialMessages();
    // อัปเดตข้อความเริ่มต้นเมื่อ targetLanguage เปลี่ยน
    UserData.targetLanguage.addListener(_updateInitialMessage);
    _checkApiConfiguration();
    _initializeSpeechToText();
  }

  void _updateInitialMessage() {
    if (_messages.isNotEmpty && _messages[0]['sender'] == 'ai') {
      setState(() {
        _messages[0] = _getInitialMessages()[0];
      });
    }
  }

  Future<void> _initializeSpeechToText() async {
    // ตรวจสอบว่า Speech-to-Text พร้อมใช้งานหรือไม่
    final available = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech-to-Text error: $error');
      },
      onStatus: (status) {
        debugPrint('Speech-to-Text status: $status');
      },
    );
    
    if (!available) {
      debugPrint('Speech-to-Text ไม่พร้อมใช้งาน');
    }
  }

  void _checkApiConfiguration() {
    if (!_aiService.isConfigured || !_voiceService.isConfigured) {
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
                'กรุณาตั้งค่า API Keys เพื่อใช้งาน AI Tutor และ Voice features',
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

  static String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': _getCurrentTime(),
      });
      _isLoading = true;
      _streamingText = ''; // รีเซ็ต streaming text
    });
    
    _controller.clear();
    
    int aiMessageIndex = _messages.length; // ประกาศนอก try block
    
    try {
      // สร้าง history จาก messages (ไม่รวมข้อความปัจจุบันที่เพิ่งเพิ่ม)
      // กรองเอาเฉพาะข้อความก่อนหน้านี้ (ไม่รวมข้อความแรกที่เป็น welcome message)
      final history = _messages
          .where((msg) => 
              msg['sender'] != 'ai' || 
              (msg['text'] != _messages.first['text'] && msg != _messages.last))
          .map((msg) => <String, String>{
                'sender': msg['sender'] as String,
                'text': msg['text'] as String,
              })
          .toList();
      
      // เพิ่ม AI message placeholder สำหรับ streaming
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': '', // เริ่มต้นด้วยข้อความว่าง
            'time': _getCurrentTime(),
          });
        });
      }
      
      // ใช้ Streaming API แทน
      await for (final chunk in _aiService.sendMessageStream(
        text,
        history: history,
        language: 'th',
      )) {
        if (mounted) {
          setState(() {
            _streamingText += chunk;
            // อัปเดตข้อความ AI แบบ realtime
            _messages[aiMessageIndex]['text'] = _streamingText;
          });
        }
      }
      
      // Streaming เสร็จแล้ว
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // เล่นเสียง AI response หลังจาก streaming เสร็จ
        await _playAIResponse(_streamingText);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // ถ้ามี error ให้แสดง error message
          if (aiMessageIndex < _messages.length) {
            _messages[aiMessageIndex]['text'] = 'ขอโทษครับ มีปัญหาในการเชื่อมต่อ AI กรุณาลองใหม่อีกครั้ง\n\nError: $e';
          } else {
            _messages.add({
              'sender': 'ai',
              'text': 'ขอโทษครับ มีปัญหาในการเชื่อมต่อ AI กรุณาลองใหม่อีกครั้ง\n\nError: $e',
              'time': _getCurrentTime(),
            });
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAIResponse(String text) async {
    if (!_voiceService.isConfigured) {
      debugPrint('Voice service not configured');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice service ไม่ได้ตั้งค่า กรุณาตรวจสอบ API Key', style: GoogleFonts.kanit()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    if (text.isEmpty) {
      debugPrint('Text is empty, skipping voice playback');
      return;
    }
    
    try {
      if (mounted) {
        setState(() => _isPlayingVoice = true);
      }
      
      debugPrint('Playing AI response: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      await _voiceService.speak(text, language: 'th');
      debugPrint('Voice playback completed');
    } catch (e) {
      debugPrint('Voice playback error: $e');
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
        setState(() => _isPlayingVoice = false);
      }
    }
  }

  Future<void> _startListening() async {
    try {
      // ขอ permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ต้องการ permission ในการใช้ microphone', style: GoogleFonts.kanit()),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ใช้ Speech-to-Text สำหรับ real-time recognition
      if (await _speechToText.initialize()) {
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              // เมื่อผู้ใช้พูดเสร็จ ให้ส่งข้อความไปยัง AI
              final text = result.recognizedWords.trim();
              if (text.isNotEmpty) {
                _sendMessage(text);
              }
              
              // หยุด listening
              _speechToText.stop();
              if (mounted) {
                setState(() {
                  _isListening = false;
                });
              }
            }
          },
          listenFor: const Duration(seconds: 30), // ฟังได้สูงสุด 30 วินาที
          pauseFor: const Duration(seconds: 3), // หยุดฟังหลังจากเงียบ 3 วินาที
          localeId: 'th_TH', // ใช้ภาษาไทย
        );
        
        if (mounted) {
          setState(() {
            _isListening = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech-to-Text ไม่พร้อมใช้งาน', style: GoogleFonts.kanit()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึกเสียง: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return; // ถ้ายังไม่ได้เริ่ม listening ไม่ต้อง stop
    
    try {
      await _speechToText.stop();
      
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      debugPrint('Stop listening error: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการหยุดฟัง: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    UserData.targetLanguage.removeListener(_updateInitialMessage);
    _controller.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _speechToText.stop();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-scroll เมื่อมีข้อความใหม่
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
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
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCE82FF), Color(0xFF9B59B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCE82FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Sensei",
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B3445),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.orange : const Color(0xFF58CC02),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isLoading ? Colors.orange : const Color(0xFF58CC02)).withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isLoading ? 'กำลังพิมพ์...' : 'Online',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: _isLoading ? Colors.orange : const Color(0xFF58CC02),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_isPlayingVoice)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volume_up, color: Colors.blue, size: 20),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1000.ms, color: Colors.blue.withValues(alpha: 0.3)),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Chat Area with Auto-scroll
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _messages.length + (_isLoading && _streamingText.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading && _streamingText.isEmpty) {
                  // Typing indicator
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return _buildChatBubble(
                  msg['text'] as String,
                  msg['time'] as String,
                  isUser,
                  index,
                );
              },
            ),
          ),

          // 2. Quick Suggestions
          if (!_isLoading && !_isListening)
            ValueListenableBuilder<String>(
              valueListenable: UserData.targetLanguage,
              builder: (context, targetLang, _) {
                final langFlag = targetLang == 'JP' ? '🇯🇵' : targetLang == 'EN' ? '🇬🇧' : targetLang == 'CN' ? '🇨🇳' : '🇰🇷';
                final langName = UserData.targetLanguageToThaiName(targetLang);
                return Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionChip("✨ ช่วยแก้ประโยค", 0),
                      const SizedBox(width: 8),
                      _buildSuggestionChip("$langFlag แปลเป็น$langName", 1),
                      const SizedBox(width: 8),
                      _buildSuggestionChip("🗣️ ฝึกออกเสียง", 2),
                    ],
                  ),
                );
              },
            ),

          // 3. Listening Indicator
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'กำลังฟัง... พูดได้เลย',
                    style: GoogleFonts.kanit(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 300.ms)
                .then()
                .shimmer(duration: 1000.ms),

          // 4. Input Bar
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, String time, bool isUser, int index) {
    if (text.isEmpty && !isUser) {
      // Empty AI message (streaming placeholder)
      return _buildTypingIndicator();
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isUser ? 40 : 0,
          right: isUser ? 0 : 40,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF1CB0F6), Color(0xFF1882D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: (isUser ? const Color(0xFF1CB0F6) : Colors.black).withValues(alpha: isUser ? 0.2 : 0.05),
              blurRadius: isUser ? 8 : 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.kanit(
                color: isUser ? Colors.white : const Color(0xFF2B3445),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.kanit(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _playAIResponse(text),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: (index * 50).ms, curve: Curves.easeOut);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 0, right: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 400.ms, delay: (index * 200).ms)
        .then()
        .fadeOut(duration: 400.ms);
  }

  Widget _buildSuggestionChip(String label, int index) {
    return ActionChip(
      avatar: label.contains('✨') 
          ? const Icon(Icons.auto_fix_high, size: 16, color: Color(0xFF58CC02))
          : label.contains('🇯🇵')
              ? const Text('🇯🇵', style: TextStyle(fontSize: 16))
              : const Icon(Icons.mic, size: 16, color: Color(0xFF58CC02)),
      label: Text(
        label.replaceAll('✨ ', '').replaceAll('🇯🇵 ', '').replaceAll('🗣️ ', ''),
        style: GoogleFonts.kanit(
          fontSize: 13,
          color: const Color(0xFF58CC02),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: const Color(0xFF58CC02).withValues(alpha: 0.3), width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      onPressed: () => _sendMessage(label),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideX(begin: 0.2, end: 0, duration: 300.ms, delay: (index * 100).ms);
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          // Microphone Button
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            onTapCancel: () => _stopListening(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _isListening
                    ? LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      )
                    : null,
                color: _isListening ? null : Colors.grey.shade100,
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? Colors.white : Colors.grey.shade600,
                size: 22,
              ),
            )
                .animate(target: _isListening ? 1 : 0)
                .scale(duration: 200.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1))
                .then()
                .scale(duration: 200.ms, begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _isListening 
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.kanit(fontSize: 15),
                enabled: !_isLoading && !_isListening,
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? "กำลังฟัง..."
                      : _isLoading
                          ? "AI กำลังพิมพ์..."
                          : "พิมพ์ข้อความ...",
                  hintStyle: GoogleFonts.kanit(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty && !_isLoading) {
                    _sendMessage(text.trim());
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: (_isLoading || _controller.text.trim().isEmpty)
                ? null
                : () => _sendMessage(_controller.text.trim()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: (_isLoading || _controller.text.trim().isEmpty)
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: (_isLoading || _controller.text.trim().isEmpty)
                    ? Colors.grey.shade300
                    : null,
                shape: BoxShape.circle,
                boxShadow: (_isLoading || _controller.text.trim().isEmpty)
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF58CC02).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
