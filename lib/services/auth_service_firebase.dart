// lib/services/auth_service_firebase.dart
// ✅ AuthService ที่ใช้ Firebase (จะใช้แทน auth_service.dart เมื่อ setup Firebase แล้ว)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';

/// Service สำหรับจัดการ Authentication ด้วย Firebase
class AuthServiceFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'], // ✅ ระบุ scopes ที่ต้องการ
  ); // ✅ สำหรับ Google Sign-In

  /// ตรวจสอบว่ามีการ Login อยู่หรือไม่
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// ลงทะเบียนผู้ใช้ใหม่ (Sign Up)
  Future<UserProfile> signUp({
    required String username,
    required String email,
    required String password,
    required String nativeLanguage,
    required String targetLanguage,
    required String currentLevel,
    required int dailyGoalMinutes,
  }) async {
    try {
      // สร้าง User ใน Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // สร้าง User Profile
      final userProfile = UserProfile(
        uid: user.uid,
        username: username,
        email: email,
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        currentLevel: currentLevel,
        dailyGoalMinutes: dailyGoalMinutes,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // บันทึกข้อมูลใน Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toMap());

      return userProfile;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// เข้าสู่ระบบ (Sign In)
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      // ดึงข้อมูล User Profile จาก Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final profile = UserProfile.fromMap(doc.data()!);
        
        // อัปเดต lastLoginAt
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
        
        return profile.copyWith(lastLoginAt: DateTime.now());
      }

      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// ✅ Sign In ด้วย Google
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Sign out ก่อน (ถ้ามี account เก่าค้างอยู่)
      await _googleSignIn.signOut();
      
      // เริ่ม Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User ยกเลิกการ Sign-In
        return null;
      }

      // ดึง authentication details จาก Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // สร้าง credential สำหรับ Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in กับ Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        return null;
      }

      // ตรวจสอบว่ามี User Profile ใน Firestore หรือไม่
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      UserProfile userProfile;
      
      if (doc.exists) {
        // มีข้อมูลอยู่แล้ว - อัปเดต lastLoginAt
        userProfile = UserProfile.fromMap(doc.data()!);
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
        return userProfile.copyWith(lastLoginAt: DateTime.now());
      } else {
        // ยังไม่มีข้อมูล - สร้าง User Profile ใหม่
        userProfile = UserProfile(
          uid: user.uid,
          username: user.displayName ?? 'User',
          email: user.email ?? '',
          nativeLanguage: 'th', // Default
          targetLanguage: 'jp', // Default
          currentLevel: 'Beginner', // Default
          dailyGoalMinutes: 15, // Default
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          avatarUrl: user.photoURL,
        );
        
        // บันทึกข้อมูลใน Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userProfile.toMap());
        
        return userProfile;
      }
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }
  
  /// ออกจากระบบ (Sign Out)
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out จาก Google
    await _auth.signOut(); // Sign out จาก Firebase
  }

  /// ดึงข้อมูล User Profile ปัจจุบัน
  Future<UserProfile?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }

    return null;
  }

  /// อัปเดต User Profile
  Future<void> updateProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(profile.toMap());
  }

  /// Stream สำหรับฟังการเปลี่ยนแปลงของ User
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

