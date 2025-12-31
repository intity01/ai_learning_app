# 🚀 Learning Language - Hackathon Submission

## 📋 Project Information

**Project Name:** Learning Language  
**Team Name:** [Your Team Name]  
**Hackathon:** AI Partner Catalyst Hackathon  
**Category:** ElevenLabs Challenge / Google Cloud Challenge

---

## 🔥 Google Cloud Products Used

### Primary Products:
1. **Firebase Authentication** - User authentication with Google Sign-In
2. **Cloud Firestore** - NoSQL database for user profiles, progress, and learning data
3. **Google Gemini API (via google_generative_ai)** - AI-powered conversational tutor for language learning

### Additional Google Services:
- **Google Sign-In** - Seamless authentication experience
- **Firebase Core** - Backend infrastructure

---

## 🛠️ Other Tools & Products Used

### Development Framework:
- **Flutter** - Cross-platform mobile app framework
- **Dart** - Programming language

### AI & Voice Services:
- **ElevenLabs API** - Text-to-Speech (TTS) and Speech-to-Text (STT) for voice interaction
- **Google Gemini 1.5 Flash** - Conversational AI for personalized tutoring

### UI/UX Libraries:
- **Google Fonts (Kanit)** - Beautiful Thai and English typography
- **Flutter Animate** - Smooth animations
- **fl_chart** - Data visualization for learning statistics

### Backend & Storage:
- **SharedPreferences** - Local data persistence
- **HTTP** - API communication

### APIs & Data Sources:
- **Jisho API** - Japanese dictionary data
- **Tatoeba API** - Example sentences in multiple languages
- **GitHub Frequency Words** - Common vocabulary lists
- **DiceBear API** - Cartoon avatar generation

### Development Tools:
- **Android Studio** - IDE
- **Git** - Version control
- **Firebase Console** - Backend management

---

## 📖 Project Story

### 💡 Inspiration

Learning a new language can be challenging, especially when you don't have access to native speakers or personalized feedback. Traditional language learning apps often lack:
- Real-time conversational practice
- Voice-based pronunciation feedback
- AI-powered personalized tutoring
- Community engagement

We were inspired to create **Learning Language** - an AI-powered language learning app that combines:
- **Conversational AI** for natural language practice
- **Voice interaction** for pronunciation training
- **Gamification** to keep learners motivated
- **Community features** for collaborative learning

### 🎯 What it does

**Learning Language** is a comprehensive mobile app for learning Japanese, English, Chinese, and Korean with:

1. **AI Tutor** 🤖
   - Real-time conversational practice with Google Gemini
   - Voice-to-voice interaction using Speech-to-Text
   - Personalized learning recommendations
   - Context-aware responses

2. **Interactive Lessons** 📚
   - Structured lessons by language and level (JP: N5-N1, EN: Beginner-Advanced, CN: HSK1-6, KR: TOPIK1-6)
   - Multiple question types: Multiple Choice, Reading, Writing, Speaking
   - Auto-generated lessons from free APIs (Jisho, Tatoeba, GitHub Frequency Words)
   - Progress tracking and lesson locking system

3. **Pronunciation Practice** 🎤
   - Real-time speech recognition
   - Pronunciation analysis using Levenshtein distance algorithm
   - Audio playback with ElevenLabs TTS
   - Visual feedback on pronunciation accuracy

4. **Gamification** 🎮
   - XP system and daily streaks
   - Leaderboard with friends
   - Achievement badges
   - Daily quests and challenges

5. **Community Features** 👥
   - Friend system with follow/unfollow
   - Blog feed for finding study partners
   - Community rooms and groups
   - Social learning experience

6. **Vocabulary Management** 📝
   - Personal vocabulary list
   - Lesson-based vocabulary
   - Custom word additions
   - Progress tracking

7. **Multi-language Support** 🌍
   - UI available in Thai and English
   - Auto-detects device language
   - Learning languages: Japanese, English, Chinese, Korean

### 🔨 How we built it

#### Architecture:
- **Frontend:** Flutter (Dart) with Material Design 3
- **Backend:** Firebase (Authentication + Firestore)
- **AI:** Google Gemini API for conversational AI
- **Voice:** ElevenLabs API for TTS/STT

#### Development Process:

1. **Foundation (Week 1)**
   - Set up Flutter project structure
   - Implemented user authentication with Firebase
   - Created onboarding flow
   - Built core UI components

2. **AI Integration (Week 2)**
   - Integrated Google Gemini API
   - Built AI Tutor page with real-time streaming
   - Implemented conversation history
   - Added context-aware responses

3. **Voice Features (Week 3)**
   - Integrated ElevenLabs TTS
   - Implemented Speech-to-Text with `speech_to_text` package
   - Built pronunciation analysis algorithm
   - Created pronunciation practice page

4. **Lesson System (Week 4)**
   - Created lesson management system
   - Integrated free APIs (Jisho, Tatoeba, GitHub)
   - Built auto-lesson generator
   - Implemented progress tracking

5. **Community & Polish (Week 5)**
   - Added friend system
   - Built blog feed
   - Implemented leaderboard
   - UI/UX improvements and bug fixes

#### Key Technical Decisions:

- **State Management:** ValueNotifier for reactive UI updates
- **Localization:** Custom AppStrings system with device language detection
- **Data Persistence:** SharedPreferences for local data, Firestore for cloud sync
- **API Integration:** Modular service architecture for easy maintenance

### 🚧 Challenges we ran into

1. **Voice Integration Complexity**
   - **Challenge:** Synchronizing Speech-to-Text, TTS, and AI responses in real-time
   - **Solution:** Implemented async/await patterns and proper state management

2. **Pronunciation Analysis**
   - **Challenge:** Accurately evaluating pronunciation without expensive APIs
   - **Solution:** Used Levenshtein distance algorithm combined with character similarity scoring

3. **Multi-language Support**
   - **Challenge:** Managing UI language vs. learning language separately
   - **Solution:** Created separate ValueNotifiers and localization system

4. **Lesson Generation**
   - **Challenge:** Finding free, reliable APIs for vocabulary and example sentences
   - **Solution:** Combined multiple free APIs (Jisho, Tatoeba, GitHub) with fallback mechanisms

5. **Real-time AI Streaming**
   - **Challenge:** Displaying AI responses as they're generated
   - **Solution:** Used `generateContentStream` from Google Gemini API with StreamBuilder

6. **Firebase Authentication**
   - **Challenge:** Setting up Google Sign-In with SHA-1 fingerprint
   - **Solution:** Created PowerShell script to automate SHA-1 extraction

### 🏆 Accomplishments we're proud of

1. **Complete AI-Powered Learning Experience**
   - Successfully integrated Google Gemini for natural conversations
   - Real-time voice interaction working smoothly
   - Context-aware AI that remembers conversation history

2. **Comprehensive Lesson System**
   - Auto-generated lessons from free APIs
   - Support for 4 languages with multiple levels
   - Multiple question types (MCQ, Reading, Writing, Speaking)

3. **Beautiful & Intuitive UI**
   - Modern Material Design 3 interface
   - Smooth animations and transitions
   - Responsive layout for different screen sizes
   - Multi-language UI with auto-detection

4. **Robust Architecture**
   - Clean code structure with separation of concerns
   - Modular service architecture
   - Proper error handling and loading states
   - Scalable data models

5. **Community Features**
   - Friend system with real-time updates
   - Blog feed for collaboration
   - Leaderboard with gamification

6. **Voice Features**
   - Accurate pronunciation analysis
   - Natural-sounding TTS with ElevenLabs
   - Real-time speech recognition

### 📚 What we learned

1. **AI Integration Best Practices**
   - How to effectively use Google Gemini API for conversational AI
   - Managing conversation context and history
   - Implementing streaming responses for better UX

2. **Voice Technology**
   - Speech-to-Text implementation challenges
   - TTS integration and audio playback
   - Pronunciation analysis algorithms

3. **Flutter Development**
   - Advanced state management with ValueNotifier
   - Custom localization systems
   - Material Design 3 implementation

4. **Firebase Services**
   - Authentication flows
   - Firestore data modeling
   - Real-time database synchronization

5. **API Integration**
   - Working with multiple free APIs
   - Error handling and fallback mechanisms
   - Data transformation and caching

6. **Project Management**
   - Breaking down complex features into manageable tasks
   - Prioritizing features for MVP
   - Balancing functionality with polish

### 🚀 What's next for Learning Language

#### Short-term (Next 1-2 months):
1. **Enhanced AI Features**
   - Multi-turn conversation improvements
   - Personalized learning path recommendations
   - Adaptive difficulty based on user performance

2. **More Languages**
   - Add more learning languages (Spanish, French, German)
   - Expand vocabulary databases

3. **Advanced Voice Features**
   - Real-time pronunciation correction
   - Voice cloning for personalized TTS
   - Conversation practice with AI avatars

4. **Community Enhancements**
   - Video/voice calls between friends
   - Study groups and challenges
   - User-generated content (lessons, vocabulary lists)

#### Medium-term (3-6 months):
1. **Offline Mode**
   - Download lessons for offline learning
   - Sync progress when online

2. **Advanced Analytics**
   - Detailed learning insights
   - Weak area identification
   - Progress predictions

3. **Gamification Expansion**
   - More achievement types
   - Seasonal events and challenges
   - Rewards system

4. **Content Expansion**
   - Professional/career-specific lessons
   - Cultural context lessons
   - News and media content

#### Long-term (6+ months):
1. **AI Tutor Improvements**
   - Multi-modal AI (text, voice, image)
   - Emotion recognition for better feedback
   - Personalized learning style adaptation

2. **Platform Expansion**
   - Web version
   - Desktop applications
   - Smartwatch integration

3. **Enterprise Features**
   - Team learning for companies
   - Progress reports for educators
   - Custom curriculum creation

4. **Monetization**
   - Premium features (advanced AI, unlimited lessons)
   - Subscription tiers
   - Marketplace for user-generated content

---

## 🛠️ Built With

### Core Technologies:
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Firebase** - Backend infrastructure
- **Google Gemini API** - AI conversational engine
- **ElevenLabs API** - Voice synthesis and recognition

### Key Libraries:
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Firebase services
- `google_generative_ai` - Google Gemini integration
- `google_sign_in` - Authentication
- `speech_to_text` - Speech recognition
- `audioplayers` - Audio playback
- `record` - Audio recording
- `google_fonts` - Typography
- `flutter_animate` - Animations
- `fl_chart` - Data visualization
- `shared_preferences` - Local storage
- `http` - API communication

### APIs & Services:
- **Jisho API** - Japanese dictionary
- **Tatoeba API** - Example sentences
- **GitHub Frequency Words** - Vocabulary lists
- **DiceBear API** - Avatar generation

---

## 🔗 Try it out

### GitHub Repository:
**https://github.com/[YOUR_USERNAME]/flutter_ai_learning_app**

### Installation Instructions:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/[YOUR_USERNAME]/flutter_ai_learning_app.git
   cd flutter_ai_learning_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys:**
   - Create `lib/config/api_config.dart` (see `API_KEYS_SETUP.md`)
   - Add your Google Gemini API key
   - Add your ElevenLabs API key (optional)

4. **Setup Firebase:**
   - Follow instructions in `FIREBASE_QUICK_START.md`
   - Download `google-services.json` and place in `android/app/`

5. **Run the app:**
   ```bash
   flutter run
   ```

### Demo Video:
[Link to demo video on YouTube/Vimeo]

### Screenshots:
[Add screenshots of key features]

---

## 📸 Project Media

### Image Gallery:
1. **Home Screen** - Main dashboard with daily quests
2. **AI Tutor** - Conversational interface with voice
3. **Lesson Detail** - Interactive lesson with progress
4. **Pronunciation Practice** - Voice training interface
5. **Leaderboard** - Gamification and rankings
6. **Profile** - User profile with friends
7. **Settings** - Language and account settings
8. **Community** - Blog feed and groups

*Note: Add actual screenshots in JPG/PNG/GIF format (max 5MB each, 3:2 ratio recommended)*

---

## 👥 Team

- **[Your Name]** - Lead Developer
- **[Team Member 2]** - [Role]
- **[Team Member 3]** - [Role]

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Google Cloud for Firebase and Gemini API
- ElevenLabs for voice technology
- Flutter team for the amazing framework
- Open source community for free APIs and libraries

---

## 📧 Contact

- **Email:** [your-email@example.com]
- **GitHub:** [@your-username]
- **LinkedIn:** [Your LinkedIn Profile]

---

**Made with ❤️ for the AI Partner Catalyst Hackathon**


