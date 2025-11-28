class DeviceState {
  const DeviceState({
    required this.status,
    required this.ip,
    required this.mode,
  });

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      status: json['status'] as String? ?? 'unknown',
      ip: json['ip'] as String? ?? '-',
      mode: json['mode'] as String? ?? 'Manual',
    );
  }

  final String status;
  final String ip;
  final String mode;
}

class Telemetry {
  const Telemetry({
    required this.temperature,
    required this.battery,
    required this.signal,
  });

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      signal: (json['signal'] as num?)?.toInt() ?? 0,
    );
  }

  final double temperature;
  final int battery;
  final int signal;
}
