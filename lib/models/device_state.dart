class DeviceState {
  const DeviceState({
    required this.status,
    required this.ip,
    required this.mode,
  });

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

  final double temperature;
  final int battery;
  final int signal;
}
