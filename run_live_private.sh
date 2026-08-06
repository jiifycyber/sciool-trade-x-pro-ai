#!/usr/bin/env bash
set -euo pipefail

KEY_FILE="$HOME/.config/titan_ai/twelve_data_key"

mkdir -p "$(dirname "$KEY_FILE")"
chmod 700 "$(dirname "$KEY_FILE")"

if [[ ! -f "$KEY_FILE" ]]; then
  read -rsp "Paste your Twelve Data API key: " API_KEY
  echo
  printf '%s' "$API_KEY" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
fi

API_KEY="$(cat "$KEY_FILE")"

if [[ -z "$API_KEY" ]]; then
  echo "The saved API key is empty."
  exit 1
fi

flutter run -d chrome --dart-define=TWELVE_DATA_API_KEY="$API_KEY"
