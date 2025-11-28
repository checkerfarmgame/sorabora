import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sora2_pro_app/models/device_state.dart';

final soraApiProvider = Provider<SoraApi>(
  (ref) => SoraApi(ref, config: const SoraApiConfig.fromEnvironment()),
);

final soraJobProvider = StateNotifierProvider<SoraJobNotifier, AsyncValue<SoraVideo?>>(
  (ref) => SoraJobNotifier(ref.read(soraApiProvider)),
);

class SoraApiConfig {
  const SoraApiConfig({
    required this.baseUrl,
    required this.apiKey,
  });

  /// Reads credentials from `--dart-define` flags.
  ///
  /// Set them when running the app, for example:
  /// `flutter run --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1 --dart-define=OPENAI_API_KEY=sk-...`
  const SoraApiConfig.fromEnvironment({
    String defaultBaseUrl = 'https://api.openai.com/v1',
    String defaultApiKey = 'sk-REPLACE_ME',
  })  : baseUrl =
            const String.fromEnvironment('OPENAI_BASE_URL', defaultValue: defaultBaseUrl),
        apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: defaultApiKey);

  final String baseUrl;
  final String apiKey;

  Map<String, String> buildHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
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

  Future<SoraVideo> createVideo({
    required String prompt,
    int durationSeconds = 5,
    String aspectRatio = '16:9',
  }) async {
    final response = await _client.post(
      _buildUri('/videos'),
      headers: _config.buildHeaders(),
      body: jsonEncode(<String, dynamic>{
        'model': 'sora-2',
        'prompt': prompt,
        'duration': durationSeconds,
        'aspect_ratio': aspectRatio,
      }),
    );

    final body = _validateResponse(response);
    return SoraVideo.fromJson(body);
  }

  Future<SoraVideo> fetchVideo(String id) async {
    final response = await _client.get(
      _buildUri('/videos/$id'),
      headers: _config.buildHeaders(),
    );

    final body = _validateResponse(response);
    return SoraVideo.fromJson(body);
  }

  Map<String, dynamic> _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }

    throw Exception('OpenAI responded with ${response.statusCode}: ${response.body}');
  }
}

class SoraJobNotifier extends StateNotifier<AsyncValue<SoraVideo?>> {
  SoraJobNotifier(this.api) : super(const AsyncValue.data(null));

  final SoraApi api;

  Future<void> createJob({
    required String prompt,
    required int durationSeconds,
    required String aspectRatio,
  }) async {
    state = const AsyncValue.loading();
    try {
      final video = await api.createVideo(
        prompt: prompt,
        durationSeconds: durationSeconds,
        aspectRatio: aspectRatio,
      );
      state = AsyncValue.data(video);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> refreshJob() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    try {
      final video = await api.fetchVideo(current.id);
      state = AsyncValue.data(video);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
