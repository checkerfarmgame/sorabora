import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/services/sora_api.dart';

class DeviceControlPanel extends ConsumerStatefulWidget {
  const DeviceControlPanel({super.key});

  @override
  ConsumerState<DeviceControlPanel> createState() => _DeviceControlPanelState();
}

class _DeviceControlPanelState extends ConsumerState<DeviceControlPanel> {
  String _selectedMode = 'Auto';
  bool _busy = false;

  Future<void> _sendCommand(String cmd) async {
    setState(() => _busy = true);
    try {
      await ref.read(soraApiProvider).sendCommand(cmd);
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _busy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Управление', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              decoration: const InputDecoration(labelText: 'Режим работы'),
              items: const [
                DropdownMenuItem(value: 'Auto', child: Text('Auto')),
                DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                DropdownMenuItem(value: 'Safe', child: Text('Safe')),
              ],
              onChanged: disabled
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedMode = value);
                        _sendCommand('mode:$value');
                      }
                    },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              onPressed: disabled ? null : () => _sendCommand('start'),
              label: const Text('Старт'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.stop),
              onPressed: disabled ? null : () => _sendCommand('stop'),
              label: const Text('Стоп'),
            ),
          ],
        ),
      ),
    );
  }
}
