import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../cubit/last_read_cubit.dart';
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

  // Font size state variables
  double _hadithFontSize = 18.0;
  double _descriptionFontSize = 16.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 30.0;
  final double _fontSizeStep = 2.0;

  // Save the current hadith as last read
  void _saveLastReadHadith() {
    context.read<LastReadCubit>().updateLastReadHadith(widget.index);
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
    _loadFontSizePreferences();
    // Update last read information when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveLastReadHadith();
    });
    _positionSub = _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (mounted) setState(() => isPlaying = state.playing);
    });
  }

  Future<void> _loadFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hadithFontSize = prefs.getDouble('hadith_font_size') ?? 18.0;
      _descriptionFontSize = prefs.getDouble('description_font_size') ?? 16.0;
    });
  }

  Future<void> _saveFontSizePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hadith_font_size', _hadithFontSize);
    await prefs.setDouble('description_font_size', _descriptionFontSize);
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

  // Font size adjustment methods
  void _increaseHadithFontSize() {
    setState(() {
      if (_hadithFontSize < _maxFontSize) {
        _hadithFontSize += _fontSizeStep;
        _saveFontSizePreferences();
      }
    });
  }

  void _decreaseHadithFontSize() {
    setState(() {
      if (_hadithFontSize > _minFontSize) {
        _hadithFontSize -= _fontSizeStep;
        _saveFontSizePreferences();
      }
    });
  }

  void _increaseDescriptionFontSize() {
    setState(() {
      if (_descriptionFontSize < _maxFontSize) {
        _descriptionFontSize += _fontSizeStep;
        _saveFontSizePreferences();
      }
    });
  }

  void _decreaseDescriptionFontSize() {
    setState(() {
      if (_descriptionFontSize > _minFontSize) {
        _descriptionFontSize -= _fontSizeStep;
        _saveFontSizePreferences();
      }
    });
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Card(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الحديث:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.text_increase),
                                    onPressed: _increaseHadithFontSize,
                                    tooltip: 'زيادة حجم الخط',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease),
                                    onPressed: _decreaseHadithFontSize,
                                    tooltip: 'تقليل حجم الخط',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.hadith.hadith
                                .split('\n')
                                .skip(1)
                                .join('\n')
                                .trim(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: _hadithFontSize,
                                ),
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
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Card(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الشرح:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.text_increase),
                                    onPressed: _increaseDescriptionFontSize,
                                    tooltip: 'زيادة حجم الخط',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease),
                                    onPressed: _decreaseDescriptionFontSize,
                                    tooltip: 'تقليل حجم الخط',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            widget.hadith.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: _descriptionFontSize),
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
                ),
                // Add Next and Previous Hadith Navigation Buttons
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavigationButton(
                          context: context,
                          icon: Icons.arrow_back_ios_rounded,
                          label: 'الحديث السابق',
                          onPressed: widget.index > 1
                              ? () => _navigateToHadith(widget.index - 1)
                              : null,
                        ),
                        _buildNavigationButton(
                          context: context,
                          icon: Icons.arrow_forward_ios_rounded,
                          label: 'الحديث التالي',
                          onPressed: widget.index < 42
                              ? () => _navigateToHadith(widget.index + 1)
                              : null,
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

  /// Navigate to a specific hadith by index
  void _navigateToHadith(int index) async {
    // Show loading indicator while fetching the hadith
    setState(() => _isLoading = true);
    
    try {
      // First ensure hadiths are loaded
      final hadithCubit = context.read<HadithCubit>();
      final hadithState = hadithCubit.state;
      
      // If hadiths aren't loaded yet, load them first
      if (hadithState is! HadithLoaded) {
        debugPrint('Hadiths not loaded yet, fetching them now...');
        await hadithCubit.fetchHadiths();
      }
      
      // Check again after potential loading
      final currentState = hadithCubit.state;
      debugPrint('Current state after fetch: ${currentState.runtimeType}');
      
      if (currentState is HadithLoaded) {
        final hadiths = currentState.hadiths;
        debugPrint('Found ${hadiths.length} hadiths, navigating to index $index');
        
        if (index > 0 && index <= hadiths.length) {
          // Pause audio if playing
          if (_player.playing) {
            await _player.pause();
          }
          
          // Replace current screen with new hadith details screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HadithDetailsScreen(
                  index: index,
                  hadith: hadiths[index - 1], // Adjust for 0-based index
                ),
              ),
            );
          }
        } else {
          debugPrint('Invalid index: $index (valid range: 1-${hadiths.length})');
        }
      } else {
        debugPrint('Failed to load hadiths: ${currentState.runtimeType}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تحميل الأحاديث، الرجاء المحاولة مرة أخرى'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error navigating to hadith: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    
    // Reset loading state if we're still on this screen
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Build a navigation button with icon and label
  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    final theme = Theme.of(context);
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? theme.disabledColor.withOpacity(0.1)
                : theme.colorScheme.primary,
            foregroundColor: isDisabled
                ? theme.disabledColor
                : theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: isDisabled ? 0 : 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
