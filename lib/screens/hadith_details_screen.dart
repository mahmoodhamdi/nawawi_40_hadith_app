import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hadith.dart';

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
      final path = 'assets/audio/الحديث_${widget.index}.mp3';
      await _player.setAsset(path);
      _duration = _player.duration ?? Duration.zero;
    } catch (e) {
      debugPrint("فشل تحميل الملف الصوتي: $e");
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: Text('الحديث رقم ${widget.index}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _showShareOptions,
              tooltip: 'مشاركة',
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            ),
          ),
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
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.hadith.hadith,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                children: [
                                  Slider(
                                    value: _position.inSeconds.toDouble().clamp(
                                      0,
                                      _duration.inSeconds.toDouble(),
                                    ),
                                    min: 0,
                                    max: _duration.inSeconds.toDouble(),
                                    onChanged:
                                        (value) => _seekTo(
                                          Duration(seconds: value.toInt()),
                                        ),
                                    activeColor: Colors.blueAccent,
                                    inactiveColor: Colors.blueAccent
                                        .withOpacity(0.3),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.replay_10),
                                        onPressed: _skipBackward,
                                        tooltip: 'رجوع 10 ثواني',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.replay),
                                        onPressed: _replay,
                                        tooltip: 'إعادة',
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_fill,
                                          size: 40,
                                        ),
                                        onPressed: _togglePlayPause,
                                        tooltip:
                                            isPlaying
                                                ? 'إيقاف الصوت'
                                                : 'تشغيل الصوت',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.forward_10),
                                        onPressed: _skipForward,
                                        tooltip: 'تقديم 10 ثواني',
                                      ),
                                    ],
                                  ),
                                ],
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
                    color: Colors.white.withOpacity(0.93),
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
                          Text(
                            widget.hadith.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.end,
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
      ),
    );
  }
}
