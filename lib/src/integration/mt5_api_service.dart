import 'dart:convert';

import 'package:http/http.dart' as http;

class Mt5ApiException implements Exception {
  const Mt5ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Mt5ApiService {
  Mt5ApiService({
    this.baseUrl = 'http://192.168.0.151:8000',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> getHealth() => _getMap('/health');

  Future<Map<String, dynamic>> getAccount() => _getMap('/account');

  Future<Map<String, dynamic>> getPrice(String symbol) =>
      _getMap('/price/${symbol.toUpperCase()}');

  Future<Map<String, dynamic>> getSignal({
    required String symbol,
    String timeframe = 'M1',
  }) =>
      _getMap(
        '/signal/${symbol.toUpperCase()}'
        '?timeframe=${timeframe.toUpperCase()}',
      );

  Future<Map<String, dynamic>> getScanner({
    String timeframe = 'M1',
  }) =>
      _getMap(
        '/scanner?timeframe=${timeframe.toUpperCase()}',
      );

  Future<List<Map<String, dynamic>>> getPositions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/positions'),
    );

    final data = _decode(response);

    if (data is! List) {
      throw const Mt5ApiException(
        'Invalid positions response.',
      );
    }

    return data
        .map(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getCandles({
    required String symbol,
    String timeframe = 'M1',
    int count = 250,
  }) {
    return _getMap(
      '/candles/${symbol.toUpperCase()}'
      '?timeframe=${timeframe.toUpperCase()}'
      '&count=$count',
    );
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
    );

    final data = _decode(response);

    if (data is! Map) {
      throw const Mt5ApiException(
        'Invalid MT5 response.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  dynamic _decode(http.Response response) {
    dynamic body;

    try {
      body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      throw Mt5ApiException(
        'MT5 bridge returned invalid data '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body is Map ? body['detail']?.toString() : null;

      throw Mt5ApiException(
        detail ?? 'MT5 request failed.',
      );
    }

    return body;
  }

  void dispose() {
    _client.close();
  }
}
