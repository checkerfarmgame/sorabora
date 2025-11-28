import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sora2_pro_app/services/sora_api.dart';
import 'package:sora2_pro_app/widgets/video_request_form.dart';

void main() {
  runApp(const ProviderScope(child: SoraApp()));
}

class SoraApp extends StatelessWidget {
  const SoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sora 2 Playground',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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
    final jobState = ref.watch(soraJobProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sora 2 (OpenAI)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить статус',
            onPressed: jobState.value == null
                ? null
                : () => ref.read(soraJobProvider.notifier).refreshJob(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Отправляйте подсказки напрямую в модель Sora 2 через OpenAI API.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const VideoRequestForm(),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: jobState.when(
                      data: (video) => video == null
                          ? const Center(
                              child: Text(
                                'Сначала отправьте запрос, чтобы увидеть статус задачи.',
                              ),
                            )
                          : _VideoStatus(video: video),
                      error: (err, stack) => Center(
                        child: Text('Ошибка: $err'),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoStatus extends StatelessWidget {
  const _VideoStatus({required this.video});

  final SoraVideo video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Задача: ${video.id}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              video.isFinished ? Icons.check_circle : Icons.timer,
              color: video.isFinished ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text('Статус: ${video.status}'),
          ],
        ),
        if (video.prompt != null) ...[
          const SizedBox(height: 8),
          Text('Промпт:', style: Theme.of(context).textTheme.titleSmall),
          Text(video.prompt!),
        ],
        if (video.durationSeconds != null || video.aspectRatio != null) ...[
          const SizedBox(height: 8),
          Text(
            'Параметры: ' +
                [
                  if (video.durationSeconds != null) 'длительность ${video.durationSeconds}s',
                  if (video.aspectRatio != null) 'соотношение ${video.aspectRatio}',
                ].join(', '),
          ),
        ],
        const SizedBox(height: 12),
        if (video.previewUrl != null)
          SelectableText('Превью: ${video.previewUrl}'),
        if (video.downloadUrl != null)
          SelectableText('Ссылка на видео: ${video.downloadUrl}'),
      ],
    );
  }
}
