# LIVE DATA SETUP

1. Create a Twelve Data account.
2. Copy your API key.
3. Open the Stage 7 project folder in the Linux terminal.
4. Run:

```bash
flutter pub get
```

5. Analyze:

```bash
flutter analyze
```

6. Launch with your key:

```bash
flutter run -d chrome --dart-define=TWELVE_DATA_API_KEY=PASTE_YOUR_KEY_HERE
```

The top card should change to `LIVE READY`.

If the app says the API key is missing, confirm there is no space around the equals sign.

Do not post screenshots showing the complete key.
