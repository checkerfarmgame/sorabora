import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/services/sora_api.dart';

class VideoRequestForm extends ConsumerStatefulWidget {
  const VideoRequestForm({super.key});

  @override
  ConsumerState<VideoRequestForm> createState() => _VideoRequestFormState();
}

class _VideoRequestFormState extends ConsumerState<VideoRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  double _duration = 5;
  String _aspectRatio = '16:9';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(soraJobProvider.notifier).createJob(
          prompt: _promptController.text.trim(),
          durationSeconds: _duration.toInt(),
          aspectRatio: _aspectRatio,
        );
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(soraJobProvider);
    final isBusy = jobState.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Текстовый промпт',
              hintText: 'Опишите сценарий или сцену для Sora 2',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Промпт не должен быть пустым';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Длительность (секунды)'),
                    Slider(
                      value: _duration,
                      min: 2,
                      max: 10,
                      divisions: 8,
                      label: _duration.toStringAsFixed(0),
                      onChanged: isBusy
                          ? null
                          : (value) => setState(() {
                                _duration = value;
                              }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _aspectRatio,
                  decoration: const InputDecoration(
                    labelText: 'Соотношение сторон',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '16:9', child: Text('16:9')),
                    DropdownMenuItem(value: '9:16', child: Text('9:16')),
                    DropdownMenuItem(value: '1:1', child: Text('1:1')),
                  ],
                  onChanged: isBusy
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _aspectRatio = value);
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            onPressed: isBusy ? null : _submit,
            label: const Text('Отправить в Sora 2'),
          ),
        ],
      ),
    );
  }
}
