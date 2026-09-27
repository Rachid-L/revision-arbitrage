#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter n'est pas installé ou n'est pas dans le PATH."
  echo "Installe Flutter puis relance ce script."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Génère un squelette Flutter Android dans un dossier temporaire,
# puis ne copie que la partie native. Ainsi, le code/lib et questions.json
# fournis ne peuvent pas être écrasés par `flutter create`.
flutter create   --platforms=android   --org fr.revisionarbitrage   --project-name revision_arbitrage   "$TMP/revision_arbitrage"

rm -rf "$ROOT/android"
cp -R "$TMP/revision_arbitrage/android" "$ROOT/android"
cd "$ROOT"
flutter pub get

echo
echo "Projet Android prêt."
echo "Tester :       flutter run"
echo "Créer l'APK :  flutter build apk --release"
