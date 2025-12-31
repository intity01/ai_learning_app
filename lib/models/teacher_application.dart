// lib/models/teacher_application.dart
class TeacherApplication {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String targetLanguage; // JP, EN, CN, KR
  final List<String> qualifications; // ประกาศนียบัตร, ประสบการณ์
  final String experience; // ประสบการณ์การสอน
  final String bio; // ประวัติส่วนตัว
  final List<String> specialties; // สาขาที่เชี่ยวชาญ
  final ApplicationStatus status; // pending, approved, rejected
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  TeacherApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.targetLanguage,
    required this.qualifications,
    required this.experience,
    required this.bio,
    required this.specialties,
    this.status = ApplicationStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'email': email,
      'targetLanguage': targetLanguage,
      'qualifications': qualifications,
      'experience': experience,
      'bio': bio,
      'specialties': specialties,
      'status': status.toString().split('.').last,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }

  factory TeacherApplication.fromMap(Map<String, dynamic> map) {
    return TeacherApplication(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      targetLanguage: map['targetLanguage'] ?? 'JP',
      qualifications: List<String>.from(map['qualifications'] ?? []),
      experience: map['experience'] ?? '',
      bio: map['bio'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt: DateTime.parse(map['submittedAt']),
      reviewedAt: map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      reviewNotes: map['reviewNotes'],
    );
  }
}

enum ApplicationStatus {
  pending,
  approved,
  rejected,
}


