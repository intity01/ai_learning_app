// lib/pages/blog_feed_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/blog_post.dart';
import '../user_data.dart';
import '../services/blog_service.dart';
import 'create_blog_post_page.dart';

class BlogFeedPage extends StatefulWidget {
  const BlogFeedPage({super.key});

  @override
  State<BlogFeedPage> createState() => _BlogFeedPageState();
}

class _BlogFeedPageState extends State<BlogFeedPage> {
  final BlogService _blogService = BlogService();
  List<BlogPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _blogService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleLike(BlogPost post) async {
    try {
      final userId = UserData.name.value;
      final updatedPost = await _blogService.toggleLike(post.id, userId);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = updatedPost;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
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
          'บล็อก & แนวร่วม',
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF58CC02)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBlogPostPage()),
              );
              if (result == true) {
                _loadPosts();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(_posts[index])
                          .animate()
                          .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                          .slideY(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return ValueListenableBuilder<String>(
      valueListenable: UserData.appLanguage,
      builder: (context, lang, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              lang == 'th' ? 'ยังไม่มีโพสต์' : 'No posts yet',
              style: GoogleFonts.kanit(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang == 'th' ? 'เริ่มต้นโพสต์หาแนวร่วมกันเลย!' : 'Start posting to find allies!',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateBlogPostPage()),
                );
                if (result == true) {
                  _loadPosts();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(lang == 'th' ? 'สร้างโพสต์' : 'Create Post', style: GoogleFonts.kanit()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BlogPost post) {
    final isLiked = post.likedBy.contains(UserData.name.value);
    final timeAgo = _getTimeAgo(post.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: post.authorAvatarUrl != null
                  ? NetworkImage(post.authorAvatarUrl!)
                  : NetworkImage(UserData.avatarTemplates[0]),
            ),
            title: Text(
              post.authorName,
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              timeAgo,
              style: GoogleFonts.kanit(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: post.targetLanguage.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.targetLanguage,
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF58CC02),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),

          // Image
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                post.imageUrl!,
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

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF2B3445),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

                // Tags
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _toggleLike(post),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey.shade600,
                      size: 20,
                    ),
                    label: Text(
                      '${post.likes}',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: isLiked ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to comments
                    },
                    icon: Icon(Icons.comment_outlined, color: Colors.grey.shade600, size: 20),
                    label: Text(
                      '${post.comments}',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Share functionality
                    },
                    icon: Icon(Icons.share_outlined, color: Colors.grey.shade600, size: 20),
                    label: Text(
                      'แชร์',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ปีที่แล้ว';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} เดือนที่แล้ว';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }
}

