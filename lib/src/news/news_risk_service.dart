class NewsRiskService {
  /// Locked placeholder.
  ///
  /// Connect an authorized economic-calendar provider before enabling this
  /// filter. Until then, the signal engine must not claim that news risk is
  /// clear.
  bool get isConfigured => false;

  Future<bool> hasHighImpactEventNear({
    required String symbol,
    required DateTime time,
    Duration window = const Duration(minutes: 30),
  }) async {
    throw StateError('Economic-calendar provider is not configured.');
  }
}
