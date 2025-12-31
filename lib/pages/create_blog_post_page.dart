// lib/pages/create_blog_post_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blog_post.dart';
import '../user_data.dart';
import '../services/blog_service.dart';

class CreateBlogPostPage extends StatefulWidget {
  const CreateBlogPostPage({super.key});

  @override
  State<CreateBlogPostPage> createState() => _CreateBlogPostPageState();
}

class _CreateBlogPostPageState extends State<CreateBlogPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final BlogService _blogService = BlogService();
  
  List<String> _tags = [];
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final post = BlogPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: UserData.name.value,
        authorName: UserData.name.value,
        authorAvatarUrl: UserData.currentAvatarUrl,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _imageUrl,
        tags: _tags,
        targetLanguage: UserData.targetLanguage.value,
        createdAt: DateTime.now(),
      );

      await _blogService.createPost(post);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('โพสต์สำเร็จ!', style: GoogleFonts.kanit()),
            backgroundColor: const Color(0xFF58CC02),
          ),
        );
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
          'สร้างโพสต์',
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: Text(
              'โพสต์',
              style: GoogleFonts.kanit(
                color: _isLoading ? Colors.grey : const Color(0xFF58CC02),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(UserData.currentAvatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          UserData.name.value,
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'หัวข้อ',
                        hintText: 'เขียนหัวข้อที่น่าสนใจ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาใส่หัวข้อ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Content
                    TextFormField(
                      controller: _contentController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'เนื้อหา',
                        hintText: 'เขียนเนื้อหาของคุณ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: GoogleFonts.kanit(fontSize: 14),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาใส่เนื้อหา';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    TextFormField(
                      onChanged: (value) => setState(() => _imageUrl = value.trim().isEmpty ? null : value.trim()),
                      decoration: InputDecoration(
                        labelText: 'URL รูปภาพ (ไม่บังคับ)',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.image_outlined),
                      ),
                      style: GoogleFonts.kanit(fontSize: 14),
                    ),
                    if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Tags
                    Text(
                      'แท็ก',
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'เพิ่มแท็ก...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.kanit(fontSize: 14),
                            onFieldSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add_circle, color: Color(0xFF58CC02)),
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
                            onDeleted: () => _removeTag(tag),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            backgroundColor: Colors.blue.shade50,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

