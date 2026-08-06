#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
read -rsp "Paste your Twelve Data API key: " TWELVE_DATA_API_KEY
echo
flutter pub get
flutter run -d chrome --dart-define=TWELVE_DATA_API_KEY="$TWELVE_DATA_API_KEY"
unset TWELVE_DATA_API_KEY
