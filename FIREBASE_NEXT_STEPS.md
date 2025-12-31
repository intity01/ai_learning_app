# 🔥 Firebase - Next Steps

## ✅ สิ่งที่ทำไปแล้ว

1. ✅ เพิ่ม Firebase dependencies ใน `pubspec.yaml`
2. ✅ สร้าง `AuthServiceFirebase` class
3. ✅ แก้ไข `android/settings.gradle.kts` - เพิ่ม Google Services plugin
4. ✅ แก้ไข `android/app/build.gradle.kts` - เพิ่ม Firebase dependencies
5. ✅ เตรียมโค้ดใน `main.dart` สำหรับ initialize Firebase

---

## 📋 ขั้นตอนที่ต้องทำต่อ (Manual Steps)

### **Step 1: สร้าง Firebase Project** (5 นาที)

1. ไปที่ [Firebase Console](https://console.firebase.google.com/)
2. คลิก "Add project" หรือ "สร้างโปรเจกต์"
3. ตั้งชื่อโปรเจกต์ (เช่น "flutter-ai-learning-app")
4. เลือก Google Analytics (แนะนำ: เปิด)
5. คลิก "Create project"

---

### **Step 2: เพิ่ม Android App** (3 นาที)

1. ใน Firebase Console → คลิก "Add app" → เลือก **Android**
2. ใส่ข้อมูล:
   - **Android package name:** `com.example.flutter_ai_learning_app`
   - **App nickname:** (optional)
3. คลิก "Register app"
4. **ดาวน์โหลด `google-services.json`**
5. **วางไฟล์ `google-services.json` ใน `android/app/`**

---

### **Step 3: Enable Authentication & Firestore** (5 นาที)

#### **3.1 Enable Email/Password Authentication**

1. ใน Firebase Console → ไปที่ **Authentication**
2. คลิก "Get started"
3. ไปที่แท็บ **Sign-in method**
4. เปิด **Email/Password** → Enable → Save

#### **3.2 Enable Firestore Database**

1. ใน Firebase Console → ไปที่ **Firestore Database**
2. คลิก "Create database"
3. เลือก **Start in test mode** (สำหรับ development)
4. เลือก location (แนะนำ: `asia-southeast1` สำหรับไทย)
5. คลิก "Enable"

---

### **Step 4: Initialize Firebase ใน Flutter** (5 นาที)

#### **4.1 ติดตั้ง FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```

#### **4.2 Configure Firebase**

```bash
flutterfire configure
```

คำสั่งนี้จะ:
- เชื่อมต่อกับ Firebase project ของคุณ
- สร้างไฟล์ `lib/firebase_options.dart` อัตโนมัติ
- ตั้งค่า `google-services.json` ให้ถูกต้อง

---

### **Step 5: Uncomment Firebase Code** (1 นาที)

แก้ไข `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ Uncomment

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Uncomment
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await UserData.init(); 
  runApp(const MyApp());
}
```

---

### **Step 6: แก้ไข SignUpLoginPage** (5 นาที)

แก้ไข `lib/pages/signup_login_page.dart`:

```dart
// เดิม
import '../services/auth_service.dart';

// ใหม่
import '../services/auth_service_firebase.dart';

// เปลี่ยน
final authService = AuthServiceFirebase();

// ใน _handleSubmit()
if (_isLogin) {
  final user = await authService.signIn(...);
} else {
  final user = await authService.signUp(...);
}
```

---

## 🧪 ทดสอบ

1. **Sign Up:**
   - กรอกข้อมูล → กด "สร้างบัญชี"
   - ตรวจสอบใน Firebase Console → Authentication → Users
   - ตรวจสอบใน Firestore → Collection `users`

2. **Sign In:**
   - ใช้ email/password ที่สร้างไว้
   - ตรวจสอบว่าข้อมูลถูกโหลดจาก Firestore

---

## 📝 Checklist

- [ ] สร้าง Firebase Project
- [ ] เพิ่ม Android App
- [ ] ดาวน์โหลด `google-services.json`
- [ ] วางไฟล์ใน `android/app/`
- [ ] Enable Email/Password Authentication
- [ ] Enable Firestore Database
- [ ] รัน `flutterfire configure`
- [ ] Uncomment Firebase code ใน `main.dart`
- [ ] แก้ไข `signup_login_page.dart` ให้ใช้ `AuthServiceFirebase`
- [ ] ทดสอบ Sign Up / Login

---

## ⚠️ หมายเหตุ

**ตอนนี้แอปยังใช้ `AuthService` (SharedPreferences) อยู่**

เมื่อ setup Firebase เสร็จแล้ว:
1. Uncomment Firebase code ใน `main.dart`
2. เปลี่ยน `AuthService` → `AuthServiceFirebase` ใน `signup_login_page.dart`
3. ทดสอบ Sign Up / Login

---

**พร้อม setup Firebase แล้ว!** 🚀


