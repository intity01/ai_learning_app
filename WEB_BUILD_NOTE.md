# ⚠️ Web Build Note

## ปัญหา Web Build

แอปนี้เป็น **Mobile App** เป็นหลัก และมีปัญหาในการ build สำหรับ Web เนื่องจาก:

1. **Firebase Auth Web Compatibility** - Firebase Auth Web package มีปัญหา compatibility กับ Dart SDK version ใหม่
2. **WebAssembly (Wasm) Warnings** - บาง packages ยังไม่รองรับ Wasm compilation

---

## ✅ วิธีแก้ (ถ้าต้องการ Build Web)

### Option 1: อัปเดต Firebase Packages (แนะนำ)

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

จากนั้น:
```bash
flutter pub get
flutter clean
flutter build web --release --base-href /ai_learning_app/
```

### Option 2: ใช้ --no-wasm-dry-run (Temporary Fix)

```bash
flutter build web --release --base-href /ai_learning_app/ --no-wasm-dry-run
```

---

## 🎯 สำหรับ Hackathon Submission

**ไม่จำเป็นต้อง Build Web ได้!**

- ✅ แอปเป็น **Mobile App** (Android/iOS) เป็นหลัก
- ✅ GitHub repository มี source code ครบถ้วน
- ✅ มี README และ documentation ครบ
- ✅ สามารถรันบน Android Emulator ได้

**GitHub Pages:**
- ถ้าต้องการแสดง demo online อาจจะใช้:
  - Screenshots/GIFs
  - Demo video (YouTube)
  - หรือ build APK สำหรับ download

---

## 📱 Mobile Build (ทำงานได้ปกติ)

```bash
# Android
flutter build apk --release

# iOS (ถ้ามี Mac)
flutter build ios --release
```

---

## 🔗 Alternative: Web Demo

ถ้าต้องการ demo online จริงๆ:

1. **ใช้ Flutter Web (ถ้าแก้ปัญหาได้)**
2. **ใช้ Screenshots + Video Demo** (แนะนำ)
3. **ใช้ APK + Install Instructions**

---

**Note:** สำหรับ hackathon submission, mobile app ที่ทำงานได้ดีบน Android/iOS ก็เพียงพอแล้ว! 🚀

