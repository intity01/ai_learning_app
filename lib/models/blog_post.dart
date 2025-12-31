// lib/models/blog_post.dart
class BlogPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String title;
  final String content;
  final String? imageUrl;
  final List<String> tags;
  final String targetLanguage;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final List<String> likedBy;

  BlogPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.title,
    required this.content,
    this.imageUrl,
    this.tags = const [],
    required this.targetLanguage,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatarUrl: map['authorAvatarUrl'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      targetLanguage: map['targetLanguage'] ?? 'JP',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  BlogPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? tags,
    String? targetLanguage,
    DateTime? createdAt,
    int? likes,
    int? comments,
    List<String>? likedBy,
  }) {
    return BlogPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}


