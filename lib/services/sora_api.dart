import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sora2_pro_app/models/device_state.dart';

final soraApiProvider = Provider<SoraApi>(
  (ref) => SoraApi(ref, config: const SoraApiConfig.fromEnvironment()),
);
final soraStateProvider = FutureProvider<DeviceState>((ref) async {
  final api = ref.read(soraApiProvider);
  return api.fetchStatus();
});

final telemetryProvider = StateNotifierProvider<TelemetryNotifier, AsyncValue<Telemetry>>(
  (ref) => TelemetryNotifier(ref.read(soraApiProvider)),
);

class SoraApiConfig {
  const SoraApiConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  /// Reads credentials from `--dart-define` flags.
  ///
  /// Set them when running the app, for example:
  /// `flutter run --dart-define=SORA_API_BASE_URL=https://192.168.0.88 --dart-define=SORA_API_USER=admin --dart-define=SORA_API_PASS=secret`
  const SoraApiConfig.fromEnvironment({
    String defaultBaseUrl = 'https://controller.example.com',
    String defaultUsername = 'admin',
    String defaultPassword = 'password',
  })  : baseUrl = const String.fromEnvironment('SORA_API_BASE_URL', defaultValue: defaultBaseUrl),
        username = const String.fromEnvironment('SORA_API_USER', defaultValue: defaultUsername),
        password = const String.fromEnvironment('SORA_API_PASS', defaultValue: defaultPassword);

  final String baseUrl;
  final String username;
  final String password;

  Map<String, String> buildHeaders() {
    final basicAuth = base64Encode(utf8.encode('$username:$password'));
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Basic $basicAuth',
    };
  }
}

class SoraApi {
  SoraApi(this.ref, {required SoraApiConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  final Ref ref;
  final SoraApiConfig _config;
  final http.Client _client;

  Uri _buildUri(String path) => Uri.parse('${_config.baseUrl}$path');

  Future<DeviceState> fetchStatus() async {
    final response = await _client.get(
      _buildUri('/api/status'),
      headers: _config.buildHeaders(),
    );

    final body = _validateResponse(response);
    return DeviceState.fromJson(body);
  }

  Future<Telemetry> fetchTelemetry() async {
    final response = await _client.get(
      _buildUri('/api/telemetry'),
      headers: _config.buildHeaders(),
    );

    final body = _validateResponse(response);
    return Telemetry.fromJson(body);
  }

  Future<void> sendCommand(String command) async {
    final response = await _client.post(
      _buildUri('/api/command'),
      headers: _config.buildHeaders(),
      body: jsonEncode(<String, String>{'command': command}),
    );

    _validateResponse(response);
  }

  Map<String, dynamic> _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }

    throw Exception('Sora API responded with ${response.statusCode}: ${response.body}');
  }

  void refreshStatus() {
    ref.refresh(soraStateProvider.future);
  }
}

class TelemetryNotifier extends StateNotifier<AsyncValue<Telemetry>> {
  TelemetryNotifier(this.api) : super(const AsyncValue.loading()) {
    refresh();
  }

  final SoraApi api;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await api.fetchTelemetry();
      state = AsyncValue.data(data);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
