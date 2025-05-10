import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioPlayer player;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;
  final ValueChanged<Duration> onSeek;

  const AudioPlayerWidget({
    super.key,
    required this.player,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.isLoading,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.onSeek,
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
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Slider(
              value: position.inSeconds.toDouble().clamp(
                0,
                duration.inSeconds.toDouble(),
              ),
              min: 0,
              max: duration.inSeconds.toDouble(),
              onChanged: (value) => onSeek(Duration(seconds: value.toInt())),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(duration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: onSkipBackward,
                  tooltip: 'رجوع 10 ثواني',
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: onReplay,
                  tooltip: 'إعادة',
                  color: theme.colorScheme.primary,
                ),
                IconButton(
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
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: onSkipForward,
                  tooltip: 'تقديم 10 ثواني',
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        );
  }
}
