# ✅ Hackathon Submission Checklist

## 📋 Pre-Submission Checklist

### 🔒 Security & Privacy
- [ ] **API Keys ไม่ถูก commit**
  - ตรวจสอบ: `git check-ignore lib/config/api_config.dart`
  - ไฟล์ `api_config.dart` อยู่ใน `.gitignore`
  - มี `api_config.example.dart` สำหรับ reference

- [ ] **ไม่มีข้อมูลส่วนตัวในโค้ด**
  - ไม่มี password, token, หรือ credentials
  - ตรวจสอบไฟล์ทั้งหมด: `git diff`

- [ ] **Firebase Config**
  - `google-services.json` สามารถ commit ได้ (public repo)
  - หรือ comment ใน `.gitignore` ถ้าต้องการ private

---

### 📝 Documentation
- [ ] **README.md** - มีข้อมูลครบถ้วน
  - Overview และ features
  - Installation instructions
  - Setup guide
  - Tech stack
  - Screenshots (ถ้ามี)

- [ ] **HACKATHON_SUBMISSION.md** - ข้อมูลสำหรับ hackathon
  - Google Cloud products used
  - Other tools/products
  - Project Story (Inspiration, What it does, How we built it, etc.)
  - Built with
  - Try it out links (GitHub)

- [ ] **LICENSE** - มีไฟล์ LICENSE (MIT recommended)

- [ ] **Setup Guides**
  - `GITHUB_SETUP.md` หรือ `GITHUB_QUICK_START.md`
  - `FIREBASE_QUICK_START.md`
  - `API_KEYS_SETUP.md`

---

### 🚀 GitHub Repository
- [ ] **Repository เป็น Public**
  - ตรวจสอบ: Settings → Danger Zone → Change repository visibility

- [ ] **Repository มีข้อมูลครบ**
  - Description
  - Topics/Tags (flutter, dart, firebase, ai, language-learning)
  - Website (ถ้ามี)

- [ ] **Code Quality**
  - Code ถูก format: `dart format .`
  - ไม่มี linter errors: `flutter analyze`
  - Comments และ documentation ครบถ้วน

---

### 🎯 Hackathon Requirements

#### Google Cloud Products
- [ ] **ระบุ Google Cloud products ที่ใช้**
  - Firebase Authentication ✅
  - Cloud Firestore ✅
  - Google Gemini API ✅
  - Google Sign-In ✅

#### Other Tools/Products
- [ ] **ระบุ tools/products อื่นๆ**
  - Flutter, Dart
  - ElevenLabs API
  - Jisho API, Tatoeba API
  - Libraries และ packages

#### Project Story
- [ ] **Inspiration** - อธิบายแรงบันดาลใจ
- [ ] **What it does** - อธิบายฟีเจอร์หลัก
- [ ] **How we built it** - อธิบาย architecture และ process
- [ ] **Challenges** - อธิบายปัญหาและวิธีแก้
- [ ] **Accomplishments** - สิ่งที่ภูมิใจ
- [ ] **What we learned** - สิ่งที่เรียนรู้
- [ ] **What's next** - แผนอนาคต

#### Try it out
- [ ] **GitHub Link** - ใส่ link ไปยัง repository
- [ ] **Installation Instructions** - วิธีติดตั้งและรัน
- [ ] **Demo Video** (optional) - Link ไปยัง YouTube/Vimeo
- [ ] **Screenshots** - ภาพหน้าจอสำคัญ

#### Project Media
- [ ] **Image Gallery** - ภาพหน้าจอ (JPG/PNG/GIF, max 5MB, 3:2 ratio)
  - Home Screen
  - AI Tutor
  - Lesson Detail
  - Pronunciation Practice
  - Leaderboard
  - Profile
  - Settings
  - Community

---

### 🧪 Testing
- [ ] **App รันได้บน Android Emulator**
  - ไม่มี compile errors
  - ไม่มี runtime errors
  - Features ทำงานได้

- [ ] **Features หลักทำงาน**
  - [ ] Authentication (Firebase)
  - [ ] AI Tutor (Gemini API)
  - [ ] Voice features (ElevenLabs)
  - [ ] Lessons
  - [ ] Community features

---

### 📦 Final Steps
- [ ] **Commit และ Push ทุกไฟล์**
  ```bash
  git add .
  git commit -m "chore: Prepare for hackathon submission"
  git push
  ```

- [ ] **ตรวจสอบบน GitHub**
  - ไฟล์ทั้งหมดถูก push แล้ว
  - README.md แสดงผลถูกต้อง
  - Links ทำงานได้

- [ ] **Copy GitHub Link**
  - https://github.com/YOUR_USERNAME/flutter_ai_learning_app

- [ ] **Submit บน Hackathon Platform**
  - ใส่ข้อมูลจาก `HACKATHON_SUBMISSION.md`
  - Upload screenshots
  - ใส่ GitHub link

---

## 🎉 Ready to Submit!

เมื่อ checklist ทั้งหมดถูก check แล้ว → **พร้อมส่ง hackathon!**

---

## 📞 Need Help?

- ดู [`GITHUB_SETUP.md`](GITHUB_SETUP.md) สำหรับ GitHub setup
- ดู [`HACKATHON_SUBMISSION.md`](HACKATHON_SUBMISSION.md) สำหรับ submission details
- ดู [`README.md`](README.md) สำหรับ project overview

---

**Good luck! 🚀**

