# แก้ไขปัญหา Android Emulator (Exit Code 1)

## ปัญหาที่พบ
```
The Android emulator exited with code 1 during startup
```

## สาเหตุที่เป็นไปได้
1. **Hardware Acceleration ไม่เปิด** - CPU virtualization ไม่เปิด
2. **Hyper-V หรือ WSL2 บล็อก** - บน Windows อาจมีปัญหา
3. **AVD Configuration ผิด** - AVD อาจเสียหาย
4. **RAM ไม่พอ** - Emulator ต้องการ RAM อย่างน้อย 2GB
5. **Android SDK ไม่ครบ** - cmdline-tools ไม่มี

## วิธีแก้ไข

### วิธีที่ 1: เปิดผ่าน Android Studio (แนะนำที่สุด)

1. **เปิด Android Studio**
2. **Tools → Device Manager**
3. **คลิก Start (▶️) ที่ Emulator**
4. **ดู Error Log** - หากมี error จะแสดงใน Android Studio
5. **แก้ไขตาม error ที่แสดง**

### วิธีที่ 2: ลองใช้ Emulator อื่น

```powershell
# ลองใช้ Pixel 6 แทน
flutter emulators --launch pixel_6_-_api_34_naphat
```

### วิธีที่ 3: ตรวจสอบ Hardware Acceleration

1. **ตรวจสอบ BIOS**
   - เปิดคอมพิวเตอร์ใหม่
   - เข้า BIOS/UEFI
   - เปิด **Virtualization Technology (VT-x/AMD-V)**

2. **ตรวจสอบ Windows Features**
   - เปิด **Control Panel → Programs → Turn Windows features on or off**
   - ตรวจสอบว่า **Hyper-V** หรือ **Windows Subsystem for Linux** ไม่ได้บล็อก

3. **ตรวจสอบ Task Manager**
   - เปิด Task Manager
   - ไปที่แท็บ **Performance → CPU**
   - ดูว่า **Virtualization** แสดงว่า **Enabled**

### วิธีที่ 4: สร้าง Emulator ใหม่

1. **เปิด Android Studio**
2. **Tools → Device Manager**
3. **Create Device**
4. **เลือก Device Template** (เช่น Pixel 5)
5. **เลือก System Image** (แนะนำ API 33 หรือ 34)
6. **Finish**

### วิธีที่ 5: ติดตั้ง cmdline-tools

1. **เปิด Android Studio**
2. **Tools → SDK Manager**
3. **แท็บ SDK Tools**
4. **ติ๊กเลือก "Android SDK Command-line Tools (latest)"**
5. **Apply** และรอให้ติดตั้งเสร็จ

### วิธีที่ 6: ตรวจสอบ Log

```powershell
# เปิด Emulator พร้อม verbose log
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
& "$env:ANDROID_HOME\emulator\emulator.exe" -avd pixel_7_-_api_35 -verbose
```

ดู error message ที่แสดงเพื่อหาสาเหตุ

## คำแนะนำ

**วิธีที่ง่ายที่สุดคือเปิด Emulator ผ่าน Android Studio** เพราะ:
- Android Studio จะแสดง error message ที่ชัดเจน
- สามารถแก้ไขปัญหาได้ง่ายกว่า
- มี GUI ที่ใช้งานง่าย

## ตรวจสอบสถานะ

```powershell
# ตรวจสอบ Emulators
flutter emulators

# ตรวจสอบ Devices
flutter devices

# ตรวจสอบ Flutter setup
flutter doctor
```


