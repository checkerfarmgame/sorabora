import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/services/sora_api.dart';

class TelemetryPanel extends ConsumerWidget {
  const TelemetryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Телеметрия', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            telemetry.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TelemetryRow(label: 'Температура', value: '${data.temperature.toStringAsFixed(1)} °C'),
                  _TelemetryRow(label: 'Батарея', value: '${data.battery}%'),
                  _TelemetryRow(label: 'Сигнал', value: '${data.signal}%'),
                ],
              ),
              error: (err, stack) => Text('Ошибка телеметрии: $err'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                tooltip: 'Обновить телеметрию',
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(telemetryProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryRow extends StatelessWidget {
  const _TelemetryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
