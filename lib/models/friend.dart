// lib/models/friend.dart
class Friend {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String targetLanguage;
  final bool isOnline;
  final DateTime? lastSeen;
  final FriendStatus status; // pending, accepted, blocked

  Friend({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.targetLanguage,
    this.isOnline = false,
    this.lastSeen,
    this.status = FriendStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'targetLanguage': targetLanguage,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      targetLanguage: map['targetLanguage'] ?? 'JP',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : null,
      status: FriendStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => FriendStatus.pending,
      ),
    );
  }
}

enum FriendStatus {
  pending,
  accepted,
  blocked,
}


