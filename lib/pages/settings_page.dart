import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';
import '../app_strings.dart';
import '../services/auth_service_firebase.dart';
import 'test_api_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onToggleTheme; 
  const SettingsPage({super.key, this.onToggleTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthServiceFirebase _authService = AuthServiceFirebase();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
    
    // ฟังการเปลี่ยนแปลงของ auth state
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        // ✅ Sync ชื่อจาก Google Account
        await UserData.syncNameFromGoogle(user.username);
        
        // ✅ Sync ข้อมูลจาก Firestore (ถ้ามี)
        try {
          final firestoreUser = await _authService.getCurrentUser();
          if (firestoreUser != null) {
            // Sync XP, Streak, etc. จาก Firestore
            // (สามารถเพิ่ม logic sync ข้อมูลอื่นๆ ได้ที่นี่)
          }
        } catch (e) {
          debugPrint('Error syncing Firestore data: $e');
        }
        
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(
                AppStrings.t('sign_in_success'),
                style: GoogleFonts.kanit(),
              ),
            ),
            backgroundColor: const Color(0xFF58CC02),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: UserData.appLanguage,
        builder: (context, lang, _) => AlertDialog(
          title: Text('${AppStrings.t('sign_out')}?', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Text(AppStrings.t('sign_out_confirm'), style: GoogleFonts.kanit()),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.t('sign_out'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _authService.signOut();
        if (mounted) {
          setState(() {
            _currentUser = null;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: UserData.appLanguage,
                builder: (context, lang, _) => Text(
                  AppStrings.t('sign_out_success'),
                  style: GoogleFonts.kanit(),
                ),
              ),
              backgroundColor: Colors.grey.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // บังคับสีพื้นหลัง Light
      appBar: AppBar(
        title: Text(AppStrings.t('settings'), style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2B3445)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ส่วน Account Information (แสดงข้อมูล Google Account)
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_currentUser != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_circle, color: const Color(0xFF58CC02), size: 20),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, lang, _) => Text(
                            AppStrings.t('connected_account'),
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _currentUser!.photoURL != null
                              ? NetworkImage(_currentUser!.photoURL!)
                              : null,
                          child: _currentUser!.photoURL == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.displayName ?? 'User',
                                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _currentUser!.email ?? AppStrings.t('no_email'),
                                      style: GoogleFonts.kanit(color: Colors.grey.shade600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 14,
                                      height: 14,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.g_mobiledata, size: 14, color: Colors.blue);
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Google Account',
                                      style: GoogleFonts.kanit(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleSignOut,
                        icon: const Icon(Icons.logout, size: 18),
                        label: ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, lang, _) => Text(
                            AppStrings.t('sign_out'),
                            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_circle, color: const Color(0xFF58CC02), size: 20),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: UserData.appLanguage,
                          builder: (context, lang, _) => Text(
                            AppStrings.t('connected_account'),
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ValueListenableBuilder<String>(
                                  valueListenable: UserData.appLanguage,
                                  builder: (context, lang, _) => Text(
                                    AppStrings.t('account_not_connected'),
                                    style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.t('connect_google_account'),
                                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.orange.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        icon: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                                ),
                              )
                            : Image.asset(
                                'assets/images/google_logo.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4));
                                },
                              ),
                        label: _isLoading
                            ? ValueListenableBuilder<String>(
                                valueListenable: UserData.appLanguage,
                                builder: (context, lang, _) => Text(
                                  AppStrings.t('signing_in'),
                                  style: GoogleFonts.kanit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2B3445),
                                  ),
                                ),
                              )
                            : ValueListenableBuilder<String>(
                                valueListenable: UserData.appLanguage,
                                builder: (context, lang, _) => Text(
                                  AppStrings.t('sign_in_with_google'),
                                  style: GoogleFonts.kanit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2B3445),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),

            // ส่วน Profile (แสดงข้อมูลในแอป)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: const Color(0xFF58CC02), size: 20),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('app_data'),
                          style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarPicker(context),
                        child: ValueListenableBuilder<int>(
                          valueListenable: UserData.avatarIndex,
                          builder: (context, index, _) {
                            return Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    UserData.avatarTemplates[index.clamp(0, UserData.avatarTemplates.length - 1)]
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF58CC02),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: UserData.name,
                                    builder: (_, name, __) => Text(name, style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                                  onPressed: () => _showEditNameDialog(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            Text("Free Member", style: GoogleFonts.kanit(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<String>(
                              valueListenable: UserData.targetLanguage,
                              builder: (context, targetLang, _) {
                                return ValueListenableBuilder<String>(
                                  valueListenable: UserData.appLanguage,
                                  builder: (context, appLang, __) {
                                    final langName = UserData.targetLanguageToDisplayName(targetLang);
                                    final langFlag = targetLang == 'JP' ? '🇯🇵' : targetLang == 'EN' ? '🇬🇧' : targetLang == 'CN' ? '🇨🇳' : '🇰🇷';
                                    return Row(
                                      children: [
                                        Text(langFlag, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Text(
                                          langName,
                                          style: GoogleFonts.kanit(color: const Color(0xFF58CC02), fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // การตั้งค่าภาษา UI (ภาษาแอป)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: const Color(0xFF58CC02), size: 20),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('app_language'),
                          style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.appLanguage,
                    builder: (context, lang, _) => Text(
                      AppStrings.t('change_app_language'),
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.appLanguage,
                    builder: (context, currentLang, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // แสดงภาษาที่เลือกปัจจุบัน
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  currentLang == 'th' ? '🇹🇭' : '🇬🇧',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.t('current_language'),
                                        style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      ValueListenableBuilder<String>(
                                        valueListenable: UserData.appLanguage,
                                        builder: (context, appLang, _) => Text(
                                          currentLang == 'th' ? AppStrings.t('thai_language') : AppStrings.t('english_language'),
                                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.t('select_language'),
                            style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<String>(
                            valueListenable: UserData.appLanguage,
                            builder: (context, appLang, _) => Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildUILanguageOption(context, 'th', '🇹🇭 ${AppStrings.t('thai_language')}', currentLang),
                                _buildUILanguageOption(context, 'en', '🇬🇧 ${AppStrings.t('english_language')}', currentLang),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // การตั้งค่าภาษาที่เรียน
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: const Color(0xFF58CC02), size: 20),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('learning_language'),
                          style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.appLanguage,
                    builder: (context, lang, _) => Text(
                      AppStrings.t('change_learning_language'),
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: UserData.targetLanguage,
                    builder: (context, currentLang, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // แสดงภาษาที่เลือกปัจจุบัน
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF58CC02).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  currentLang == 'JP' ? '🇯🇵' : currentLang == 'EN' ? '🇬🇧' : currentLang == 'CN' ? '🇨🇳' : '🇰🇷',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.t('current_language'),
                                        style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      ValueListenableBuilder<String>(
                                        valueListenable: UserData.appLanguage,
                                        builder: (context, appLang, _) => Text(
                                          UserData.targetLanguageToDisplayName(currentLang),
                                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.t('select_language'),
                            style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<String>(
                            valueListenable: UserData.appLanguage,
                            builder: (context, appLang, _) => Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildLanguageOption(context, 'JP', UserData.targetLanguageToDisplayNameWithFlag('JP'), currentLang),
                                _buildLanguageOption(context, 'EN', UserData.targetLanguageToDisplayNameWithFlag('EN'), currentLang),
                                _buildLanguageOption(context, 'CN', UserData.targetLanguageToDisplayNameWithFlag('CN'), currentLang),
                                _buildLanguageOption(context, 'KR', UserData.targetLanguageToDisplayNameWithFlag('KR'), currentLang),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // ปุ่ม Test API (Developer)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.api),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02).withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TestApiPage()),
                  );
                },
                label: Text(
                  'ทดสอบ API & สร้างบทเรียน',
                  style: GoogleFonts.kanit(
                    color: const Color(0xFF58CC02),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม Reset
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  _showResetDialog(context);
                },
                child: ValueListenableBuilder<String>(
                  valueListenable: UserData.appLanguage,
                  builder: (context, lang, _) => Text(
                    AppStrings.t('reset_all_data'),
                    style: GoogleFonts.kanit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text("Version 1.0.0", style: GoogleFonts.kanit(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUILanguageOption(BuildContext context, String langCode, String label, String currentLang) {
    final isSelected = currentLang == langCode;
    return GestureDetector(
      onTap: () async {
        await UserData.setLanguage(langCode);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder(
                valueListenable: UserData.appLanguage,
                builder: (context, currentLang, __) => Text(
                  langCode == 'th' 
                    ? AppStrings.t('app_language_changed_th')
                    : AppStrings.t('app_language_changed_en'),
                  style: GoogleFonts.kanit(),
                ),
              ),
              backgroundColor: const Color(0xFF58CC02),
              duration: const Duration(seconds: 2),
            ),
          );
          // Reload page to apply language changes
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String langCode, String label, String currentLang) {
    final isSelected = currentLang == langCode;
    return GestureDetector(
      onTap: () async {
        await UserData.setTargetLanguage(langCode);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder(
                valueListenable: UserData.appLanguage,
                builder: (context, _, __) => Text('${AppStrings.t('learning_language_changed')} $label', style: GoogleFonts.kanit()),
              ),
              backgroundColor: Colors.grey.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: UserData.appLanguage,
        builder: (context, lang, _) => AlertDialog(
          title: Text(AppStrings.t('confirm_reset'), style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: Text(AppStrings.t('reset_warning'), style: GoogleFonts.kanit()),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                UserData.resetProgress();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppStrings.t('reset_success'), style: GoogleFonts.kanit()),
                  backgroundColor: Colors.grey.shade800,
                ));
              },
              child: Text(AppStrings.t('confirm'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: UserData.name.value);
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: UserData.appLanguage,
        builder: (context, lang, _) => AlertDialog(
          title: Text(AppStrings.t('edit_your_name'), style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            style: GoogleFonts.kanit(),
            decoration: InputDecoration(
              labelText: AppStrings.t('new_name'),
              border: const OutlineInputBorder(),
              hintText: AppStrings.t('please_enter_name'),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('cancel'), style: GoogleFonts.kanit(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  UserData.updateName(controller.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.t('name_changed_success'), style: GoogleFonts.kanit()),
                      backgroundColor: const Color(0xFF58CC02),
                    ),
                  );
                }
              },
              child: Text(AppStrings.t('save'), style: GoogleFonts.kanit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('select_avatar'),
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: UserData.avatarTemplates.length,
            itemBuilder: (context, index) {
              final isSelected = UserData.avatarIndex.value == index;
              return GestureDetector(
                onTap: () {
                  UserData.setAvatarIndex(index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ValueListenableBuilder<String>(
                        valueListenable: UserData.appLanguage,
                        builder: (context, lang, _) => Text(
                          AppStrings.t('avatar_changed_success'),
                          style: GoogleFonts.kanit(),
                        ),
                      ),
                      backgroundColor: const Color(0xFF58CC02),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF58CC02) : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(UserData.avatarTemplates[index]),
                  ),
                ),
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ValueListenableBuilder<String>(
              valueListenable: UserData.appLanguage,
              builder: (context, lang, _) => Text(
                AppStrings.t('close'),
                style: GoogleFonts.kanit(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}