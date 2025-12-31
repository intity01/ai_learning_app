# PowerShell Script for GitHub Secrets Setup Helper
# Shows the values needed for GitHub Secrets configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Secrets Setup Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Read from google-services.json
$googleServicesPath = "android\app\google-services.json"

if (Test-Path $googleServicesPath) {
    Write-Host "Reading Firebase credentials from google-services.json..." -ForegroundColor Green
    $json = Get-Content $googleServicesPath | ConvertFrom-Json
    
    $projectNumber = $json.project_info.project_number
    $projectId = $json.project_info.project_id
    $storageBucket = $json.project_info.storage_bucket
    $appId = $json.client[0].client_info.mobilesdk_app_id
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "GitHub Secrets to Configure:" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. FIREBASE_API_KEY" -ForegroundColor White
    Write-Host "   IMPORTANT: Create new API key from Google Cloud Console" -ForegroundColor Red
    Write-Host "   URL: https://console.cloud.google.com/apis/credentials?project=$projectId" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "2. FIREBASE_APP_ID" -ForegroundColor White
    Write-Host "   Value: $appId" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "3. FIREBASE_MESSAGING_SENDER_ID" -ForegroundColor White
    Write-Host "   Value: $projectNumber" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "4. FIREBASE_PROJECT_ID" -ForegroundColor White
    Write-Host "   Value: $projectId" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "5. FIREBASE_STORAGE_BUCKET" -ForegroundColor White
    Write-Host "   Value: $storageBucket" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Setup Steps:" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to: https://github.com/intity01/ai_learning_app/settings/secrets/actions" -ForegroundColor Cyan
    Write-Host "2. Click 'New repository secret' for each secret" -ForegroundColor Cyan
    Write-Host "3. Enter Name and Value as shown above" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IMPORTANT: FIREBASE_API_KEY must be created new from Google Cloud Console!" -ForegroundColor Red
    Write-Host ""
    
} else {
    Write-Host "ERROR: google-services.json not found" -ForegroundColor Red
    Write-Host "   Check if file exists at: $googleServicesPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press Enter to close..." -ForegroundColor Gray
Read-Host
