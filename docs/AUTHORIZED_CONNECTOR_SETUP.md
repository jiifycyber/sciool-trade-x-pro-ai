# Authorized Connector Setup

The included Pocket Option adapter is intentionally locked.

To unlock a real connector safely, obtain all of the following:

1. Written confirmation that your account may use automation.
2. Official or authorized integration documentation.
3. A supported authentication method that does not require exposing your password.
4. Test/demo environment access.
5. Rate limits and order-status documentation.
6. A documented method to cancel, reconcile, and audit orders.

Then create a new adapter implementing:

```dart
abstract class AuthorizedExecutionAdapter {
  String get providerName;
  bool get isConfigured;
  bool get isConnected;
  Future<ConnectorStatus> healthCheck();
  Future<String> submitApprovedTrade(ExecutionRequest request);
}
```

Do not implement:

- Browser credential scraping
- DOM auto-clicking
- CAPTCHA bypass
- Undocumented private WebSocket calls
- Session-cookie theft or replay
