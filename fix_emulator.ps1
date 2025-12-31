# Script สำหรับแก้ไขปัญหา Android Emulator
Write-Host "=== กำลังตรวจสอบและแก้ไขปัญหา Android Emulator ===" -ForegroundColor Green
Write-Host ""

# ตรวจสอบ AVD
Write-Host "1. ตรวจสอบ AVD ที่มี..." -ForegroundColor Yellow
flutter emulators

Write-Host ""
Write-Host "2. ตรวจสอบ Android SDK..." -ForegroundColor Yellow
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $androidHome) {
    Write-Host "   Android SDK พบที่: $androidHome" -ForegroundColor Green
} else {
    Write-Host "   ไม่พบ Android SDK!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== วิธีแก้ไขปัญหา ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "ปัญหาที่พบ:" -ForegroundColor Yellow
Write-Host "1. Android Emulator ไม่สามารถเปิดได้ (exit code 1)" -ForegroundColor White
Write-Host "2. cmdline-tools ไม่มี" -ForegroundColor White
Write-Host ""
Write-Host "วิธีแก้ไข:" -ForegroundColor Green
Write-Host ""
Write-Host "วิธีที่ 1: เปิดผ่าน Android Studio (แนะนำ)" -ForegroundColor Cyan
Write-Host "  1. เปิด Android Studio" -ForegroundColor White
Write-Host "  2. Tools -> Device Manager" -ForegroundColor White
Write-Host "  3. คลิก Start ที่ Emulator ที่ต้องการ" -ForegroundColor White
Write-Host "  4. หากมี error ให้ดู log ใน Android Studio" -ForegroundColor White
Write-Host ""
Write-Host "วิธีที่ 2: ติดตั้ง cmdline-tools" -ForegroundColor Cyan
Write-Host "  1. เปิด Android Studio" -ForegroundColor White
Write-Host "  2. Tools -> SDK Manager" -ForegroundColor White
Write-Host "  3. ไปที่แท็บ SDK Tools" -ForegroundColor White
Write-Host "  4. ติ๊กเลือก 'Android SDK Command-line Tools (latest)'" -ForegroundColor White
Write-Host "  5. คลิก Apply และรอให้ติดตั้งเสร็จ" -ForegroundColor White
Write-Host ""
Write-Host "วิธีที่ 3: ลองใช้ Emulator อื่น" -ForegroundColor Cyan
Write-Host "  flutter emulators --launch pixel_6_-_api_34_naphat" -ForegroundColor White
Write-Host ""
Write-Host "วิธีที่ 4: ตรวจสอบ Hardware Acceleration" -ForegroundColor Cyan
Write-Host "  - ตรวจสอบว่า Virtualization เปิดอยู่ใน BIOS" -ForegroundColor White
Write-Host "  - ตรวจสอบว่า Hyper-V หรือ WSL2 ไม่ได้บล็อก emulator" -ForegroundColor White
Write-Host ""


