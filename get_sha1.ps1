# Script for getting SHA-1 Fingerprint for Google Sign-In

Write-Host "Finding Java installation..." -ForegroundColor Cyan

# Method 1: Use keytool from Android Studio's JDK
$javaPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe",
    "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
    "$env:ProgramFiles\Android\Android Studio\jre\bin\keytool.exe",
    "$env:ProgramFiles\Android\Android Studio\jre\jre\bin\keytool.exe"
)

$keytoolPath = $null
foreach ($path in $javaPaths) {
    if (Test-Path $path) {
        $keytoolPath = $path
        Write-Host "Found keytool at: $path" -ForegroundColor Green
        break
    }
}

if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "How to fix:" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio"
    Write-Host "2. Go to File -> Settings -> Build, Execution, Deployment -> Build Tools -> Gradle"
    Write-Host "3. Check 'Gradle JDK' and note the path"
    Write-Host "4. Set JAVA_HOME to that path"
    Write-Host ""
    Write-Host "Or use another method:" -ForegroundColor Yellow
    Write-Host "- Use Android Studio's Terminal (has Java already)"
    Write-Host "- Install JDK from https://adoptium.net/"
    exit 1
}

# Find debug keystore
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (-not (Test-Path $keystorePath)) {
    Write-Host "ERROR: debug keystore not found at: $keystorePath" -ForegroundColor Red
    Write-Host "Creating debug keystore..." -ForegroundColor Yellow
    
    # Create debug keystore directory if it doesn't exist
    $keystoreDir = Split-Path $keystorePath -Parent
    if (-not (Test-Path $keystoreDir)) {
        New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
    }
    
    Write-Host "WARNING: Need to create keystore first - running Flutter app for the first time will create it automatically" -ForegroundColor Yellow
    Write-Host "   Or run: flutter run -d emulator-5554" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Getting SHA-1 fingerprint..." -ForegroundColor Cyan
Write-Host ""

# Run keytool to get SHA-1
$keytoolDir = Split-Path $keytoolPath -Parent
$javaHome = Split-Path $keytoolDir -Parent

$env:JAVA_HOME = $javaHome
$newPath = $keytoolDir + ";" + $env:PATH
$env:PATH = $newPath

Write-Host "JAVA_HOME set to: $javaHome" -ForegroundColor Gray
Write-Host ""

# Run keytool
& $keytoolPath -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1 | ForEach-Object {
    if ($_ -match "SHA1:\s*(.+)") {
        $sha1 = $matches[1].Trim()
        Write-Host ""
        Write-Host "SHA-1 Fingerprint:" -ForegroundColor Green
        Write-Host $sha1 -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""
        Write-Host "Copy the SHA-1 above and add it to:" -ForegroundColor Yellow
        Write-Host "   Firebase Console -> Project Settings -> Your apps -> Android app -> Add fingerprint" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host $_
    }
}

Write-Host ""
Write-Host "If you don't see SHA-1, check:" -ForegroundColor Yellow
Write-Host "   1. debug.keystore exists at $keystorePath" -ForegroundColor Gray
Write-Host "   2. Run Flutter app for the first time to create keystore" -ForegroundColor Gray
Write-Host ""
