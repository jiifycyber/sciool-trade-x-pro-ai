import '../integration/connector_models.dart';

abstract class AuthorizedExecutionAdapter {
  String get providerName;
  bool get isConfigured;
  bool get isConnected;

  Future<ConnectorStatus> healthCheck();

  Future<String> submitApprovedTrade(ExecutionRequest request);
}

/// Locked placeholder for Pocket Option.
///
/// Replace this class only when a documented, authorized integration method
/// is available for the account. Do not add credential scraping, browser
/// automation, DOM clicking, or undocumented WebSocket access.
class PocketOptionAuthorizedAdapter implements AuthorizedExecutionAdapter {
  @override
  String get providerName => 'Pocket Option';

  @override
  bool get isConfigured => false;

  @override
  bool get isConnected => false;

  @override
  Future<ConnectorStatus> healthCheck() async {
    return ConnectorStatus(
      name: providerName,
      state: ConnectorState.locked,
      message:
          'Execution locked: no authorized account integration is configured.',
      checkedAt: DateTime.now(),
    );
  }

  @override
  Future<String> submitApprovedTrade(ExecutionRequest request) {
    throw StateError(
      'Pocket Option live execution is locked until an authorized integration is configured.',
    );
  }
}
