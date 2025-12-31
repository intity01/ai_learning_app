# PowerShell script to get SHA-1 fingerprint for Android
# This script runs gradlew signingReport and extracts the SHA-1 fingerprint

Write-Host "🔍 Getting SHA-1 fingerprint..." -ForegroundColor Cyan
Write-Host ""

# Check if gradlew.bat exists
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "❌ Error: gradlew.bat not found in current directory" -ForegroundColor Red
    Write-Host "Please run this script from the android directory" -ForegroundColor Yellow
    exit 1
}

# Run gradlew signingReport
Write-Host "Running: .\gradlew.bat signingReport" -ForegroundColor Gray
Write-Host ""

$output = & .\gradlew.bat signingReport 2>&1

# Display full output
Write-Host $output

Write-Host ""
$separator = "============================================================"
Write-Host $separator -ForegroundColor Cyan
Write-Host "📋 SHA-1 Fingerprint(s):" -ForegroundColor Green
Write-Host $separator -ForegroundColor Cyan
Write-Host ""

# Extract SHA-1 fingerprints from output
$sha1Pattern = "SHA1:\s+([A-F0-9:]+)"
$matches = [regex]::Matches($output, $sha1Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

if ($matches.Count -eq 0) {
    Write-Host "⚠️  No SHA-1 fingerprint found in output" -ForegroundColor Yellow
    Write-Host "Please check the output above manually" -ForegroundColor Yellow
} else {
    $fingerprints = @()
    foreach ($match in $matches) {
        $sha1 = $match.Groups[1].Value
        if ($fingerprints -notcontains $sha1) {
            $fingerprints += $sha1
            Write-Host "✅ $sha1" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "📝 Copy the SHA-1 fingerprint above and add it to:" -ForegroundColor Cyan
    Write-Host "   Firebase Console → Project Settings → Your apps → Android app" -ForegroundColor Cyan
    Write-Host "   → Add fingerprint" -ForegroundColor Cyan
}

Write-Host ""
Write-Host $separator -ForegroundColor Cyan
