// lib/models/community_room.dart
class CommunityRoom {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final String language; // JP, EN, CN, KR
  final RoomType type; // video, voice, text
  final DateTime createdAt;
  final DateTime? expiresAt; // Auto-delete if empty or single user
  final List<String> participantIds;
  final int maxParticipants;
  final bool isPublic;

  CommunityRoom({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    required this.language,
    required this.type,
    required this.createdAt,
    this.expiresAt,
    required this.participantIds,
    this.maxParticipants = 10,
    this.isPublic = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'language': language,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'participantIds': participantIds,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
    };
  }

  factory CommunityRoom.fromMap(Map<String, dynamic> map) {
    return CommunityRoom(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      language: map['language'] ?? 'JP',
      type: RoomType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => RoomType.voice,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      maxParticipants: map['maxParticipants'] ?? 10,
      isPublic: map['isPublic'] ?? true,
    );
  }

  CommunityRoom copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? title,
    String? description,
    String? language,
    RoomType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? participantIds,
    int? maxParticipants,
    bool? isPublic,
  }) {
    return CommunityRoom(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      participantIds: participantIds ?? List.from(this.participantIds),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  int get participantCount => participantIds.length;
  bool get isEmpty => participantIds.isEmpty;
  bool get hasSingleUser => participantIds.length == 1;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get shouldDelete => isEmpty || hasSingleUser || isExpired;
}

enum RoomType {
  video,
  voice,
  text,
}

