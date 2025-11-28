class SoraVideo {
  const SoraVideo({
    required this.id,
    required this.status,
    this.downloadUrl,
    this.previewUrl,
    this.prompt,
    this.durationSeconds,
    this.aspectRatio,
  });

  factory SoraVideo.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    return SoraVideo(
      id: json['id'] as String? ?? '-',
      status: json['status'] as String? ?? 'unknown',
      downloadUrl: json['download_url'] as String? ?? metadata?['download_url'] as String?,
      previewUrl: json['preview_url'] as String? ?? metadata?['preview_url'] as String?,
      prompt: json['prompt'] as String? ?? metadata?['prompt'] as String?,
      durationSeconds:
          (json['duration'] as num?)?.toInt() ?? (metadata?['duration'] as num?)?.toInt(),
      aspectRatio: json['aspect_ratio'] as String? ?? metadata?['aspect_ratio'] as String?,
    );
  }

  final String id;
  final String status;
  final String? downloadUrl;
  final String? previewUrl;
  final String? prompt;
  final int? durationSeconds;
  final String? aspectRatio;

  bool get isFinished => status.toLowerCase() == 'completed';
  bool get isRunning => status.toLowerCase() == 'running';
}
