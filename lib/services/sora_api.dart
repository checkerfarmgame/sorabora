import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sora2_pro_app/models/device_state.dart';

final soraApiConfigProvider =
    Provider<SoraApiConfig>((_) => SoraApiConfig.fromEnvironment());
final soraApiProvider = Provider<SoraApi>((ref) => SoraApi(ref));
final soraStateProvider = FutureProvider<DeviceState>((ref) async {
  final api = ref.read(soraApiProvider);
  return api.fetchStatus();
});

final telemetryProvider =
    StateNotifierProvider<TelemetryNotifier, AsyncValue<Telemetry>>(
  (ref) => TelemetryNotifier(ref.read(soraApiProvider)),
);

class SoraApiConfig {
  const SoraApiConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
    this.timeout = const Duration(seconds: 6),
  });

  final Uri baseUrl;
  final String username;
  final String password;
  final Duration timeout;

  factory SoraApiConfig.fromEnvironment({Uri? fallbackBaseUrl}) {
    final base = const String.fromEnvironment(
      'SORA_BASE_URL',
      defaultValue: 'https://sora-2-pro.local/api',
    );
    return SoraApiConfig(
      baseUrl: fallbackBaseUrl ?? Uri.parse(base),
      username: const String.fromEnvironment('SORA_USERNAME', defaultValue: ''),
      password: const String.fromEnvironment('SORA_PASSWORD', defaultValue: ''),
    );
  }

  Uri endpoint(String path) {
    final sanitized = baseUrl.toString().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$sanitized/$path');
  }

  Map<String, String> get headers {
    final auth = base64Encode(utf8.encode('$username:$password'));
    return {
      HttpHeaders.authorizationHeader: 'Basic $auth',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
  }
}

class SoraApi {
  SoraApi(this.ref, {http.Client? client, SoraApiConfig? config})
      : _client = client ?? http.Client(),
        _config = config ?? ref.read(soraApiConfigProvider);

  final Ref ref;
  final http.Client _client;
  final SoraApiConfig _config;

  Future<DeviceState> fetchStatus() async {
    final uri = _config.endpoint('status');
    final response =
        await _client.get(uri, headers: _config.headers).timeout(_config.timeout);
    _ensureSuccess(response, 'status');
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return DeviceState.fromJson(payload);
  }

  Future<Telemetry> fetchTelemetry() async {
    final uri = _config.endpoint('telemetry');
    final response =
        await _client.get(uri, headers: _config.headers).timeout(_config.timeout);
    _ensureSuccess(response, 'telemetry');
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return Telemetry.fromJson(payload);
  }

  Future<void> sendCommand(String command) async {
    final uri = _config.endpoint('commands');
    final response = await _client
        .post(
          uri,
          headers: _config.headers,
          body: jsonEncode({'command': command}),
        )
        .timeout(_config.timeout);
    _ensureSuccess(response, 'commands');
  }

  void refreshStatus() {
    ref.invalidate(soraStateProvider);
  }

  void _ensureSuccess(http.Response response, String operation) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw HttpException(
      'Sora-2 Pro $operation failed (${response.statusCode}): ${response.body}',
      uri: response.request?.url,
    );
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
