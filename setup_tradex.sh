#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Setting up TradeX Intelligence..."

flutter config --enable-web
flutter config --enable-linux-desktop

if [[ ! -d web || ! -d linux ]]; then
  flutter create .
fi

flutter pub get

# Remove Flutter's default generated test because this project uses TradeXApp.
rm -f test/widget_test.dart

flutter analyze

echo
echo "Setup complete."
echo "Linux: flutter run -d linux"
echo "Web:   flutter run -d chrome"
echo "Build: flutter build web --release"
