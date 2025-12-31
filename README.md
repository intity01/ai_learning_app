# 🌍 Learning Language - AI-Powered Language Learning App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

**An intelligent language learning app powered by Google Gemini AI and ElevenLabs voice technology**

[Features](#-features) • [Installation](#-installation) • [Setup](#-setup) • [Demo](#-demo) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

**Learning Language** is a comprehensive mobile application for learning Japanese, English, Chinese, and Korean. It combines AI-powered conversational tutoring, voice interaction, gamification, and community features to create an engaging learning experience.

### 🎯 Key Features

- 🤖 **AI Tutor** - Real-time conversations with Google Gemini
- 🎤 **Voice Practice** - Pronunciation training with ElevenLabs
- 📚 **Interactive Lessons** - Auto-generated lessons for 4 languages
- 🎮 **Gamification** - XP, streaks, leaderboards, and achievements
- 👥 **Community** - Friends, blog feed, and study groups
- 🌍 **Multi-language UI** - Thai and English interface support

---

## ✨ Features

### 🤖 AI-Powered Learning
- **Conversational AI Tutor** using Google Gemini API
- Real-time streaming responses
- Context-aware conversations
- Personalized learning recommendations

### 🎤 Voice Features
- **Speech-to-Text** for pronunciation practice
- **Text-to-Speech** with ElevenLabs natural voices
- Real-time pronunciation analysis
- Voice-driven interaction with AI

### 📚 Comprehensive Lessons
- **4 Languages**: Japanese (N5-N1), English (Beginner-Advanced), Chinese (HSK1-6), Korean (TOPIK1-6)
- **Auto-generated lessons** from free APIs (Jisho, Tatoeba, GitHub)
- Multiple question types: Multiple Choice, Reading, Writing, Speaking
- Progress tracking and lesson locking system

### 🎮 Gamification
- XP system and daily streaks
- Leaderboard with friends
- Achievement badges
- Daily quests and challenges

### 👥 Social Features
- Friend system with follow/unfollow
- Blog feed for finding study partners
- Community rooms and groups
- Social learning experience

### 📊 Learning Analytics
- Detailed progress tracking
- Statistics and charts
- Vocabulary management
- Learning history

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase account
- Google Gemini API key
- ElevenLabs API key (optional)

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/flutter_ai_learning_app.git
cd flutter_ai_learning_app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure API Keys

1. Copy the example config file:
   ```bash
   cp lib/config/api_config.example.dart lib/config/api_config.dart
   ```

2. Edit `lib/config/api_config.dart` and add your API keys:
   ```dart
   static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
   static const String elevenLabsApiKey = 'YOUR_ELEVENLABS_API_KEY';
   ```

   **Get API Keys:**
   - **Google Gemini**: https://aistudio.google.com/app/apikey
   - **ElevenLabs**: https://elevenlabs.io/app/settings/api-keys

### Step 4: Setup Firebase

Follow the detailed guide in [`FIREBASE_QUICK_START.md`](FIREBASE_QUICK_START.md):

1. Create a Firebase project
2. Add Android app
3. Download `google-services.json`
4. Place it in `android/app/`

### Step 5: Run the App

```bash
# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d pixel_6_-_api_34_naphat
```

---

## 🛠️ Tech Stack

### Core Technologies
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Firebase** - Backend infrastructure
  - Authentication
  - Cloud Firestore
  - Google Sign-In

### AI & Voice
- **Google Gemini API** - Conversational AI
- **ElevenLabs API** - Text-to-Speech & Speech-to-Text

### Key Libraries
- `google_generative_ai` - Gemini integration
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Firebase services
- `speech_to_text` - Speech recognition
- `audioplayers` - Audio playback
- `google_fonts` - Typography (Kanit)
- `flutter_animate` - Animations
- `fl_chart` - Data visualization
- `shared_preferences` - Local storage

### APIs & Services
- **Jisho API** - Japanese dictionary
- **Tatoeba API** - Example sentences
- **GitHub Frequency Words** - Vocabulary lists

---

## 📁 Project Structure

```
lib/
├── config/              # API configuration
├── models/              # Data models
├── pages/               # UI pages
│   ├── home_page.dart
│   ├── ai_tutor_page.dart
│   ├── lesson_list_page.dart
│   └── ...
├── services/            # Business logic
│   ├── ai_service.dart
│   ├── lesson_manager.dart
│   └── ...
├── widgets/             # Reusable widgets
├── main.dart            # App entry point
└── user_data.dart       # State management
```

---

## 🎨 Screenshots

*Add screenshots here*

- Home Screen
- AI Tutor
- Lesson Detail
- Pronunciation Practice
- Leaderboard
- Profile

---

## 📖 Documentation

- [`HACKATHON_SUBMISSION.md`](HACKATHON_SUBMISSION.md) - Hackathon submission details
- [`GITHUB_SETUP.md`](GITHUB_SETUP.md) - GitHub setup guide
- [`FIREBASE_QUICK_START.md`](FIREBASE_QUICK_START.md) - Firebase setup
- [`API_KEYS_SETUP.md`](API_KEYS_SETUP.md) - API keys configuration

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Google Cloud for Firebase and Gemini API
- ElevenLabs for voice technology
- Flutter team for the amazing framework
- Open source community for free APIs and libraries

---

## 📧 Contact

- **GitHub**: [@your-username](https://github.com/your-username)
- **Email**: your-email@example.com

---

## 🏆 Hackathon

This project was created for the **AI Partner Catalyst Hackathon**.

**Submission Details:**
- See [`HACKATHON_SUBMISSION.md`](HACKATHON_SUBMISSION.md) for complete submission information
- **Try it out**: https://github.com/YOUR_USERNAME/flutter_ai_learning_app

---

<div align="center">

**Made with ❤️ for language learners worldwide**

⭐ Star this repo if you find it helpful!

</div>
