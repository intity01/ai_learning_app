# 🚀 Hackathon Roadmap - Flutter AI Learning App

## 🎯 Challenge ที่แนะนำ: **ElevenLabs Challenge**

**เหตุผล:**
- ✅ แอปเป็น **Language Learning App** → เหมาะกับ Voice Features
- ✅ มี **Voice Service** ที่ยังไม่ได้ implement → ใช้ ElevenLabs ได้เลย
- ✅ ต้องใช้ **Google Cloud Vertex AI/Gemini** → สำหรับ AI Tutor
- ✅ **Voice-driven interaction** → ทำให้แอปน่าสนใจและแตกต่าง

---

## 📋 Priority Tasks (เรียงตามความสำคัญ)

### **Phase 1: Foundation (1-2 วัน)** 🔥

#### 1.1 เชื่อมต่อ Onboarding Flow
- [ ] แก้ไข `main.dart` ให้ตรวจสอบ First Launch
- [ ] เพิ่ม Route สำหรับ Onboarding Pages
- [ ] แก้ไข `MainScreen` ให้นำทางไปยัง Onboarding
- [ ] ทดสอบ Onboarding Flow ทั้งหมด

**ไฟล์ที่ต้องแก้ไข:**
- `lib/main.dart`
- `lib/main_screen.dart`
- `lib/user_data.dart` - เพิ่ม `isFirstLaunch()` method

---

#### 1.2 เชื่อมต่อ Firebase
- [ ] Setup Firebase Project
- [ ] ติดตั้ง Firebase Dependencies
- [ ] แก้ไข `AuthService` ให้ใช้ Firebase
- [ ] Sync UserData กับ Firestore

**ไฟล์ที่ต้องแก้ไข:**
- `pubspec.yaml` - เพิ่ม dependencies
- `lib/services/auth_service.dart` - แก้ไขให้ใช้ Firebase
- `android/build.gradle` - เพิ่ม Firebase config
- `android/app/build.gradle` - เพิ่ม Firebase config

---

### **Phase 2: AI & Voice Integration (2-3 วัน)** 🎤🤖

#### 2.1 Implement AI Service (Google Cloud Vertex AI/Gemini)
- [ ] สร้าง `AIService` class
- [ ] เชื่อมต่อ Vertex AI หรือ Gemini API
- [ ] แก้ไข `AITutorPage` ให้ใช้ AI Service
- [ ] เพิ่ม Error Handling และ Loading States

**ไฟล์ที่ต้องแก้ไข:**
- `lib/services/ai_service.dart` - สร้างใหม่
- `lib/pages/ai_tutor_page.dart` - แก้ไขให้ใช้ AI Service
- `pubspec.yaml` - เพิ่ม `google_generative_ai` หรือ `googleapis`

**API ที่ต้องใช้:**
- Google Cloud Vertex AI หรือ Gemini API

---

#### 2.2 Implement Voice Service (ElevenLabs) 🎤
- [ ] สร้าง `VoiceService` class
- [ ] เชื่อมต่อ ElevenLabs API
- [ ] เพิ่ม Text-to-Speech สำหรับคำศัพท์
- [ ] เพิ่ม Speech-to-Text สำหรับการฝึกออกเสียง
- [ ] เพิ่มปุ่ม Play Sound ใน Vocabulary Page
- [ ] เพิ่มปุ่ม Play Sound ใน Lesson Detail Page

**ไฟล์ที่ต้องแก้ไข:**
- `lib/services/voice_service.dart` - สร้างใหม่
- `lib/pages/vocabulary_page.dart` - เพิ่มปุ่ม Play Sound
- `lib/pages/lesson_detail_page.dart` - เพิ่มปุ่ม Play Sound
- `pubspec.yaml` - เพิ่ม `http` package (มีอยู่แล้ว)

**API ที่ต้องใช้:**
- ElevenLabs API (Text-to-Speech, Speech-to-Text)

---

### **Phase 3: Polish & Optimization (1 วัน)** ✨

#### 3.1 แก้ไข Deprecation Warnings
- [ ] แก้ไข `withOpacity` → `withValues` (72 จุด)
- [ ] ใช้ Find & Replace ใน IDE

**ไฟล์ที่ต้องแก้ไข:**
- ทุกไฟล์ใน `lib/pages/`
- ทุกไฟล์ใน `lib/widgets/`

---

#### 3.2 Error Handling & Loading States
- [ ] เพิ่ม Error Handling ในทุก API calls
- [ ] เพิ่ม Loading States ในทุกหน้า
- [ ] เพิ่ม Skeleton Screens

---

## 🎯 ElevenLabs Challenge Requirements

### **Hard Requirements:**
1. ✅ ใช้ **ElevenLabs Agents** + **Google Cloud Vertex AI/Gemini**
2. ✅ ให้แอปมี **natural, human voice** และ **personality**
3. ✅ ผู้ใช้สามารถ **interact ผ่าน speech** ได้
4. ✅ ใช้ **React SDK** หรือ **server-side calls** บน Google Cloud

### **Implementation Plan:**

#### **Feature 1: Voice Tutor (AI + Voice)**
- ใช้ **Gemini API** สำหรับ AI responses
- ใช้ **ElevenLabs TTS** สำหรับเสียงพูด
- ผู้ใช้สามารถ **พูดกับ AI Tutor** ได้

#### **Feature 2: Pronunciation Practice**
- ใช้ **ElevenLabs Speech-to-Text** สำหรับตรวจสอบการออกเสียง
- ใช้ **ElevenLabs TTS** สำหรับตัวอย่างการออกเสียง
- แสดง feedback ว่าออกเสียงถูกต้องหรือไม่

#### **Feature 3: Vocabulary Pronunciation**
- เพิ่มปุ่ม Play Sound ใน Vocabulary Page
- ใช้ **ElevenLabs TTS** สำหรับออกเสียงคำศัพท์
- รองรับหลายภาษา (ญี่ปุ่น, อังกฤษ)

---

## 📝 Submission Requirements

### **What to Submit:**
1. ✅ **Hosted Application URL** - Deploy บน Google Cloud
2. ✅ **Public Repository** - GitHub with OSI license
3. ✅ **README** - Deployment instructions
4. ✅ **Demo Video** (3 minutes) - YouTube/Vimeo
5. ✅ **Devpost Submission Form**

### **Repository Requirements:**
- ✅ Public repository
- ✅ Open source license (MIT, Apache 2.0, etc.)
- ✅ README with deployment instructions
- ✅ All source code and assets

---

## 🛠️ Technical Stack

### **Frontend:**
- Flutter (Dart)
- Material Design 3
- Google Fonts (Kanit)

### **Backend:**
- Google Cloud Functions (สำหรับ API calls)
- Firebase Authentication
- Firestore Database

### **AI & Voice:**
- Google Cloud Vertex AI / Gemini API
- ElevenLabs API (TTS, STT, Agents)

### **Deployment:**
- Google Cloud Run (สำหรับ backend)
- Firebase Hosting (สำหรับ frontend หรือใช้ Flutter Web)

---

## 📊 Timeline

### **Day 1-2: Foundation**
- เชื่อมต่อ Onboarding Flow
- เชื่อมต่อ Firebase
- Setup Google Cloud Project

### **Day 3-4: AI Integration**
- Implement AI Service (Gemini)
- แก้ไข AI Tutor Page
- ทดสอบ AI responses

### **Day 5-6: Voice Integration**
- Implement Voice Service (ElevenLabs)
- เพิ่ม Voice features
- ทดสอบ Voice interaction

### **Day 7: Polish**
- แก้ไข Deprecation Warnings
- Error Handling
- Testing & Bug Fixes
- Create Demo Video
- Prepare Submission

---

## 🎨 Unique Selling Points

### **1. Voice-Driven Learning**
- ผู้ใช้สามารถ **พูดกับ AI Tutor** ได้
- **Pronunciation Practice** ด้วย Speech-to-Text
- **Natural Voice** ด้วย ElevenLabs

### **2. AI-Powered Personalization**
- AI Tutor จำการสนทนาก่อนหน้า
- แนะนำบทเรียนตามระดับ
- สร้างคำถามแบบ adaptive

### **3. Real-time Feedback**
- Error Feedback พร้อม explanation
- Voice feedback สำหรับการออกเสียง
- Progress tracking แบบ real-time

---

## 🚀 Next Steps

1. **เริ่มจาก Phase 1** - Foundation (Onboarding + Firebase)
2. **ต่อด้วย Phase 2** - AI & Voice Integration
3. **จบด้วย Phase 3** - Polish & Submission

---

**พร้อมเริ่มแล้ว! ต้องการให้ช่วยทำ Phase ไหนก่อน?** 🚀


