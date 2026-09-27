$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter n'est pas installé ou n'est pas dans le PATH."
  exit 1
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Temp = Join-Path $env:TEMP ("revision_arbitrage_" + [guid]::NewGuid().ToString())
$Bootstrap = Join-Path $Temp "revision_arbitrage"

try {
  flutter create --platforms=android --org fr.revisionarbitrage --project-name revision_arbitrage $Bootstrap
  $AndroidTarget = Join-Path $Root "android"
  if (Test-Path $AndroidTarget) { Remove-Item $AndroidTarget -Recurse -Force }
  Copy-Item (Join-Path $Bootstrap "android") $AndroidTarget -Recurse
  Set-Location $Root
  flutter pub get
  Write-Host "Projet Android prêt."
  Write-Host "Tester :      flutter run"
  Write-Host "Créer l'APK : flutter build apk --release"
}
finally {
  if (Test-Path $Temp) { Remove-Item $Temp -Recurse -Force }
}
