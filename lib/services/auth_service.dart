import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Service สำหรับจัดการ Authentication
/// 
/// **Note:** ตอนนี้ใช้ SharedPreferences เป็น temporary storage
/// **TODO:** ควรเปลี่ยนเป็น Firebase Auth หรือ Supabase ในอนาคต
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserProfile = 'user_profile';

  /// ตรวจสอบว่ามีการ Login อยู่หรือไม่
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// ลงทะเบียนผู้ใช้ใหม่ (Sign Up)
  static Future<UserProfile> signUp({
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    required String currentLevel,
    required int dailyGoalMinutes,
  }) async {
    // TODO: เชื่อมต่อ Firebase Auth หรือ Supabase
    // ตอนนี้ใช้ SharedPreferences เป็น temporary
    
    final prefs = await SharedPreferences.getInstance();
    
    // สร้าง User Profile
    final userProfile = UserProfile(
      uid: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      username: username,
      email: email,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      currentLevel: currentLevel,
      dailyGoalMinutes: dailyGoalMinutes,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    // บันทึกข้อมูล
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userProfile.uid!);
    await prefs.setString(_keyUserProfile, _profileToJson(userProfile));

    return userProfile;
  }

  /// เข้าสู่ระบบ (Sign In)
  static Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    // TODO: เชื่อมต่อ Firebase Auth หรือ Supabase
    final prefs = await SharedPreferences.getInstance();
    
    // ตรวจสอบว่ามีข้อมูลหรือไม่
    if (await isLoggedIn()) {
      final profileJson = prefs.getString(_keyUserProfile);
      if (profileJson != null) {
        final profile = _profileFromJson(profileJson);
        // อัปเดต lastLoginAt
        final updatedProfile = profile.copyWith(lastLoginAt: DateTime.now());
        await prefs.setString(_keyUserProfile, _profileToJson(updatedProfile));
        return updatedProfile;
      }
    }

    return null;
  }

  /// ออกจากระบบ (Sign Out)
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    // ไม่ลบข้อมูล user profile เพื่อให้สามารถ login ใหม่ได้
  }

  /// ดึงข้อมูล User Profile ปัจจุบัน
  static Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (await isLoggedIn()) {
      final profileJson = prefs.getString(_keyUserProfile);
      if (profileJson != null) {
        return _profileFromJson(profileJson);
      }
    }
    return null;
  }

  /// อัปเดต User Profile
  static Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, _profileToJson(profile));
  }

  // Helper methods
  static String _profileToJson(UserProfile profile) {
    return jsonEncode(profile.toMap());
  }

  static UserProfile _profileFromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (e) {
      // Fallback to default profile if parsing fails
      return UserProfile(
        username: 'User',
        email: 'user@example.com',
        nativeLanguage: 'th',
        targetLanguage: 'jp',
        currentLevel: 'Beginner',
        dailyGoalMinutes: 15,
      );
    }
  }
}

