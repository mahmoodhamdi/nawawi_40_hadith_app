import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatelessWidget {
  // Made AudioPlayer optional to support both direct AudioPlayer and Cubit approaches
  final AudioPlayer? player;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double>? onSpeedChanged;
  final double playbackSpeed;

  const AudioPlayerWidget({
    super.key,
    this.player, // Made optional
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.isLoading,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.onSeek,
    this.onSpeedChanged,
    this.playbackSpeed = 1.0,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isLoading
        ? Semantics(
            label: 'جاري تحميل الصوت',
            child: const Center(child: CircularProgressIndicator()),
          )
        : Semantics(
            label: 'مشغل الصوت',
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Semantics(
                    label:
                        'شريط التقدم. الموقع الحالي ${_formatDuration(position)} من ${_formatDuration(duration)}',
                    slider: true,
                    value: '${(position.inSeconds / duration.inSeconds * 100).round()}%',
                    child: Slider(
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        duration.inSeconds.toDouble(),
                      ),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) =>
                          onSeek(Duration(seconds: value.toInt())),
                      activeColor: theme.colorScheme.primary,
                      inactiveColor:
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        label: 'الوقت الحالي',
                        child: Text(
                          _formatDuration(position),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Semantics(
                        label: 'المدة الكلية',
                        child: Text(
                          _formatDuration(duration),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'إعادة التشغيل من البداية',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.replay),
                          onPressed: onReplay,
                          tooltip: 'إعادة',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Semantics(
                        label: 'رجوع 10 ثواني',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.replay_10),
                          onPressed: onSkipBackward,
                          tooltip: 'رجوع 10 ثواني',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Semantics(
                        label: isPlaying ? 'إيقاف الصوت' : 'تشغيل الصوت',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 40,
                          ),
                          onPressed: onPlayPause,
                          tooltip: isPlaying ? 'إيقاف الصوت' : 'تشغيل الصوت',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Semantics(
                        label: 'تقديم 10 ثواني',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.forward_10),
                          onPressed: onSkipForward,
                          tooltip: 'تقديم 10 ثواني',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            label:
                                'سرعة التشغيل الحالية ${playbackSpeed}x. انقر للتغيير',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.speed),
                              onPressed: () {
                                // Cycle through speeds: 1.0 -> 1.5 -> 2.0 -> 1.0
                                double nextSpeed;
                                if (playbackSpeed == 1.0) {
                                  nextSpeed = 1.5;
                                } else if (playbackSpeed == 1.5) {
                                  nextSpeed = 2.0;
                                } else {
                                  nextSpeed = 1.0;
                                }
                                onSpeedChanged?.call(nextSpeed);
                              },
                              tooltip: 'تغيير سرعة التشغيل',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          ExcludeSemantics(
                            child: Text(
                              '${playbackSpeed}x',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
