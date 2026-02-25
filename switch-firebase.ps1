# Google Services JSON Switcher
# Usage: powershell -ExecutionPolicy Bypass -File switch-firebase.ps1 -Copy | -Main
#
# -Copy : Use google-services-copy.json
# -Main : Use google-services-main.json

param(
    [switch]$Copy,
    [switch]$Main
)

$androidAppPath = "android/app"
$mainJson = Join-Path $androidAppPath "google-services-main.json"
$copyJson = Join-Path $androidAppPath "google-services-copy.json"
$targetJson = Join-Path $androidAppPath "google-services.json"

if ($Copy) {
    if (Test-Path $copyJson) {
        Copy-Item $copyJson $targetJson -Force
        Write-Host "Switched to COPY Firebase project."
    } else {
        Write-Host "google-services-copy.json not found!"
    }
} elseif ($Main) {
    if (Test-Path $mainJson) {
        Copy-Item $mainJson $targetJson -Force
        Write-Host "Switched to MAIN Firebase project."
    } else {
        Write-Host "google-services-main.json not found!"
    }
} else {
    Write-Host "Specify -Copy or -Main."
}
