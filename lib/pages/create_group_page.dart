// lib/pages/create_group_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_group.dart';
import '../services/community_service.dart';
import '../user_data.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _communityService = CommunityService();
  
  String _selectedLanguage = UserData.targetLanguage.value;
  int _maxMembers = 100;
  bool _isPublic = true;
  bool _isLoading = false;
  List<String> _tags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('กรุณาล็อคอินก่อนสร้างกลุ่ม', style: GoogleFonts.kanit()),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final group = await _communityService.createGroup(
        creatorId: user.uid,
        creatorName: UserData.name.value,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        language: _selectedLanguage,
        maxMembers: _maxMembers,
        isPublic: _isPublic,
        tags: _tags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สร้างกลุ่มสำเร็จ!', style: GoogleFonts.kanit()),
            backgroundColor: const Color(0xFF58CC02),
          ),
        );
        Navigator.pop(context, group);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'สร้างกลุ่มใหม่',
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                'ชื่อกลุ่ม',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'กรุณากรอกชื่อกลุ่ม',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.kanit(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อกลุ่ม';
                  }
                  if (value.trim().length < 3) {
                    return 'ชื่อกลุ่มต้องมีอย่างน้อย 3 ตัวอักษร';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'คำอธิบาย',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'อธิบายเกี่ยวกับกลุ่มนี้...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.kanit(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกคำอธิบาย';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Language
              Text(
                'ภาษา',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: UserData.targetLanguage,
                builder: (context, currentLang, _) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ['JP', 'EN', 'CN', 'KR'].map((lang) {
                      final isSelected = _selectedLanguage == lang;
                      final langName = UserData.targetLanguageToThaiName(lang);
                      final langFlag = lang == 'JP' ? '🇯🇵' : lang == 'EN' ? '🇬🇧' : lang == 'CN' ? '🇨🇳' : '🇰🇷';
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLanguage = lang),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF58CC02) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(langFlag, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                langName,
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Tags
              Text(
                'แท็ก (Topics)',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: 'เพิ่มแท็ก (กด Enter)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.kanit(),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF58CC02)),
                    onPressed: _addTag,
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag, style: GoogleFonts.kanit(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: const Color(0xFF58CC02).withValues(alpha: 0.1),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),

              // Max Members
              Text(
                'จำนวนสมาชิกสูงสุด',
                style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _maxMembers.toDouble(),
                      min: 10,
                      max: 500,
                      divisions: 49,
                      label: '$_maxMembers คน',
                      onChanged: (value) => setState(() => _maxMembers = value.toInt()),
                    ),
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_maxMembers',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Public/Private
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'กลุ่มสาธารณะ',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ทุกคนสามารถเข้าร่วมได้',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (value) => setState(() => _isPublic = value),
                      activeColor: const Color(0xFF58CC02),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'สร้างกลุ่ม',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

