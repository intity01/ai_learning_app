import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:ui' as ui;

// Player Model for Leaderboard
class Player {
  final String name;
  final int xp;
  final String avatarUrl;
  final bool isMe;
  Player({required this.name, required this.xp, required this.avatarUrl, this.isMe = false});
}

class UserData {
  // --- Main Notifiers ---
  static ValueNotifier<String> name = ValueNotifier("Learner");
  static ValueNotifier<int> xp = ValueNotifier(0);
  static ValueNotifier<int> streak = ValueNotifier(0);
  static ValueNotifier<String> rank = ValueNotifier("Bronze");
  static ValueNotifier<String> level = ValueNotifier("Beginner");
  static ValueNotifier<int> avatarIndex = ValueNotifier(0); // Index ของ avatar template (0-11)
  
  // Theme & Language
  static ValueNotifier<String> appLanguage = ValueNotifier("th");
  static ValueNotifier<String> targetLanguage = ValueNotifier("JP"); // ภาษาที่เรียน (JP, EN, CN, KR)
  static ValueNotifier<bool> isDarkMode = ValueNotifier(false); // Added for Theme Support
  
  // Avatar Templates (12 ตัวการ์ตูน) - ใช้ DiceBear API (Adventurer style)
  static List<String> get avatarTemplates => [
    'https://api.dicebear.com/7.x/adventurer/png?seed=1&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=2&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=3&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=4&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=5&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=6&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=7&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=8&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=9&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=10&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=11&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
    'https://api.dicebear.com/7.x/adventurer/png?seed=12&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf',
  ];
  
  static String get currentAvatarUrl => avatarTemplates[avatarIndex.value.clamp(0, avatarTemplates.length - 1)];

  static ValueNotifier<List<String>> history = ValueNotifier([]);
  static ValueNotifier<Map<int, double>> lessonProgress = ValueNotifier({}); 
  static ValueNotifier<List<int>> weeklyXP = ValueNotifier([0, 0, 0, 0, 0, 0, 0]);
  static ValueNotifier<Map<int, int>> lessonCurrentIndex = ValueNotifier({}); 

  static ValueNotifier<int> dailyXP = ValueNotifier(0);
  static ValueNotifier<int> dailyVocabAdded = ValueNotifier(0);

  // Default Vocabulary List (Factory Settings)
  static const List<Map<String, dynamic>> _defaultVocab = [
    {'word': 'こんにちは', 'meaning': 'สวัสดี', 'romaji': 'Konnichiwa', 'tag': 'Greeting', 'isCustom': false, 'lessonId': 1},
    {'word': 'ありがとう', 'meaning': 'ขอบคุณ', 'romaji': 'Arigatou', 'tag': 'Basic', 'isCustom': false, 'lessonId': 1},
    {'word': 'さようなら', 'meaning': 'ลาก่อน', 'romaji': 'Sayounara', 'tag': 'Basic', 'isCustom': false, 'lessonId': 1},
    {'word': '私 (Watashi)', 'meaning': 'ฉัน/ผม', 'romaji': 'Watashi', 'tag': 'Pronoun', 'isCustom': false, 'lessonId': 2},
    {'word': '名前 (Namae)', 'meaning': 'ชื่อ', 'romaji': 'Namae', 'tag': 'Noun', 'isCustom': false, 'lessonId': 2},
    {'word': '一 (Ichi)', 'meaning': 'หนึ่ง', 'romaji': 'Ichi', 'tag': 'Number', 'isCustom': false, 'lessonId': 3},
    {'word': '二 (Ni)', 'meaning': 'สอง', 'romaji': 'Ni', 'tag': 'Number', 'isCustom': false, 'lessonId': 3},
  ];

  static ValueNotifier<List<Map<String, dynamic>>> vocabList = ValueNotifier(List.from(_defaultVocab));
  static ValueNotifier<List<Player>> leaderboard = ValueNotifier([]);
  static ValueNotifier<int> myRankPosition = ValueNotifier(0);

  // SharedPreferences Keys
  static const String _keyName = 'user_name';
  static const String _keyXP = 'user_xp';
  static const String _keyStreak = 'user_streak';
  static const String _keyLastLogin = 'last_login_date';
  static const String _keyLessonProgress = 'lesson_progress_';
  static const String _keyLessonIndex = 'lesson_index_';
  static const String _keyLanguage = 'app_language';
  static const String _keyTargetLanguage = 'target_language'; // Key for Target Language
  static const String _keyTheme = 'app_theme_dark'; // Key for Dark Mode
  static const String _keyHistory = 'user_history';
  static const String _keyWeeklyXP = 'user_weekly_xp';
  static const String _keyDailyXP = 'user_daily_xp';
  static const String _keyDailyVocab = 'user_daily_vocab';
  static const String _keyFirstLaunch = 'is_first_launch'; // ✅ สำหรับตรวจสอบ First Launch
  static const String _keyAvatarIndex = 'user_avatar_index'; // Key for Avatar Template Index

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString(_keyName) ?? "Learner";
    xp.value = prefs.getInt(_keyXP) ?? 0;
    avatarIndex.value = prefs.getInt(_keyAvatarIndex) ?? 0;
    
    // Load Daily Stats
    dailyXP.value = prefs.getInt(_keyDailyXP) ?? 0;
    dailyVocabAdded.value = prefs.getInt(_keyDailyVocab) ?? 0;

    // Load Settings
    // อ่านภาษาจากอุปกรณ์ (device locale) ถ้ายังไม่เคยตั้งค่า
    String? savedLanguage = prefs.getString(_keyLanguage);
    if (savedLanguage == null) {
      // อ่านภาษาจากอุปกรณ์
      String deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      // รองรับเฉพาะ th และ en (ถ้าเป็นภาษาอื่นให้ใช้ th เป็น default)
      savedLanguage = (deviceLocale == 'th' || deviceLocale == 'en') ? deviceLocale : 'th';
      // บันทึกค่าเริ่มต้นจาก device locale
      await prefs.setString(_keyLanguage, savedLanguage);
    }
    appLanguage.value = savedLanguage;
    targetLanguage.value = prefs.getString(_keyTargetLanguage) ?? "JP";
    isDarkMode.value = prefs.getBool(_keyTheme) ?? false;

    history.value = prefs.getStringList(_keyHistory) ?? [];
    
    List<String>? savedWeekly = prefs.getStringList(_keyWeeklyXP);
    if (savedWeekly != null && savedWeekly.length == 7) {
      weeklyXP.value = savedWeekly.map((e) => int.parse(e)).toList();
    }

    // Streak Logic & Daily Reset
    String? lastLoginStr = prefs.getString(_keyLastLogin);
    int currentStreak = prefs.getInt(_keyStreak) ?? 0;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (lastLoginStr != null) {
      DateTime lastLogin = DateTime.parse(lastLoginStr);
      DateTime lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      
      // Reset Daily Stats if new day
      if (lastLoginDate.isBefore(today)) {
        dailyXP.value = 0;
        dailyVocabAdded.value = 0;
        await prefs.setInt(_keyDailyXP, 0);
        await prefs.setInt(_keyDailyVocab, 0);
      }

      // Reset Weekly XP if new week (Monday)
      if (now.weekday == 1 && lastLoginDate.isBefore(today)) {
         weeklyXP.value = [0, 0, 0, 0, 0, 0, 0];
         await prefs.setStringList(_keyWeeklyXP, weeklyXP.value.map((e) => e.toString()).toList());
      }

      if (today.difference(lastLoginDate).inDays == 1) {
        streak.value = currentStreak;
      } else if (today.difference(lastLoginDate).inDays > 1) {
        streak.value = 0;
        await prefs.setInt(_keyStreak, 0);
      } else {
        streak.value = currentStreak;
      }
    } else {
      streak.value = 0;
    }
    
    // Load Lesson Progress & Indices
    Map<int, double> progress = {};
    Map<int, int> indices = {};
    for (int i = 1; i <= 5; i++) {
      progress[i] = prefs.getDouble('$_keyLessonProgress$i') ?? 0.0;
      indices[i] = prefs.getInt('$_keyLessonIndex$i') ?? 0;
    }
    lessonProgress.value = progress;
    lessonCurrentIndex.value = indices;

    _updateRankAndLevel();
    _generateLeaderboard();
  }

  // --- Logic Functions ---

  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    appLanguage.value = langCode;
    await prefs.setString(_keyLanguage, langCode);
  }

  static Future<void> setTargetLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    targetLanguage.value = langCode;
    await prefs.setString(_keyTargetLanguage, langCode);
  }

  // แปลง display string เป็น language code
  static String targetLanguageFromDisplay(String displayString) {
    if (displayString.contains('日本語') || displayString.contains('ญี่ปุ่น')) {
      return 'JP';
    } else if (displayString.contains('English') || displayString.contains('อังกฤษ')) {
      return 'EN';
    } else if (displayString.contains('中文') || displayString.contains('จีน')) {
      return 'CN';
    } else if (displayString.contains('한국어') || displayString.contains('เกาหลี')) {
      return 'KR';
    }
    return 'JP'; // default
  }

  // แปลง targetLanguage code เป็น voice service language code (ja, en, th, etc.)
  static String targetLanguageToVoiceCode(String langCode) {
    switch (langCode) {
      case 'JP':
        return 'ja';
      case 'EN':
        return 'en';
      case 'CN':
        return 'zh';
      case 'KR':
        return 'ko';
      default:
        return 'ja';
    }
  }

  // แปลง targetLanguage code เป็นชื่อภาษาไทย
  static String targetLanguageToThaiName(String langCode) {
    switch (langCode) {
      case 'JP':
        return 'ภาษาญี่ปุ่น';
      case 'EN':
        return 'ภาษาอังกฤษ';
      case 'CN':
        return 'ภาษาจีน';
      case 'KR':
        return 'ภาษาเกาหลี';
      default:
        return 'ภาษาญี่ปุ่น';
    }
  }

  // แปลง targetLanguage code เป็นชื่อภาษาอังกฤษ
  static String targetLanguageToEnglishName(String langCode) {
    switch (langCode) {
      case 'JP':
        return 'Japanese';
      case 'EN':
        return 'English';
      case 'CN':
        return 'Chinese';
      case 'KR':
        return 'Korean';
      default:
        return 'Japanese';
    }
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = !isDarkMode.value;
    await prefs.setBool(_keyTheme, isDarkMode.value);
  }

  static Future<void> updateLessonProgress(int lessonId, int questionIndex, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();
    
    Map<int, int> currentIndices = Map.from(lessonCurrentIndex.value);
    currentIndices[lessonId] = questionIndex;
    lessonCurrentIndex.value = currentIndices;
    await prefs.setInt('$_keyLessonIndex$lessonId', questionIndex);

    double percent = questionIndex / totalQuestions;
    if (percent > 1.0) percent = 1.0;
    
    Map<int, double> currentProgress = Map.from(lessonProgress.value);
    if ((currentProgress[lessonId] ?? 0.0) < 1.0) {
       currentProgress[lessonId] = percent;
       lessonProgress.value = currentProgress;
       await prefs.setDouble('$_keyLessonProgress$lessonId', percent);
    }
  }

  static void _generateLeaderboard() {
    List<Player> tempPlayers = [];
    final random = Random();
    List<String> botNames = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Heidi", "Ivan", "Judy", "Ken", "Leo", "Mike", "Nancy", "Oscar", "Paul", "Queen", "Rose", "Steve", "Tina"];
    for (var botName in botNames) {
      int botXP = (xp.value - 200) + random.nextInt(500); 
      if (botXP < 0) botXP = random.nextInt(100);
      tempPlayers.add(Player(name: botName, xp: botXP, avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=$botName&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf', isMe: false));
    }
    tempPlayers.add(Player(name: name.value, xp: xp.value, avatarUrl: currentAvatarUrl, isMe: true));
    tempPlayers.sort((a, b) => b.xp.compareTo(a.xp));
    leaderboard.value = tempPlayers;
    int index = leaderboard.value.indexWhere((p) => p.isMe);
    if (index != -1) myRankPosition.value = index + 1;
  }

  static Future<void> addVocabulary(String word, String meaning, String romaji, String tag) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> currentList = List.from(vocabList.value);
    currentList.insert(0, {'word': word, 'meaning': meaning, 'romaji': romaji, 'tag': tag, 'isCustom': true, 'lessonId': 0});
    vocabList.value = currentList;
    
    dailyVocabAdded.value += 1;
    await prefs.setInt(_keyDailyVocab, dailyVocabAdded.value);
  }

  static void deleteVocabulary(String wordToDelete) {
    List<Map<String, dynamic>> currentList = List.from(vocabList.value);
    currentList.removeWhere((item) => item['word'] == wordToDelete && item['isCustom'] == true);
    vocabList.value = currentList;
  }

  // 🔥 Full Reset Function
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    xp.value = 0;
    streak.value = 0;
    rank.value = "Bronze";
    level.value = "Beginner";
    history.value = [];
    lessonProgress.value = {};
    lessonCurrentIndex.value = {}; // Reset current question index
    weeklyXP.value = [0, 0, 0, 0, 0, 0, 0];
    
    appLanguage.value = "th";
    targetLanguage.value = "JP";
    isDarkMode.value = false; // Reset Theme
    
    dailyXP.value = 0;
    dailyVocabAdded.value = 0;
    
    // Reset Vocab to Default
    vocabList.value = List.from(_defaultVocab);
    
    _generateLeaderboard();
  }

  static Future<void> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    name.value = newName;
    await prefs.setString(_keyName, newName);
    _generateLeaderboard();
  }
  
  static Future<void> setAvatarIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    avatarIndex.value = index.clamp(0, avatarTemplates.length - 1);
    await prefs.setInt(_keyAvatarIndex, avatarIndex.value);
    _generateLeaderboard();
  }
  
  // Sync ชื่อจาก Google Account (ถ้ายังไม่ได้ตั้งชื่อเอง)
  static Future<void> syncNameFromGoogle(String? googleName) async {
    if (googleName != null && googleName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final currentName = prefs.getString(_keyName) ?? "Learner";
      // Sync เฉพาะถ้ายังใช้ชื่อ default หรือชื่อว่าง
      if (currentName == "Learner" || currentName.isEmpty) {
        name.value = googleName;
        await prefs.setString(_keyName, googleName);
        _generateLeaderboard();
      }
    }
  }

  static Future<void> completeLesson(int lessonId, String lessonTitle) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update Progress to 100%
    Map<int, double> currentProgress = Map.from(lessonProgress.value);
    currentProgress[lessonId] = 1.0; 
    lessonProgress.value = currentProgress;
    await prefs.setDouble('$_keyLessonProgress$lessonId', 1.0);

    // Reset Question Index to 0
    Map<int, int> currentIndices = Map.from(lessonCurrentIndex.value);
    currentIndices[lessonId] = 0;
    lessonCurrentIndex.value = currentIndices;
    await prefs.setInt('$_keyLessonIndex$lessonId', 0);

    int xpGain = 50; 
    xp.value += xpGain;
    await prefs.setInt(_keyXP, xp.value);

    dailyXP.value += xpGain;
    await prefs.setInt(_keyDailyXP, dailyXP.value);

    DateTime now = DateTime.now();
    int weekdayIndex = now.weekday - 1; 
    List<int> currentWeekly = List.from(weeklyXP.value);
    currentWeekly[weekdayIndex] += xpGain; 
    weeklyXP.value = currentWeekly;
    await prefs.setStringList(_keyWeeklyXP, currentWeekly.map((e) => e.toString()).toList());

    String todayStr = now.toIso8601String().split('T')[0];
    String? lastLoginStr = prefs.getString(_keyLastLogin);
    String? lastDateStr = lastLoginStr?.split('T')[0];

    if (lastDateStr != todayStr) {
      streak.value += 1;
      await prefs.setInt(_keyStreak, streak.value);
      await prefs.setString(_keyLastLogin, now.toIso8601String());
    }

    String timestamp = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    String historyEntry = "$lessonTitle|$timestamp";
    
    List<String> currentHistory = List.from(history.value);
    currentHistory.insert(0, historyEntry);
    history.value = currentHistory;
    await prefs.setStringList(_keyHistory, currentHistory);

    _updateRankAndLevel();
    _generateLeaderboard();
  }

  static void _updateRankAndLevel() {
    int score = xp.value;
    if (score < 100) { rank.value = "Bronze"; level.value = "Beginner"; }
    else if (score < 500) { rank.value = "Silver"; level.value = "Intermediate"; }
    else if (score < 1000) { rank.value = "Gold"; level.value = "Advanced"; }
    else if (score < 2000) { rank.value = "Platinum"; level.value = "Expert"; }
    else { rank.value = "Diamond"; level.value = "Master"; }
  }
  
  // ✅ ตรวจสอบว่าเป็น First Launch หรือไม่
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true; // Default = true (ยังไม่เคยเปิด)
  }
  
  // ✅ บันทึกว่า Onboarding เสร็จแล้ว
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }
}