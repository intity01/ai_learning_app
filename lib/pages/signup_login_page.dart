import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../services/auth_service_firebase.dart'; // ✅ ใช้ Firebase แทน SharedPreferences
import '../main_screen.dart';
import '../user_data.dart'; // ✅ สำหรับบันทึกว่า Onboarding เสร็จแล้ว

/// หน้า Sign Up / Login
/// ใช้ Lazy Registration - ให้ลองก่อน ค่อยสมัคร
class SignUpLoginPage extends StatefulWidget {
  final String nativeLanguage;
  final String targetLanguage;
  final String currentLevel;
  final int dailyGoalMinutes;

  const SignUpLoginPage({
    super.key,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.currentLevel,
    required this.dailyGoalMinutes,
  });

  @override
  State<SignUpLoginPage> createState() => _SignUpLoginPageState();
}

class _SignUpLoginPageState extends State<SignUpLoginPage> {
  bool _isLoading = false;
  
  // ✅ ใช้ AuthServiceFirebase แทน AuthService
  final _authService = AuthServiceFirebase();


  // ✅ Google Sign-In Handler
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        // ✅ Sync ชื่อจาก Google Account
        await UserData.syncNameFromGoogle(user.username);
        
        // ✅ บันทึก targetLanguage จาก onboarding
        String langCode = UserData.targetLanguageFromDisplay(widget.targetLanguage);
        await UserData.setTargetLanguage(langCode);
        // ✅ บันทึกว่า Onboarding เสร็จแล้ว
        await UserData.setFirstLaunchCompleted();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        // User ยกเลิกการ Sign-In
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2B3445)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Gap(20),
                Text(
                  "เข้าสู่ระบบ",
                  style: GoogleFonts.kanit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2B3445),
                  ),
                ),
                const Gap(8),
                Text(
                  "เข้าสู่ระบบด้วย Google เพื่อบันทึกความคืบหน้าของคุณ",
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Gap(40),

                // ✅ Google Sign-In Button (หลัก)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4));
                      },
                    ),
                    label: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                            ),
                          )
                        : Text(
                            "เข้าสู่ระบบด้วย Google",
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2B3445),
                            ),
                          ),
                  ),
                ),
                const Gap(20),

                // Skip Option (Lazy Registration)
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : () async {
                      // ✅ บันทึก targetLanguage จาก onboarding
                      String langCode = UserData.targetLanguageFromDisplay(widget.targetLanguage);
                      await UserData.setTargetLanguage(langCode);
                      // ✅ บันทึกว่า Onboarding เสร็จแล้ว
                      await UserData.setFirstLaunchCompleted();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      }
                    },
                    child: Text(
                      "ข้ามไปก่อน (ลองใช้ฟรี)",
                      style: GoogleFonts.kanit(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}

