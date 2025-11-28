import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/models/device_state.dart';

final soraApiProvider = Provider<SoraApi>((ref) => SoraApi(ref));
final soraStateProvider = FutureProvider<DeviceState>((ref) async {
  final api = ref.read(soraApiProvider);
  return api.fetchStatus();
});

final telemetryProvider = StateNotifierProvider<TelemetryNotifier, AsyncValue<Telemetry>>(
  (ref) => TelemetryNotifier(ref.read(soraApiProvider)),
);

class SoraApi {
  SoraApi(this.ref);

  final Ref ref;

  Future<DeviceState> fetchStatus() async {
    // TODO: Replace with real HTTP call to Sora-2 Pro controller.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const DeviceState(status: 'online', ip: '192.168.0.88', mode: 'Auto');
  }

  Future<Telemetry> fetchTelemetry() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Telemetry(temperature: 36.5, battery: 82, signal: 74);
  }

  Future<void> sendCommand(String command) async {
    // TODO: Replace with actual POST/PUT to device
    await Future<void>.delayed(const Duration(milliseconds: 300));
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
