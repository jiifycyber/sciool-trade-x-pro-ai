enum MarketDataProvider {
  automatic,
  metaTrader5,
  twelveData,
}

class MarketProviderConfig {
  static MarketDataProvider selectedProvider =
      MarketDataProvider.automatic;

  static const String mt5BaseUrl =
      'http://192.168.0.151:8000';
}