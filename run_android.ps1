# Script สำหรับรันแอปบน Android Emulator เท่านั้น
Write-Host "=== กำลังเปิด Android Emulator ===" -ForegroundColor Green

# เปิด Emulator
Write-Host "กำลังเปิด Pixel 7 - API 35..." -ForegroundColor Yellow
flutter emulators --launch pixel_7_-_api_35

# รอให้ Emulator boot เสร็จ
Write-Host "`nรอให้ Emulator boot เสร็จ (อาจใช้เวลา 30-60 วินาที)..." -ForegroundColor Yellow
$maxWait = 120  # รอสูงสุด 2 นาที
$waited = 0
$found = $false

while ($waited -lt $maxWait -and -not $found) {
    Start-Sleep -Seconds 5
    $waited += 5
    $devices = flutter devices 2>&1 | Out-String
    if ($devices -match "android") {
        $found = $true
        Write-Host "พบ Android Emulator แล้ว!" -ForegroundColor Green
        break
    }
    Write-Host "รออีก... ($waited/$maxWait วินาที)" -ForegroundColor Gray
}

if (-not $found) {
    Write-Host "`nไม่พบ Android Emulator หลังจากรอ $maxWait วินาที" -ForegroundColor Red
    Write-Host "กรุณาตรวจสอบว่า Emulator เปิดอยู่หรือไม่" -ForegroundColor Yellow
    exit 1
}

# รออีกสักครู่เพื่อให้ Emulator พร้อมใช้งาน
Write-Host "`nรอให้ Emulator พร้อมใช้งาน..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# แสดง devices ที่มี
Write-Host "`n=== Devices ที่พร้อมใช้งาน ===" -ForegroundColor Green
flutter devices

# รันแอปบน Android เท่านั้น
Write-Host "`n=== กำลังรันแอปบน Android Emulator ===" -ForegroundColor Green
flutter run -d android


