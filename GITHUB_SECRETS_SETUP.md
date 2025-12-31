# GitHub Secrets Setup Guide

## ขั้นตอนการตั้งค่า GitHub Secrets สำหรับ Web Build

### Step 1: หา Firebase Credentials

คุณสามารถหา credentials ได้จากไฟล์เหล่านี้:

#### จากไฟล์ `android/app/google-services.json`:
```json
{
  "project_info": {
    "project_number": "392673254940",  // ← FIREBASE_MESSAGING_SENDER_ID
    "project_id": "cominiti",           // ← FIREBASE_PROJECT_ID
    "storage_bucket": "cominiti.firebasestorage.app"  // ← FIREBASE_STORAGE_BUCKET
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:392673254940:android:88101ba2de91333e2389d9"  // ← FIREBASE_APP_ID
      },
      "api_key": [
        {
          "current_key": "YOUR_FIREBASE_API_KEY_HERE"  // ← FIREBASE_API_KEY (ต้องสร้างใหม่)
        }
      ]
    }
  ]
}
```

#### จากไฟล์ `lib/firebase_options.dart`:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '...',              // ← FIREBASE_API_KEY
  appId: '...',               // ← FIREBASE_APP_ID
  messagingSenderId: '...',   // ← FIREBASE_MESSAGING_SENDER_ID
  projectId: '...',           // ← FIREBASE_PROJECT_ID
  storageBucket: '...',       // ← FIREBASE_STORAGE_BUCKET
);
```

---

### Step 2: สร้าง Firebase API Key ใหม่ (สำคัญ!)

**⚠️ ต้องสร้าง API Key ใหม่เพราะ key เก่าถูก revoke แล้ว**

1. ไปที่ [Google Cloud Console](https://console.cloud.google.com/)
2. เลือก Project: **cominiti**
3. ไปที่ **APIs & Services** → **Credentials**
4. คลิก **+ CREATE CREDENTIALS** → **API Key**
5. Copy API Key ที่สร้างใหม่
6. (แนะนำ) Restrict API Key:
   - **Application restrictions**: Android apps
   - **API restrictions**: เลือก Firebase services ที่ใช้

---

### Step 3: ตั้งค่า GitHub Secrets

1. ไปที่ GitHub Repository: `https://github.com/intity01/ai_learning_app`

2. คลิก **Settings** (ด้านบน)

3. ในเมนูด้านซ้าย คลิก **Secrets and variables** → **Actions**

4. คลิก **New repository secret** สำหรับแต่ละ secret:

#### Secret 1: FIREBASE_API_KEY
- **Name**: `FIREBASE_API_KEY`
- **Secret**: `AIzaSy...` (API Key ใหม่ที่สร้างจาก Step 2)
- คลิก **Add secret**

#### Secret 2: FIREBASE_APP_ID
- **Name**: `FIREBASE_APP_ID`
- **Secret**: `1:392673254940:android:88101ba2de91333e2389d9`
- คลิก **Add secret**

#### Secret 3: FIREBASE_MESSAGING_SENDER_ID
- **Name**: `FIREBASE_MESSAGING_SENDER_ID`
- **Secret**: `392673254940`
- คลิก **Add secret**

#### Secret 4: FIREBASE_PROJECT_ID
- **Name**: `FIREBASE_PROJECT_ID`
- **Secret**: `cominiti`
- คลิก **Add secret**

#### Secret 5: FIREBASE_STORAGE_BUCKET
- **Name**: `FIREBASE_STORAGE_BUCKET`
- **Secret**: `cominiti.firebasestorage.app`
- คลิก **Add secret**

---

### Step 4: ตรวจสอบ Secrets

หลังจากเพิ่ม secrets ทั้งหมดแล้ว คุณควรเห็น:
- ✅ FIREBASE_API_KEY
- ✅ FIREBASE_APP_ID
- ✅ FIREBASE_MESSAGING_SENDER_ID
- ✅ FIREBASE_PROJECT_ID
- ✅ FIREBASE_STORAGE_BUCKET

---

### Step 5: ทดสอบ Workflow

1. ไปที่ **Actions** tab ใน GitHub
2. คลิก **Deploy Flutter Web to GitHub Pages**
3. คลิก **Run workflow** → **Run workflow**
4. ตรวจสอบว่า build สำเร็จหรือไม่

---

## Troubleshooting

### ถ้า Build ยังล้มเหลว:

1. **ตรวจสอบ Secrets**: ตรวจสอบว่า secrets ทั้งหมดถูกตั้งค่าแล้ว
2. **ตรวจสอบ API Key**: ตรวจสอบว่า API Key ใหม่ทำงานได้
3. **ตรวจสอบ Firebase Packages**: อาจต้องอัปเดต Firebase packages
4. **ดู Logs**: ดู error logs ใน GitHub Actions เพื่อหาสาเหตุ

### ถ้าไม่ต้องการ Web Build:

คุณสามารถ disable workflow ได้:
```bash
git mv .github/workflows/deploy_github_pages.yml .github/workflows/deploy_github_pages.yml.disabled
```

---

## ข้อมูลจากไฟล์ปัจจุบัน

จากไฟล์ที่มีอยู่:

- **FIREBASE_APP_ID**: `1:392673254940:android:88101ba2de91333e2389d9`
- **FIREBASE_MESSAGING_SENDER_ID**: `392673254940`
- **FIREBASE_PROJECT_ID**: `cominiti`
- **FIREBASE_STORAGE_BUCKET**: `cominiti.firebasestorage.app`
- **FIREBASE_API_KEY**: ⚠️ **ต้องสร้างใหม่** (key เก่าถูก revoke แล้ว)

---

## Quick Reference

| Secret Name | Value | Source |
|------------|-------|--------|
| FIREBASE_API_KEY | `AIzaSy...` (ใหม่) | Google Cloud Console |
| FIREBASE_APP_ID | `1:392673254940:android:88101ba2de91333e2389d9` | google-services.json |
| FIREBASE_MESSAGING_SENDER_ID | `392673254940` | google-services.json |
| FIREBASE_PROJECT_ID | `cominiti` | google-services.json |
| FIREBASE_STORAGE_BUCKET | `cominiti.firebasestorage.app` | google-services.json |

---

**Note**: หลังจากตั้งค่า secrets แล้ว workflow จะใช้ค่าเหล่านี้แทน placeholder values

