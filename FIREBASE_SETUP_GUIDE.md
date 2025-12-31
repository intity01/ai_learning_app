# 🔥 Firebase Setup Guide

## 📋 ขั้นตอนการ Setup Firebase

### **Step 1: สร้าง Firebase Project**

1. ไปที่ [Firebase Console](https://console.firebase.google.com/)
2. คลิก "Add project" หรือ "สร้างโปรเจกต์"
3. ตั้งชื่อโปรเจกต์ (เช่น "flutter-ai-learning-app")
4. เลือก Google Analytics (แนะนำ: เปิด)
5. คลิก "Create project"

---

### **Step 2: เพิ่ม Android App**

1. ใน Firebase Console → คลิก "Add app" → เลือก Android
2. ใส่ข้อมูล:
   - **Android package name:** `com.example.flutter_ai_learning_app` (หรือ package name ของคุณ)
   - **App nickname:** (optional)
   - **Debug signing certificate SHA-1:** (optional สำหรับตอนนี้)
3. คลิก "Register app"
4. ดาวน์โหลด `google-services.json`
5. วางไฟล์ `google-services.json` ใน `android/app/`

---

### **Step 3: ติดตั้ง Dependencies**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
```

---

### **Step 4: ตั้งค่า Android**

#### **4.1 แก้ไข `android/build.gradle`**

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### **4.2 แก้ไข `android/app/build.gradle`**

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services' // ✅ เพิ่มบรรทัดนี้

dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}
```

---

### **Step 5: ตั้งค่า Firebase ใน Flutter**

#### **5.1 Initialize Firebase ใน `main.dart`**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // จะสร้างอัตโนมัติ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await UserData.init();
  runApp(const MyApp());
}
```

#### **5.2 สร้าง Firebase Options**

รันคำสั่ง:
```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub global activate flutterfire_cli
flutterfire configure
```

---

### **Step 3: แก้ไข AuthService**

แก้ไข `lib/services/auth_service.dart` ให้ใช้ Firebase แทน SharedPreferences

---

## ✅ Checklist

- [ ] สร้าง Firebase Project
- [ ] เพิ่ม Android App
- [ ] ดาวน์โหลด `google-services.json`
- [ ] วางไฟล์ใน `android/app/`
- [ ] ติดตั้ง dependencies
- [ ] ตั้งค่า `android/build.gradle`
- [ ] ตั้งค่า `android/app/build.gradle`
- [ ] Initialize Firebase ใน `main.dart`
- [ ] แก้ไข `AuthService` ให้ใช้ Firebase
- [ ] ทดสอบ Sign Up / Login

---

**พร้อมเริ่มแล้ว!** 🚀


