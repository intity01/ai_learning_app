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
├── config/         # API keys and constants
├── models/         # Data models (User, Lesson, Chat)
├── pages/          # UI Screens (Home, Tutor, Profile)
├── services/       # Logic (AI Service, Firebase, Audio)
├── widgets/        # Reusable UI components
└── main.dart       # Entry point
