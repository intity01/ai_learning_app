// lib/services/teacher_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/teacher_application.dart';

/// Service สำหรับจัดการการสมัครอาจารย์
class TeacherService {
  static const String _keyApplications = 'teacher_applications';
  static const String _keyTeachers = 'approved_teachers';

  /// สมัครเป็นอาจารย์
  Future<TeacherApplication> submitApplication({
    required String userId,
    required String userName,
    required String email,
    required String targetLanguage,
    required List<String> qualifications,
    required String experience,
    required String bio,
    required List<String> specialties,
  }) async {
    final applications = await getAllApplications();
    
    // ตรวจสอบว่ามีการสมัครอยู่แล้วหรือไม่
    final existing = applications.where((a) => 
      a.userId == userId && 
      a.status == ApplicationStatus.pending
    ).toList();
    
    if (existing.isNotEmpty) {
      throw Exception('คุณมีการสมัครที่รอการอนุมัติอยู่แล้ว');
    }

    final application = TeacherApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      email: email,
      targetLanguage: targetLanguage,
      qualifications: qualifications,
      experience: experience,
      bio: bio,
      specialties: specialties,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );

    applications.add(application);
    await _saveApplications(applications);
    
    return application;
  }

  /// อนุมัติการสมัคร (Admin only)
  Future<void> approveApplication(String applicationId, {String? notes}) async {
    final applications = await getAllApplications();
    final index = applications.indexWhere((a) => a.id == applicationId);
    
    if (index == -1) return;
    
    final app = applications[index];
    applications[index] = TeacherApplication(
      id: app.id,
      userId: app.userId,
      userName: app.userName,
      email: app.email,
      targetLanguage: app.targetLanguage,
      qualifications: app.qualifications,
      experience: app.experience,
      bio: app.bio,
      specialties: app.specialties,
      status: ApplicationStatus.approved,
      submittedAt: app.submittedAt,
      reviewedAt: DateTime.now(),
      reviewNotes: notes,
    );
    
    await _saveApplications(applications);
    await _addApprovedTeacher(app.userId, app);
  }

  /// ปฏิเสธการสมัคร (Admin only)
  Future<void> rejectApplication(String applicationId, {String? notes}) async {
    final applications = await getAllApplications();
    final index = applications.indexWhere((a) => a.id == applicationId);
    
    if (index == -1) return;
    
    final app = applications[index];
    applications[index] = TeacherApplication(
      id: app.id,
      userId: app.userId,
      userName: app.userName,
      email: app.email,
      targetLanguage: app.targetLanguage,
      qualifications: app.qualifications,
      experience: app.experience,
      bio: app.bio,
      specialties: app.specialties,
      status: ApplicationStatus.rejected,
      submittedAt: app.submittedAt,
      reviewedAt: DateTime.now(),
      reviewNotes: notes,
    );
    
    await _saveApplications(applications);
  }

  /// ดึงการสมัครทั้งหมด
  Future<List<TeacherApplication>> getAllApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final appsJson = prefs.getStringList(_keyApplications) ?? [];
    
    return appsJson
        .map((json) => TeacherApplication.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  /// ดึงการสมัครของ user
  Future<TeacherApplication?> getUserApplication(String userId) async {
    final applications = await getAllApplications();
    return applications.where((a) => a.userId == userId).firstOrNull;
  }

  /// ตรวจสอบว่าเป็นอาจารย์หรือไม่
  Future<bool> isTeacher(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final teachersJson = prefs.getStringList(_keyTeachers) ?? [];
    return teachersJson.contains(userId);
  }

  /// เพิ่มอาจารย์ที่อนุมัติแล้ว
  Future<void> _addApprovedTeacher(String userId, TeacherApplication app) async {
    final prefs = await SharedPreferences.getInstance();
    final teachersJson = prefs.getStringList(_keyTeachers) ?? [];
    if (!teachersJson.contains(userId)) {
      teachersJson.add(userId);
      await prefs.setStringList(_keyTeachers, teachersJson);
    }
  }

  /// บันทึก applications
  Future<void> _saveApplications(List<TeacherApplication> applications) async {
    final prefs = await SharedPreferences.getInstance();
    final appsJson = applications.map((a) => jsonEncode(a.toMap())).toList();
    await prefs.setStringList(_keyApplications, appsJson);
  }
}


