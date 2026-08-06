import 'package:flutter/foundation.dart';
import 'connector_models.dart';
import 'authorized_execution_adapter.dart';

class IntegrationController extends ChangeNotifier {
  final AuthorizedExecutionAdapter adapter;

  IntegrationController({AuthorizedExecutionAdapter? adapter})
      : adapter = adapter ?? PocketOptionAuthorizedAdapter();

  bool killSwitch = true;
  bool liveModeRequested = false;
  ConnectorStatus? connectorStatus;
  final List<ExecutionRequest> queue = [];
  final List<AuditEntry> auditLog = [];

  Future<void> checkConnection() async {
    connectorStatus = await adapter.healthCheck();
    _audit('CONNECTION_CHECK', connectorStatus!.message);
    notifyListeners();
  }

  void setKillSwitch(bool enabled) {
    killSwitch = enabled;
    _audit(
      enabled ? 'KILL_SWITCH_ON' : 'KILL_SWITCH_OFF',
      enabled
          ? 'All execution requests are blocked.'
          : 'Execution requests may proceed only if all other safeguards pass.',
    );
    notifyListeners();
  }

  void requestLiveMode(bool enabled) {
    liveModeRequested = enabled;
    _audit(
      'LIVE_MODE_REQUEST',
      enabled ? 'Live mode requested.' : 'Returned to demo mode.',
    );
    notifyListeners();
  }

  void enqueue(ExecutionRequest request) {
    queue.insert(0, request);
    _audit(
      'SIGNAL_QUEUED',
      '${request.symbol} ${request.direction} at ${request.confidence}% confidence.',
    );
    notifyListeners();
  }

  Future<String> approve(String requestId) async {
    final index = queue.indexWhere((e) => e.id == requestId);
    if (index < 0) throw StateError('Request not found.');

    final request = queue[index].copyWith(approved: true);
    queue[index] = request;
    _audit('TRADE_APPROVED', '${request.symbol} ${request.direction} approved.');

    if (!liveModeRequested) {
      notifyListeners();
      return 'Demo approval recorded. No live trade was placed.';
    }

    if (killSwitch) {
      notifyListeners();
      return 'Blocked by emergency kill switch.';
    }

    if (!adapter.isConfigured || !adapter.isConnected) {
      notifyListeners();
      return 'Blocked: authorized execution connector is not configured.';
    }

    final result = await adapter.submitApprovedTrade(request);
    _audit('TRADE_SUBMITTED', result);
    notifyListeners();
    return result;
  }

  void reject(String requestId) {
    queue.removeWhere((e) => e.id == requestId);
    _audit('TRADE_REJECTED', 'Approval request $requestId was rejected.');
    notifyListeners();
  }

  void _audit(String action, String detail) {
    auditLog.insert(
      0,
      AuditEntry(time: DateTime.now(), action: action, detail: detail),
    );
  }
}
