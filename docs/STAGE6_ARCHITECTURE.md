# Stage 6 Architecture

```text
Market Data Adapter
        ↓
Technical Indicators
        ↓
Strategy / Confidence Engine
        ↓
Risk Governor
        ↓
Approval Queue
        ↓
AuthorizedExecutionAdapter
        ↓
Broker or Platform
        ↓
Result Reconciliation
        ↓
Journal + Analytics + Audit Log
```

The final platform connection is isolated from the rest of the app. This prevents a future integration change from requiring a complete rebuild.
