// lib/models/community_group.dart
class CommunityGroup {
  final String id;
  final String creatorId;
  final String creatorName;
  final String name;
  final String description;
  final String language; // JP, EN, CN, KR
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> memberIds;
  final int maxMembers;
  final bool isPublic;
  final List<String> tags; // Topics, interests

  CommunityGroup({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.name,
    required this.description,
    required this.language,
    this.imageUrl,
    required this.createdAt,
    required this.memberIds,
    this.maxMembers = 100,
    this.isPublic = true,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'name': name,
      'description': description,
      'language': language,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'isPublic': isPublic,
      'tags': tags,
    };
  }

  factory CommunityGroup.fromMap(Map<String, dynamic> map) {
    return CommunityGroup(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      language: map['language'] ?? 'JP',
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      maxMembers: map['maxMembers'] ?? 100,
      isPublic: map['isPublic'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  CommunityGroup copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? name,
    String? description,
    String? language,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? memberIds,
    int? maxMembers,
    bool? isPublic,
    List<String>? tags,
  }) {
    return CommunityGroup(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? List.from(this.memberIds),
      maxMembers: maxMembers ?? this.maxMembers,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? List.from(this.tags),
    );
  }

  int get memberCount => memberIds.length;
  bool get isFull => memberIds.length >= maxMembers;
  bool isMember(String userId) => memberIds.contains(userId);
}

