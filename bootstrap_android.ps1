$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter n'est pas installé ou n'est pas dans le PATH."
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
python (Join-Path $Root "tool/generate_branding.py")
$Temp = Join-Path ([System.IO.Path]::GetTempPath()) ("revision_arbitrage_" + [Guid]::NewGuid())

try {
  flutter create --platforms=android --org fr.revisionarbitrage --project-name revision_arbitrage $Temp
  Remove-Item -Recurse -Force (Join-Path $Root "android") -ErrorAction SilentlyContinue
  Copy-Item -Recurse (Join-Path $Temp "android") (Join-Path $Root "android")

  $Manifest = Join-Path $Root "android/app/src/main/AndroidManifest.xml"
  (Get-Content $Manifest -Raw).Replace('android:label="revision_arbitrage"', 'android:label="Révision Arbitrage"') | Set-Content $Manifest -Encoding utf8

  foreach ($density in @("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")) {
    Copy-Item (Join-Path $Root "assets/branding/android/mipmap-$density/ic_launcher.png") (Join-Path $Root "android/app/src/main/res/mipmap-$density/ic_launcher.png") -Force
  }

  Set-Location $Root
  flutter pub get
  Write-Host "Projet Android prêt."
}
finally {
  Remove-Item -Recurse -Force $Temp -ErrorAction SilentlyContinue
}
