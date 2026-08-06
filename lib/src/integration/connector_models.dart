enum ConnectorState { disconnected, configured, connected, error, locked }

class ConnectorStatus {
  final String name;
  final ConnectorState state;
  final String message;
  final DateTime checkedAt;

  const ConnectorStatus({
    required this.name,
    required this.state,
    required this.message,
    required this.checkedAt,
  });
}

class ExecutionRequest {
  final String id;
  final String symbol;
  final String direction;
  final double amount;
  final int expirationMinutes;
  final int confidence;
  final bool approved;
  final DateTime createdAt;

  const ExecutionRequest({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.amount,
    required this.expirationMinutes,
    required this.confidence,
    required this.approved,
    required this.createdAt,
  });

  ExecutionRequest copyWith({bool? approved}) => ExecutionRequest(
        id: id,
        symbol: symbol,
        direction: direction,
        amount: amount,
        expirationMinutes: expirationMinutes,
        confidence: confidence,
        approved: approved ?? this.approved,
        createdAt: createdAt,
      );
}

class AuditEntry {
  final DateTime time;
  final String action;
  final String detail;

  const AuditEntry({
    required this.time,
    required this.action,
    required this.detail,
  });
}
