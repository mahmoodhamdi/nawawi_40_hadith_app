import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hadith.dart';
import '../widgets/audio_player_widget.dart';

class HadithDetailsScreen extends StatefulWidget {
  final int index;
  final Hadith hadith;

  const HadithDetailsScreen({
    super.key,
    required this.index,
    required this.hadith,
  });

  @override
  State<HadithDetailsScreen> createState() => _HadithDetailsScreenState();
}

class _HadithDetailsScreenState extends State<HadithDetailsScreen> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  double _playbackSpeed = 1.0;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
    _positionSub = _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (mounted) setState(() => isPlaying = state.playing);
    });
  }

  Future<void> _loadAudio() async {
    try {
      // Renamed asset file to audio_1.mp3, audio_2.mp3, etc.
      final path = 'assets/audio/audio_${widget.index}.mp3';
      debugPrint('Loading audio from path: $path');

      await _player.setAsset(path);
      _duration = _player.duration ?? Duration.zero;
      debugPrint('Audio loaded successfully. Duration: $_duration');
    } catch (e, stackTrace) {
      debugPrint('Error loading audio: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الملف الصوتي: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _seekTo(Duration position) {
    _player.seek(position);
  }

  void _skipForward() {
    final newPos = _position + const Duration(seconds: 10);
    if (newPos < _duration) {
      _seekTo(newPos);
    } else {
      _seekTo(_duration);
    }
  }

  void _skipBackward() {
    final newPos = _position - const Duration(seconds: 10);
    if (newPos > Duration.zero) {
      _seekTo(newPos);
    } else {
      _seekTo(Duration.zero);
    }
  }

  void _replay() {
    _seekTo(Duration.zero);
    _player.play();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _player.setSpeed(speed);
  }

  void _shareHadithOnly() {
    Share.share(widget.hadith.hadith);
  }

  void _shareDescriptionOnly() {
    Share.share(widget.hadith.description);
  }

  void _shareBoth() {
    Share.share('${widget.hadith.hadith}\n\n${widget.hadith.description}');
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.short_text),
                  title: const Text('مشاركة الحديث فقط'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareHadithOnly();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('مشاركة الشرح فقط'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareDescriptionOnly();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: const Text('مشاركة الحديث مع الشرح'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareBoth();
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hadith.hadith.split('\n').first.trim()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
            tooltip: 'مشاركة',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(
                          widget.hadith.hadith
                              .split('\n')
                              .skip(1)
                              .join('\n')
                              .trim(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                          contextMenuBuilder: (context, editableTextState) {
                            return AdaptiveTextSelectionToolbar.editableText(
                              editableTextState: editableTextState,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : AudioPlayerWidget(
                              player: _player,
                              isPlaying: isPlaying,
                              duration: _duration,
                              position: _position,
                              isLoading: _isLoading,
                              onPlayPause: _togglePlayPause,
                              onReplay: _replay,
                              onSkipForward: _skipForward,
                              onSkipBackward: _skipBackward,
                              onSeek: _seekTo,
                              onSpeedChanged: _changePlaybackSpeed,
                              playbackSpeed: _playbackSpeed,
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'الشرح:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          widget.hadith.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                          contextMenuBuilder: (context, editableTextState) {
                            return AdaptiveTextSelectionToolbar.editableText(
                              editableTextState: editableTextState,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
