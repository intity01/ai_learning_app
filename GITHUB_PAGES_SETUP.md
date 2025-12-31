# 🌐 GitHub Pages Setup Guide

คู่มือการตั้งค่า GitHub Pages เพื่อแสดงผล Flutter Web App ของคุณ

---

## 📋 ขั้นตอนการตั้งค่า

### **Step 1: Enable GitHub Pages ใน Repository**

1. ไปที่ GitHub repository ของคุณ
2. คลิก **Settings** → เลื่อนลงไปที่ **Pages**
3. ในส่วน **Source** เลือก:
   - **Source**: `GitHub Actions` 
   - (ไม่ใช่ Deploy from a branch)
4. กด **Save**

---

### **Step 2: ตรวจสอบ Workflow File**

ไฟล์ `.github/workflows/deploy_github_pages.yml` จะถูกสร้างไว้แล้ว

**⚠️ สำคัญ:** แก้ไข base-href ใน workflow file:

```yaml
run: flutter build web --release --base-href /flutter_ai_learning_app/
```

เปลี่ยน `/flutter_ai_learning_app/` เป็นชื่อ repository ของคุณ

**ตัวอย่าง:**
- ถ้า repository คือ `my-learning-app` → `/my-learning-app/`
- ถ้า repository คือ `language-app` → `/language-app/`

---

### **Step 3: Push Code ไป GitHub**

```bash
# เพิ่มไฟล์ workflow
git add .github/workflows/deploy_github_pages.yml
git commit -m "feat: Add GitHub Pages deployment workflow"
git push origin main
```

---

### **Step 4: รอให้ GitHub Actions Build**

1. ไปที่ **Actions** tab ใน GitHub repository
2. คุณจะเห็น workflow `Deploy Flutter Web to GitHub Pages` กำลัง run
3. รอให้ build เสร็จ (ประมาณ 3-5 นาที)
4. ถ้าสำเร็จจะเห็น ✓ เขียว

---

### **Step 5: เข้าถึงเว็บไซต์**

หลังจาก build สำเร็จ:

1. ไปที่ **Settings** → **Pages**
2. จะเห็น URL ของเว็บไซต์:
   ```
   https://YOUR_USERNAME.github.io/flutter_ai_learning_app/
   ```
   (เปลี่ยน YOUR_USERNAME และ flutter_ai_learning_app ให้ตรงกับ repository ของคุณ)

3. หรือไปที่ **Actions** tab → คลิก workflow run ล่าสุด → จะเห็น link ในส่วน **deploy** job

---

## 🔧 Troubleshooting

### **ปัญหา: Build ล้มเหลว**

**ตรวจสอบ:**
- Flutter version ใน workflow ตรงกับที่คุณใช้หรือไม่
- Dependencies ถูกต้องหรือไม่ (`flutter pub get` ทำงานไหม)
- API keys ไม่จำเป็นสำหรับ web build (แต่ต้องระวัง security)

### **ปัญหา: หน้าเว็บเป็น blank/ขาว**

**แก้ไข:**
1. ตรวจสอบ base-href ถูกต้องหรือไม่
2. ตรวจสอบ console ใน browser (F12) ดู error
3. ตรวจสอบว่า build/web มีไฟล์อยู่

### **ปัญหา: Assets ไม่แสดง**

**แก้ไข:**
- ตรวจสอบว่า `assets/` folder ถูก include ใน `pubspec.yaml`
- Rebuild: `flutter clean && flutter pub get && flutter build web`

### **ปัญหา: Routes ไม่ทำงาน (404)**

**แก้ไข:**
1. สร้างไฟล์ `404.html` ใน `web/` folder
2. หรือใช้ GitHub Pages redirect

---

## 🔄 การ Update เว็บไซต์

ทุกครั้งที่ push code ไป `main` branch:
- GitHub Actions จะ build และ deploy อัตโนมัติ
- เว็บไซต์จะอัปเดตภายใน 1-2 นาที

หรือ deploy แบบ manual:
1. ไปที่ **Actions** tab
2. เลือก workflow `Deploy Flutter Web to GitHub Pages`
3. คลิก **Run workflow** → **Run workflow**

---

## ⚠️ ข้อควรระวัง

### **Security: API Keys**

**อย่า** commit API keys ไป GitHub:
- ✅ ใช้ `lib/config/api_config.dart` ที่อยู่ใน `.gitignore`
- ✅ ใช้ environment variables ใน GitHub Actions (ถ้าต้องการ)
- ❌ **ห้าม** hardcode API keys ใน code

### **Firebase Configuration**

สำหรับ Flutter web ต้อง:
1. เพิ่ม Firebase Web app ใน Firebase Console
2. Download `firebase_options.dart` สำหรับ web
3. ตั้งค่า Firebase Hosting ถ้าต้องการ (ไม่จำเป็นสำหรับ GitHub Pages)

---

## 📝 Custom Domain (Optional)

ถ้าต้องการใช้ domain ของตัวเอง:

1. ใน **Settings** → **Pages** → **Custom domain**
2. ใส่ domain ที่ต้องการ
3. เพิ่ม CNAME record ใน DNS provider

---

## 🎯 Checklist

- [ ] Enable GitHub Pages (ใช้ GitHub Actions)
- [ ] แก้ไข base-href ใน workflow file
- [ ] Push code ไป GitHub
- [ ] ตรวจสอบ GitHub Actions build สำเร็จ
- [ ] เข้าถึงเว็บไซต์ได้
- [ ] ทดสอบ features ต่างๆ ทำงานถูกต้อง
- [ ] แก้ไข README.md ให้มีลิงก์ไป GitHub Pages

---

## 📚 Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## ✅ เสร็จแล้ว!

หลังจากทำตามขั้นตอนทั้งหมด คุณจะมีเว็บไซต์แสดงผลงานบน GitHub Pages แล้ว! 🎉

**ตัวอย่าง URL:**
```
https://YOUR_USERNAME.github.io/flutter_ai_learning_app/
```

---

**สร้างโดย:** Flutter AI Learning App Team

