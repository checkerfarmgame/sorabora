import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/services/sora_api.dart';
import 'package:sora2_pro_app/widgets/device_control_panel.dart';
import 'package:sora2_pro_app/widgets/telemetry_panel.dart';

void main() {
  runApp(const ProviderScope(child: SoraApp()));
}

class SoraApp extends StatelessWidget {
  const SoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sora-2 Pro Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SoraHomePage(),
    );
  }
}

class SoraHomePage extends ConsumerWidget {
  const SoraHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(soraStateProvider);
    final telemetry = ref.watch(telemetryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sora-2 Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(soraApiProvider).refreshStatus();
              ref.read(telemetryProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: deviceState.when(
        data: (state) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeviceHeader(status: state.status, ip: state.ip),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: const [
                      Expanded(child: DeviceControlPanel()),
                      SizedBox(width: 12),
                      Expanded(child: TelemetryPanel()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Ошибка загрузки: $err'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  const _DeviceHeader({required this.status, required this.ip});

  final String status;
  final String ip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              status == 'online' ? Icons.check_circle : Icons.warning,
              color: status == 'online' ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Статус: $status',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('IP: $ip'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
