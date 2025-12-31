// lib/models/user_profile.dart
class UserProfile {
  final String? uid; // ID จากระบบ Auth (Firebase/Supabase)
  final String username;
  final String email;
  final String nativeLanguage; // ภาษาแม่ (เช่น "th", "en")
  final String targetLanguage; // ภาษาที่อยากเรียน (เช่น "jp", "en")
  final String currentLevel; // A1, A2, B1, Beginner, Intermediate, Advanced
  final int dailyGoalMinutes; // เป้าหมายวันละกี่นาที (เช่น 15, 30)
  final int xp; // คะแนนสะสม
  final int streak; // จำนวนวันที่เรียนต่อเนื่อง
  final String rank; // Bronze, Silver, Gold, Platinum, Diamond
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? avatarUrl;

  UserProfile({
    this.uid,
    required this.username,
    required this.email,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.currentLevel,
    required this.dailyGoalMinutes,
    this.xp = 0,
    this.streak = 0,
    this.rank = "Bronze",
    this.createdAt,
    this.lastLoginAt,
    this.avatarUrl,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'nativeLanguage': nativeLanguage,
      'targetLanguage': targetLanguage,
      'currentLevel': currentLevel,
      'dailyGoalMinutes': dailyGoalMinutes,
      'xp': xp,
      'streak': streak,
      'rank': rank,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  // Create from Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      nativeLanguage: map['nativeLanguage'] ?? 'th',
      targetLanguage: map['targetLanguage'] ?? 'jp',
      currentLevel: map['currentLevel'] ?? 'Beginner',
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 15,
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      rank: map['rank'] ?? 'Bronze',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
      avatarUrl: map['avatarUrl'],
    );
  }

  // Copy with method
  UserProfile copyWith({
    String? uid,
    String? username,
    String? email,
    String? nativeLanguage,
    String? targetLanguage,
    String? currentLevel,
    int? dailyGoalMinutes,
    int? xp,
    int? streak,
    String? rank,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      currentLevel: currentLevel ?? this.currentLevel,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      rank: rank ?? this.rank,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}