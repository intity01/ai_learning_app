@echo off
echo ========================================
echo กำลังเปิด Android Emulator
echo ========================================
echo.

set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set EMULATOR_PATH=%ANDROID_HOME%\emulator\emulator.exe

if not exist "%EMULATOR_PATH%" (
    echo ไม่พบ emulator.exe ที่ %EMULATOR_PATH%
    echo กรุณาตรวจสอบว่า Android SDK ติดตั้งถูกต้อง
    pause
    exit /b 1
)

echo กำลังเปิด Pixel 7 - API 35...
start "" "%EMULATOR_PATH%" -avd pixel_7_-_api_35

echo.
echo Emulator กำลังเปิดอยู่...
echo กรุณารอให้ Emulator boot เสร็จ (ประมาณ 30-60 วินาที)
echo.
echo เมื่อ Emulator พร้อมแล้ว ให้รันคำสั่ง:
echo   flutter run -d android
echo.

timeout /t 5 /nobreak >nul

echo กำลังตรวจสอบสถานะ...
flutter devices

echo.
echo หากยังไม่เห็น Android device ให้รออีกสักครู่
pause


