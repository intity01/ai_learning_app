import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import ไฟล์หลัก
import 'main_screen.dart'; 
import 'user_data.dart';   

// Import หน้าต่างๆ 
import 'pages/ai_tutor_page.dart';
import 'pages/lesson_list_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/vocabulary_page.dart';
import 'pages/stats_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/onboarding_questions_page.dart';
import 'pages/friends_page.dart';
import 'pages/blog_feed_page.dart';
import 'pages/test_api_page.dart';
// ✅ Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialize Firebase (ตรวจสอบว่า initialize แล้วหรือยัง)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // ถ้า Firebase ถูก initialize แล้วจะไม่ error
    debugPrint('Firebase initialization: $e');
  }
  
  await UserData.init(); 
  runApp(const MyApp());
}

// ✅ Widget สำหรับตรวจสอบ First Launch
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await UserData.isFirstLaunch();
    setState(() {
      _isFirstLaunch = isFirst;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ ถ้าเป็น First Launch ให้ไปหน้า Onboarding
    if (_isFirstLaunch) {
      return const OnboardingPage();
    }

    // ✅ ถ้าไม่ใช่ ให้ไปหน้า MainScreen
    return const MainScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 ไม่ต้องใช้ ValueListenableBuilder ฟัง Theme/Language แล้ว
    // บังคับเป็น Light Mode และภาษาไทย (Default) ไปเลย
    return MaterialApp(
      title: 'Flutter AI Learning App',
      debugShowCheckedModeBanner: false,
      
      // บังคับ Light Mode
      themeMode: ThemeMode.light,
      
      // ☀️ Light Theme Setup (ปรับให้สบายตาขึ้น)
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD), // สีพื้นหลังสอดคล้องกับทุกหน้า
        colorSchemeSeed: const Color(0xFF58CC02),
        brightness: Brightness.light,
        
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: const Color(0xFF2B3445)),
        ),
        
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8F9FD),
          foregroundColor: const Color(0xFF2B3445),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.kanit(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: const Color(0xFF2B3445)
          ),
        ),
      ),
      
      home: const AppInitializer(), // ✅ ใช้ AppInitializer แทน MainScreen
      
      routes: {
        '/home': (context) => const MainScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/onboarding-questions': (context) => const OnboardingQuestionsPage(),
        // Note: LoadingPlanPage and SignUpLoginPage require parameters, so they should be navigated via MaterialPageRoute with arguments
        '/ai-tutor': (context) => const AITutorPage(),
        '/lessons': (context) => const LessonListPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/vocabulary': (context) => const VocabularyPage(),
        '/stats': (context) => const StatsPage(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/friends': (context) => const FriendsPage(),
        '/blog': (context) => const BlogFeedPage(),
        '/test-api': (context) => const TestApiPage(),
      },
    );
  }
}