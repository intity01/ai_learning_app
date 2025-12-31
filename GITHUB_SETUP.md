# 🚀 GitHub Setup Guide

## 📋 ขั้นตอนการเชื่อม GitHub และ Push โปรเจกต์

### **Step 1: สร้าง GitHub Repository**

1. ไปที่ [GitHub](https://github.com) และล็อกอิน
2. คลิก **"+"** → **"New repository"**
3. ตั้งชื่อ repository (เช่น `flutter_ai_learning_app`)
4. เลือก **Public** (สำหรับ hackathon submission)
5. **อย่า** check "Initialize with README" (เพราะเรามีไฟล์อยู่แล้ว)
6. คลิก **"Create repository"**

---

### **Step 2: ตรวจสอบ Git Status**

เปิด Terminal/PowerShell ในโฟลเดอร์โปรเจกต์:

```bash
# ตรวจสอบว่าเป็น Git repository หรือยัง
git status
```

ถ้ายังไม่ใช่ Git repository:

```bash
# Initialize Git
git init
```

---

### **Step 3: เพิ่ม Remote Repository**

```bash
# เพิ่ม remote (แทนที่ YOUR_USERNAME และ REPO_NAME ด้วยข้อมูลของคุณ)
git remote add origin https://github.com/YOUR_USERNAME/flutter_ai_learning_app.git

# ตรวจสอบ remote
git remote -v
```

---

### **Step 4: เพิ่มไฟล์ทั้งหมด**

```bash
# เพิ่มไฟล์ทั้งหมด (ยกเว้นที่อยู่ใน .gitignore)
git add .

# ตรวจสอบไฟล์ที่จะ commit
git status
```

**⚠️ ตรวจสอบว่าไม่มีไฟล์สำคัญถูก commit:**
- `lib/config/api_config.dart` (API keys)
- `.env` files
- ไฟล์ส่วนตัวอื่นๆ

---

### **Step 5: Commit ครั้งแรก**

```bash
# Commit ครั้งแรก
git commit -m "Initial commit: Flutter AI Learning App for Hackathon"

# หรือ commit message ที่ละเอียดกว่า
git commit -m "feat: Complete Flutter AI Learning App

- AI Tutor with Google Gemini API
- Voice features with ElevenLabs
- Interactive lessons for 4 languages
- Firebase authentication and Firestore
- Community features (friends, blog, leaderboard)
- Multi-language UI support (Thai/English)
- Gamification system (XP, streaks, achievements)"
```

---

### **Step 6: Push ไป GitHub**

```bash
# Push ไป main branch
git branch -M main
git push -u origin main
```

ถ้าเจอ error เกี่ยวกับ authentication:

**Option 1: ใช้ Personal Access Token**
1. ไปที่ GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → เลือก scopes: `repo`
3. Copy token
4. เมื่อ push จะถาม username/password → ใช้ token แทน password

**Option 2: ใช้ GitHub CLI**
```bash
# ติดตั้ง GitHub CLI (ถ้ายังไม่มี)
# Windows: winget install GitHub.cli

# Login
gh auth login

# Push
git push -u origin main
```

---

### **Step 7: ตรวจสอบบน GitHub**

1. ไปที่ repository บน GitHub
2. ตรวจสอบว่าไฟล์ทั้งหมดถูก push แล้ว
3. ตรวจสอบ README.md แสดงผลถูกต้อง

---

## 🔒 Security Checklist

ก่อน push ไป GitHub ตรวจสอบว่า:

- [ ] **API Keys ไม่ถูก commit**
  - ตรวจสอบว่า `lib/config/api_config.dart` อยู่ใน `.gitignore`
  - ใช้ `git check-ignore lib/config/api_config.dart` เพื่อตรวจสอบ

- [ ] **Firebase Config**
  - `google-services.json` สามารถ commit ได้ถ้าเป็น public repo
  - แต่ถ้าเป็น private repo อาจจะไม่ควร commit

- [ ] **ไม่มีข้อมูลส่วนตัว**
  - ไม่มี password, token, หรือ credentials ในโค้ด
  - ตรวจสอบไฟล์ทั้งหมดด้วย `git diff` ก่อน commit

---

## 📝 สร้าง API Config Template

สร้างไฟล์ `lib/config/api_config.example.dart` เพื่อให้คนอื่นรู้ว่าต้องตั้งค่าอะไร:

```dart
// api_config.example.dart
// Copy this file to api_config.dart and fill in your API keys

class ApiConfig {
  // Google Gemini API Key
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // ElevenLabs API Key (optional)
  static const String elevenLabsApiKey = 'YOUR_ELEVENLABS_API_KEY_HERE';
  
  // Jira API (if using)
  static const String jiraEmail = 'YOUR_EMAIL@example.com';
  static const String jiraApiToken = 'YOUR_JIRA_API_TOKEN';
}
```

---

## 🔄 การ Update Code ในอนาคต

```bash
# 1. ตรวจสอบการเปลี่ยนแปลง
git status

# 2. เพิ่มไฟล์ที่เปลี่ยนแปลง
git add .

# 3. Commit
git commit -m "feat: Add new feature description"

# 4. Push
git push
```

---

## 🌿 สร้าง Branch สำหรับ Features

```bash
# สร้าง branch ใหม่
git checkout -b feature/new-feature

# ทำงานบน branch นี้
# ... make changes ...

# Commit และ push
git add .
git commit -m "feat: Add new feature"
git push -u origin feature/new-feature

# สร้าง Pull Request บน GitHub
# แล้ว merge กลับไป main branch
```

---

## 📚 Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com)
- [Flutter Git Best Practices](https://docs.flutter.dev/development/tools/version-control)

---

## ✅ Checklist สำหรับ Hackathon Submission

- [ ] Repository เป็น **Public**
- [ ] มี **README.md** ที่อธิบายโปรเจกต์
- [ ] มี **LICENSE** file (MIT recommended)
- [ ] มี **HACKATHON_SUBMISSION.md** พร้อมข้อมูลครบถ้วน
- [ ] Code ถูก format และ clean
- [ ] ไม่มี API keys ในโค้ด
- [ ] มี instructions สำหรับ setup และ run
- [ ] มี screenshots หรือ demo video link

---

**Happy Coding! 🚀**

