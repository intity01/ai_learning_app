# ⚡ GitHub Quick Start (5 นาที)

## 🚀 Push โปรเจกต์ไป GitHub อย่างรวดเร็ว

### **Step 1: สร้าง Repository บน GitHub**

1. ไปที่ https://github.com/new
2. ตั้งชื่อ: `flutter_ai_learning_app`
3. เลือก **Public**
4. **อย่า** check "Initialize with README"
5. คลิก **"Create repository"**

---

### **Step 2: เปิด Terminal/PowerShell**

```powershell
# ไปที่โฟลเดอร์โปรเจกต์
cd C:\Users\Naphatsadon4596\Downloads\flutter_ai_learning_app\flutter_ai_learning_app

# ตรวจสอบว่าเป็น Git repo หรือยัง
git status
```

ถ้ายังไม่ใช่ Git repo:

```powershell
git init
```

---

### **Step 3: เพิ่ม Remote และ Push**

```powershell
# เพิ่ม remote (แทนที่ YOUR_USERNAME ด้วย username ของคุณ)
git remote add origin https://github.com/YOUR_USERNAME/flutter_ai_learning_app.git

# เพิ่มไฟล์ทั้งหมด
git add .

# Commit
git commit -m "Initial commit: Flutter AI Learning App for Hackathon"

# Push
git branch -M main
git push -u origin main
```

---

### **Step 4: ถ้าเจอ Authentication Error**

**ใช้ Personal Access Token:**

1. ไปที่: https://github.com/settings/tokens
2. Generate new token (classic)
3. เลือก scope: `repo`
4. Copy token
5. เมื่อ push จะถาม password → **ใช้ token แทน password**

---

### **Step 5: ตรวจสอบ**

ไปที่: `https://github.com/YOUR_USERNAME/flutter_ai_learning_app`

ควรเห็นไฟล์ทั้งหมดแล้ว! ✅

---

## ⚠️ ตรวจสอบก่อน Push

```powershell
# ตรวจสอบว่า api_config.dart ไม่ถูก commit
git check-ignore lib/config/api_config.dart

# ถ้าไม่มี output = ถูก ignore แล้ว ✅
# ถ้ามี output = ต้องเพิ่มใน .gitignore
```

---

## 📝 ตัวอย่าง Git Commands

```powershell
# ดูสถานะ
git status

# เพิ่มไฟล์
git add .

# Commit
git commit -m "feat: Add new feature"

# Push
git push

# ดู history
git log --oneline
```

---

**เสร็จแล้ว! 🎉**

ดูรายละเอียดเพิ่มเติมใน [`GITHUB_SETUP.md`](GITHUB_SETUP.md)

