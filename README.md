# Learning Language - AI-Powered Application

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A cross-platform mobile application for learning Japanese, English, Chinese, and Korean. The app leverages Google Gemini for conversational AI tutoring and ElevenLabs for realistic voice interactions, combined with gamification elements to enhance engagement.

[Live Demo](https://YOUR_USERNAME.github.io/flutter_ai_learning_app/) | [Report Bug](https://github.com/YOUR_USERNAME/flutter_ai_learning_app/issues)

## Features

* **AI Tutor:** Real-time conversation practice using Google Gemini API with context awareness.
* **Voice Integration:** Speech-to-Text for pronunciation checks and Text-to-Speech using ElevenLabs.
* **Curriculum:** Auto-generated lessons for 4 languages (JP, EN, CN, KR) sourced from public APIs (Jisho, Tatoeba).
* **Gamification:** Experience points (XP), daily streaks, leaderboards, and achievement badges.
* **Social:** Friend system, activity feeds, and community groups.
* **Analytics:** Detailed progress tracking and vocabulary retention statistics.

## Tech Stack

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Auth, Firestore)
* **AI Services:** Google Gemini API, ElevenLabs API
* **Key Packages:** `google_generative_ai`, `speech_to_text`, `audioplayers`, `fl_chart`, `provider`

## Installation

### Prerequisites
* Flutter SDK (3.0.0+)
* Firebase Project
* API Keys (Google Gemini, ElevenLabs)

### Setup Steps

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/flutter_ai_learning_app.git](https://github.com/YOUR_USERNAME/flutter_ai_learning_app.git)
    cd flutter_ai_learning_app
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Environment**
    Create `lib/config/api_config.dart` from the example file and add your keys:
    ```dart
    static const String geminiApiKey = 'YOUR_GEMINI_KEY';
    static const String elevenLabsApiKey = 'YOUR_ELEVENLABS_KEY';
    ```

4.  **Firebase Setup**
    Place your `google-services.json` file in the `android/app/` directory.

5.  **Run Application**
    ```bash
    flutter run
    ```

## Project Structure

```text
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

## 🌐 Try it Online

**Live Demo:** [https://YOUR_USERNAME.github.io/flutter_ai_learning_app/](https://YOUR_USERNAME.github.io/flutter_ai_learning_app/)

> ⚠️ **Setup Required:** 
> - ดูคู่มือการตั้งค่า GitHub Pages: [`GITHUB_PAGES_SETUP.md`](GITHUB_PAGES_SETUP.md)
> - แทนที่ `YOUR_USERNAME` ด้วย GitHub username ของคุณ

---

## 📖 Documentation

- [`GITHUB_PAGES_SETUP.md`](GITHUB_PAGES_SETUP.md) - 🌐 GitHub Pages deployment guide
- [`HACKATHON_SUBMISSION.md`](HACKATHON_SUBMISSION.md) - Hackathon submission details
- [`GITHUB_SETUP.md`](GITHUB_SETUP.md) - GitHub repository setup guide
- [`FIREBASE_QUICK_START.md`](FIREBASE_QUICK_START.md) - Firebase setup
- [`API_KEYS_SETUP.md`](API_KEYS_SETUP.md) - API keys configuration
- [`SECURITY.md`](SECURITY.md) - 🔒 Security policy and vulnerability reporting

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

## 🔒 Security

For security vulnerabilities, please see our [Security Policy](SECURITY.md) and report them privately. **Do not** open public issues for security vulnerabilities.

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
- **🌐 Live Demo**: https://YOUR_USERNAME.github.io/flutter_ai_learning_app/
- **📦 Repository**: https://github.com/YOUR_USERNAME/flutter_ai_learning_app

---

<div align="center">

**Made with ❤️ for language learners worldwide**

⭐ Star this repo if you find it helpful!

</div>
