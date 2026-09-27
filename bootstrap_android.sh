#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter n'est pas installé ou n'est pas dans le PATH."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
python3 "$ROOT/tool/generate_branding.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

flutter create \
  --platforms=android \
  --org fr.revisionarbitrage \
  --project-name revision_arbitrage \
  "$TMP/revision_arbitrage"

rm -rf "$ROOT/android"
cp -R "$TMP/revision_arbitrage/android" "$ROOT/android"

MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"
python3 - "$MANIFEST" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace('android:label="revision_arbitrage"', 'android:label="Révision Arbitrage"')
p.write_text(s)
PY

for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  src="$ROOT/assets/branding/android/mipmap-$density/ic_launcher.png"
  dst="$ROOT/android/app/src/main/res/mipmap-$density/ic_launcher.png"
  cp "$src" "$dst"
done

cd "$ROOT"
flutter pub get

echo "Projet Android prêt."
