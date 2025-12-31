# 🔐 คู่มือตั้งค่า Google Sign-In

## ✅ สิ่งที่แก้ไขแล้ว

1. ✅ เพิ่ม `google_sign_in` package ใน `pubspec.yaml`
2. ✅ เพิ่ม `signInWithGoogle()` method ใน `AuthServiceFirebase`
3. ✅ แก้ไข `signup_login_page.dart` ให้ใช้ Google Sign-In เป็นหลัก
4. ✅ UI แสดงปุ่ม "เข้าสู่ระบบด้วย Google" เป็นหลัก

---

## 🎯 วิธี Enable Google Sign-In ใน Firebase Console

### **Step 1: Enable Google Authentication**

1. ไปที่ [Firebase Console](https://console.firebase.google.com/)
2. เลือกโปรเจกต์ `cominiti`
3. คลิก **"Authentication"** (เมนูซ้าย)
4. คลิก **"Get started"** (ถ้ามี)
5. ไปที่แท็บ **"Sign-in method"**
6. คลิก **"Google"**
7. เปิดสวิตช์ **"Enable"**
8. เลือก **"Project support email"** (อีเมลที่ใช้สำหรับโปรเจกต์)
9. คลิก **"Save"**

---

### **Step 2: Enable Firestore Database**

1. คลิก **"Firestore Database"** (เมนูซ้าย)
2. คลิก **"Create database"** (ถ้ายังไม่มี)
3. เลือก **"Start in test mode"**
4. คลิก **"Next"**
5. เลือก Location: **`asia-southeast1`** (Singapore)
6. คลิก **"Enable"**

---

### **Step 3: Configure SHA-1 Fingerprint (สำหรับ Android)**

**สำหรับ Android Emulator/Device:**

1. เปิด Terminal/PowerShell
2. รันคำสั่ง:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   หรือสำหรับ Windows:
   ```powershell
   cd android
   .\gradlew.bat signingReport
   ```

3. คัดลอก **SHA-1 fingerprint** (ดูที่ `Variant: debug` → `SHA1:`)

4. ไปที่ Firebase Console → **Project Settings** → **Your apps** → เลือก Android app

5. คลิก **"Add fingerprint"** → วาง SHA-1 fingerprint → **Save**

---

## 🧪 วิธีทดสอบ

### **Step 1: รันแอป**

```bash
flutter run -d emulator-5554
```

### **Step 2: ทดสอบ Google Sign-In**

1. **ผ่าน Onboarding:**
   - ผ่าน Onboarding Pages
   - ตอบคำถาม Onboarding Questions
   - ผ่าน Loading Plan
   - ไปหน้า Sign Up/Login

2. **กดปุ่ม "เข้าสู่ระบบด้วย Google":**
   - ควรเปิด Google Sign-In dialog
   - เลือก Google Account
   - อนุญาตการเข้าถึง

3. **ตรวจสอบผลลัพธ์:**
   - ✅ ควรไปหน้า MainScreen
   - ✅ ตรวจสอบใน Firebase Console → **Authentication → Users**
     - ควรเห็น user ใหม่ที่มี email จาก Google Account
   - ✅ ตรวจสอบใน Firebase Console → **Firestore Database → Collection `users`**
     - ควรเห็น document ใหม่ที่มีข้อมูล user profile

---

## 🐛 Troubleshooting

### **ปัญหา: "Google Sign-In failed: PlatformException(...)"**

**สาเหตุ:** Google Sign-In ยังไม่ได้ Enable ใน Firebase Console

**แก้ไข:**
1. ไปที่ Firebase Console → Authentication → Sign-in method
2. Enable Google
3. เลือก Project support email
4. Save

---

### **ปัญหา: "DEVELOPER_ERROR" หรือ "10:"**

**สาเหตุ:** SHA-1 fingerprint ยังไม่ได้เพิ่มใน Firebase Console

**แก้ไข:**
1. รัน `./gradlew signingReport` (หรือ `.\gradlew.bat signingReport` สำหรับ Windows)
2. คัดลอก SHA-1 fingerprint
3. ไปที่ Firebase Console → Project Settings → Your apps → Android app
4. เพิ่ม SHA-1 fingerprint
5. Save
6. รันแอปใหม่

---

### **ปัญหา: "Sign-In dialog ไม่เปิด"**

**สาเหตุ:** 
- Google Play Services ไม่ได้ติดตั้งใน Emulator
- หรือ SHA-1 fingerprint ไม่ถูกต้อง

**แก้ไข:**
1. ตรวจสอบว่า Emulator มี Google Play Services
2. ตรวจสอบ SHA-1 fingerprint ใน Firebase Console
3. รันแอปใหม่

---

### **ปัญหา: "User ยกเลิกการ Sign-In"**

**สาเหตุ:** User กด Cancel หรือปิด dialog

**แก้ไข:** ไม่ต้องแก้ไข - เป็นพฤติกรรมปกติ

---

## ✅ Checklist

### **Before Testing:**
- [ ] Enable Google Sign-In ใน Firebase Console
- [ ] Enable Firestore Database ใน Firebase Console
- [ ] เพิ่ม SHA-1 fingerprint ใน Firebase Console (สำหรับ Android)
- [ ] แอปรันได้ (ไม่มี errors)

### **Testing:**
- [ ] Google Sign-In dialog เปิดได้
- [ ] เลือก Google Account ได้
- [ ] Sign-In สำเร็จ
- [ ] ตรวจสอบใน Firebase Console → Authentication → Users
- [ ] ตรวจสอบใน Firestore → Collection `users`
- [ ] ไปหน้า MainScreen ได้
- [ ] Skip (Lazy Registration) ทำงานได้

---

## 📝 Expected Results

### **After Google Sign-In:**
1. ✅ User ถูกสร้างใน Firebase Authentication (Provider: `google.com`)
2. ✅ User Profile ถูกบันทึกใน Firestore → Collection `users`
   - `uid`: Firebase User UID
   - `username`: Google Display Name
   - `email`: Google Email
   - `avatarUrl`: Google Photo URL (ถ้ามี)
   - `nativeLanguage`: 'th' (default)
   - `targetLanguage`: 'jp' (default)
   - `currentLevel`: 'Beginner' (default)
   - `dailyGoalMinutes`: 15 (default)
3. ✅ ไปหน้า MainScreen
4. ✅ Onboarding เสร็จแล้ว (เปิดแอปใหม่ → ไม่แสดง Onboarding)

---

## 🔄 Next Sign-In

เมื่อ Sign-In ครั้งต่อไป:
- ✅ User Profile จะถูกโหลดจาก Firestore
- ✅ `lastLoginAt` จะถูกอัปเดต
- ✅ ไม่ต้องสร้าง User Profile ใหม่

---

**พร้อมทดสอบแล้ว!** 🚀

