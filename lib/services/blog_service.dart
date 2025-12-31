// lib/services/blog_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/blog_post.dart';

class BlogService {
  static const String _keyPosts = 'blog_posts';

  /// สร้างโพสต์ใหม่
  Future<void> createPost(BlogPost post) async {
    final posts = await getAllPosts();
    posts.insert(0, post); // เพิ่มที่ด้านบน
    await _savePosts(posts);
  }

  /// ดึงโพสต์ทั้งหมด (เรียงตามวันที่ใหม่สุด)
  Future<List<BlogPost>> getAllPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList(_keyPosts) ?? [];
    
    final posts = postsJson
        .map((json) => BlogPost.fromMap(jsonDecode(json)))
        .toList();
    
    // เรียงตามวันที่ใหม่สุด
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return posts;
  }

  /// ดึงโพสต์ตาม ID
  Future<BlogPost?> getPostById(String postId) async {
    final posts = await getAllPosts();
    try {
      return posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  /// Like/Unlike โพสต์
  Future<BlogPost> toggleLike(String postId, String userId) async {
    final posts = await getAllPosts();
    final index = posts.indexWhere((p) => p.id == postId);
    
    if (index == -1) {
      throw Exception('ไม่พบโพสต์');
    }

    final post = posts[index];
    final likedBy = List<String>.from(post.likedBy);
    final isLiked = likedBy.contains(userId);

    if (isLiked) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    final updatedPost = post.copyWith(
      likes: isLiked ? post.likes - 1 : post.likes + 1,
      likedBy: likedBy,
    );

    posts[index] = updatedPost;
    await _savePosts(posts);

    return updatedPost;
  }

  /// เพิ่มคอมเมนต์
  Future<void> addComment(String postId, String userId, String comment) async {
    final posts = await getAllPosts();
    final index = posts.indexWhere((p) => p.id == postId);
    
    if (index == -1) {
      throw Exception('ไม่พบโพสต์');
    }

    final post = posts[index];
    final updatedPost = post.copyWith(
      comments: post.comments + 1,
    );

    posts[index] = updatedPost;
    await _savePosts(posts);
  }

  /// ลบโพสต์
  Future<void> deletePost(String postId, String authorId) async {
    final posts = await getAllPosts();
    final post = posts.firstWhere((p) => p.id == postId);
    
    if (post.authorId != authorId) {
      throw Exception('คุณไม่มีสิทธิ์ลบโพสต์นี้');
    }

    posts.removeWhere((p) => p.id == postId);
    await _savePosts(posts);
  }

  /// บันทึกโพสต์
  Future<void> _savePosts(List<BlogPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_keyPosts, postsJson);
  }
}


