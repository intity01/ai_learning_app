import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../app_strings.dart';

class AddVocabularyPage extends StatefulWidget {
  const AddVocabularyPage({super.key});

  @override
  State<AddVocabularyPage> createState() => _AddVocabularyPageState();
}

class _AddVocabularyPageState extends State<AddVocabularyPage> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _romajiController = TextEditingController();
  final _tagController = TextEditingController();

  void _saveVocab() {
    // Validation
    if (_wordController.text.trim().isEmpty || _meaningController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกคำศัพท์และคำแปล', style: GoogleFonts.kanit()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // บันทึกคำศัพท์
      UserData.addVocabulary(
        _wordController.text.trim(),
        _meaningController.text.trim(),
        _romajiController.text.trim().isEmpty ? '-' : _romajiController.text.trim(),
        _tagController.text.trim().isEmpty ? 'General' : _tagController.text.trim(),
      );

      // ปิดหน้าและแสดงข้อความสำเร็จ
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกสำเร็จ!', style: GoogleFonts.kanit()),
          backgroundColor: const Color(0xFF58CC02),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: ValueListenableBuilder(
          valueListenable: UserData.appLanguage,
          builder: (context, _, __) => Text(AppStrings.t('add_new_vocabulary'), style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.targetLanguage,
                    builder: (context, targetLang, _) {
                      final langName = UserData.targetLanguageToThaiName(targetLang);
                      return _buildLabel("คำศัพท์ ($langName)");
                    },
                  ),
                  _buildInput(_wordController, "เช่น 猫, Apple", Icons.abc),
                  const SizedBox(height: 20),
                  _buildLabel("คำอ่าน (Romaji)"),
                  _buildInput(_romajiController, "เช่น Neko, เนโกะ", Icons.record_voice_over_rounded),
                  const SizedBox(height: 20),
                  _buildLabel("คำแปล"),
                  _buildInput(_meaningController, "เช่น แมว", Icons.translate_rounded),
                  const SizedBox(height: 20),
                  _buildLabel("หมวดหมู่ (Tag)"),
                  _buildInput(_tagController, "เช่น สัตว์, ผลไม้", Icons.label_outline_rounded),
                ],
              ),
            ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveVocab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: const Color(0xFF58CC02).withValues(alpha: 0.5),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ).animate().fade(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.kanit(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}