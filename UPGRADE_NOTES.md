# SCIOOL Trade X Pro — AI Strategy Upgrade

This build keeps the approved modern TradeX interface and adds the first integrated strategy upgrade.

## Included

- Renamed active branding to **SCIOOL Trade X Pro**.
- Saved strategy profile using SharedPreferences.
- Default **Jontarius 1-Minute** profile:
  - EMA 9 / 21
  - MACD 5 / 13 / 5
  - ZigZag 5 / 4 / 3
  - RSI 14
  - Bollinger Bands 20 / 2
  - Volume/activity period 10
  - Minimum confidence 85%
  - One-minute expiration
- Editable AI Strategy & Risk Controls screen.
- Strategy-aware live market calculations.
- Weighted CALL / PUT / WAIT scoring.
- AI explanations and warning reasons when the system returns WAIT.
- API-key behavior remains unchanged: launch locally with `--dart-define=TWELVE_DATA_API_KEY=...`.

## Important

This is a decision-support tool. It cannot guarantee outcomes or eliminate trading risk. Live execution remains approval-only.
