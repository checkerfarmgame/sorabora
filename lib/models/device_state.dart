class DeviceState {
  const DeviceState({
    required this.status,
    required this.ip,
    required this.mode,
  });

  final String status;
  final String ip;
  final String mode;

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      status: json['status'] as String? ?? 'unknown',
      ip: json['ip'] as String? ?? '0.0.0.0',
      mode: json['mode'] as String? ?? 'Auto',
    );
  }
}

class Telemetry {
  const Telemetry({
    required this.temperature,
    required this.battery,
    required this.signal,
  });

  final double temperature;
  final int battery;
  final int signal;

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      signal: (json['signal'] as num?)?.toInt() ?? 0,
    );
  }
}
