class User {
  final String username;
  final String avatarUrl;
  final int level;
  final int streakDays;
  final double progress;

  User({
    required this.username,
    required this.avatarUrl,
    required this.level,
    required this.streakDays,
    required this.progress,
  });
}