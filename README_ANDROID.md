# วิธีรันแอปบน Android Emulator

## ปัญหาที่พบ
- Android cmdline-tools ไม่มี (ต้องติดตั้งผ่าน Android Studio)
- Android licenses ยังไม่ยอมรับ

## วิธีแก้ไข (แนะนำ)

### วิธีที่ 1: เปิด Emulator ผ่าน Android Studio (แนะนำ)

1. **เปิด Android Studio**
   - เปิดโปรเจกต์ `flutter_ai_learning_app`

2. **เปิด Device Manager**
   - ไปที่: **Tools → Device Manager**
   - หรือกด `Ctrl+Shift+A` แล้วพิมพ์ "Device Manager"

3. **เปิด Emulator**
   - คลิกที่ **▶️ Start** ที่ Emulator ที่ต้องการ (เช่น Pixel 7 - API 35)
   - รอให้ Emulator boot เสร็จ (ประมาณ 30-60 วินาที)

4. **รันแอป**
   - ใน Android Studio: เลือก device เป็น "android" จาก dropdown
   - กดปุ่ม **Run (▶️)** หรือกด `Shift+F10`
   - หรือใน Terminal: `flutter run -d android`

### วิธีที่ 2: ใช้ Terminal (ถ้า Emulator เปิดอยู่แล้ว)

```powershell
# ตรวจสอบว่า Emulator เปิดอยู่หรือไม่
flutter devices

# ถ้ามี Android device แล้ว ให้รัน:
flutter run -d android
```

### วิธีที่ 3: แก้ไข Android cmdline-tools

1. เปิด **Android Studio**
2. ไปที่ **Tools → SDK Manager**
3. ไปที่แท็บ **SDK Tools**
4. ติ๊กเลือก **Android SDK Command-line Tools (latest)**
5. คลิก **Apply** และรอให้ติดตั้งเสร็จ
6. เปิด Terminal และรัน:
   ```powershell
   flutter doctor --android-licenses
   ```
   กด `y` เพื่อยอมรับ licenses ทั้งหมด

## ตรวจสอบสถานะ

```powershell
# ตรวจสอบ devices
flutter devices

# ตรวจสอบ Flutter setup
flutter doctor
```

## สคริปต์อัตโนมัติ

ใช้สคริปต์ `run_android.ps1`:
```powershell
.\run_android.ps1
```

**หมายเหตุ:** สคริปต์จะเปิด Emulator อัตโนมัติ แต่ต้องมี cmdline-tools ติดตั้งก่อน


