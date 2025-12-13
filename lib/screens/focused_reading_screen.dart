import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../core/l10n/app_localizations.dart';
import '../cubit/audio_player_cubit.dart';
import '../cubit/font_size_cubit.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../cubit/language_cubit.dart';
import '../cubit/reading_stats_cubit.dart';
import '../models/hadith.dart';

/// A distraction-free, immersive reading screen for hadiths
class FocusedReadingScreen extends StatefulWidget {
  final int initialIndex;
  final Hadith initialHadith;

  const FocusedReadingScreen({
    super.key,
    required this.initialIndex,
    required this.initialHadith,
  });

  @override
  State<FocusedReadingScreen> createState() => _FocusedReadingScreenState();
}

class _FocusedReadingScreenState extends State<FocusedReadingScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _showControls = true;
  late AnimationController _fadeController;
  late PageController _pageController;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex - 1);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    // Enter immersive mode
    _enterImmersiveMode();

    // Load audio for current hadith
    context.read<AudioPlayerCubit>().loadAudio(_currentIndex);

    // Mark as read
    context.read<ReadingStatsCubit>().markAsRead(_currentIndex);

    // Auto-hide controls after 3 seconds
    _scheduleHideControls();
  }

  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  void _scheduleHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _scheduleHideControls();
    }
  }

  void _onPageChanged(int pageIndex) {
    final newIndex = pageIndex + 1;
    final hadithState = context.read<HadithCubit>().state;

    if (hadithState is HadithLoaded && newIndex <= hadithState.hadiths.length) {
      setState(() {
        _currentIndex = newIndex;
      });

      // Load new audio
      context.read<AudioPlayerCubit>().loadAudio(newIndex);

      // Mark as read
      context.read<ReadingStatsCubit>().markAsRead(newIndex);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    _exitImmersiveMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ],
                ),
              ),
            ),

            // Main content - PageView for swiping
            BlocBuilder<HadithCubit, HadithState>(
              builder: (context, hadithState) {
                if (hadithState is! HadithLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: hadithState.hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadithState.hadiths[index];
                    return _buildHadithPage(hadith, index + 1);
                  },
                );
              },
            ),

            // Top controls (back button, hadith number)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Hadith number and title
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          final languageCode = context.watch<LanguageCubit>().state.language.code;
                          final hadithState = context.watch<HadithCubit>().state;
                          final hadithTitle = hadithState is HadithLoaded
                              ? hadithState.hadiths[_currentIndex - 1].getTitle(languageCode)
                              : '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.hadithTitle(_currentIndex),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hadithTitle.isNotEmpty)
                                  Text(
                                    hadithTitle,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(220),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Toggle description button
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return IconButton(
                            icon: Icon(
                              _showDescription ? Icons.article : Icons.article_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _showDescription = !_showDescription;
                              });
                            },
                            tooltip: _showDescription
                                ? (l10n.isArabic ? 'إخفاء الشرح' : 'Hide explanation')
                                : (l10n.isArabic ? 'عرض الشرح' : 'Show explanation'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom controls (audio, navigation hints)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio controls
                      _buildAudioControls(),

                      // Navigation hint
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swipe,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.swipeToNavigate,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Page indicator dots
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildPageIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithPage(Hadith hadith, int index) {
    return BlocBuilder<FontSizeCubit, FontSizeState>(
      builder: (context, fontState) {
        final languageCode = context.watch<LanguageCubit>().state.language.code;
        final l10n = AppLocalizations.of(context);
        final isArabic = l10n.isArabic;
        final hadithText = hadith.getHadith(languageCode);
        final descriptionText = hadith.getDescription(languageCode);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative element
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              // Hadith text
              Text(
                _getHadithText(hadithText),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: fontState.hadithFontSize + 4,
                  height: 2.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),

              // Description (if shown) with markdown support
              if (_showDescription && descriptionText.isNotEmpty) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.isArabic ? 'الشرح' : 'Explanation',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Directionality(
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        child: MarkdownBody(
                          data: descriptionText,
                          styleSheet: _getFocusedMarkdownStyle(
                            context,
                            fontState.descriptionFontSize,
                            isArabic,
                          ),
                          selectable: true,
                          softLineBreak: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Decorative element
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioControls() {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Progress bar
              if (audioState.duration.inSeconds > 0)
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: const Color(0xFFD4AF37),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: const Color(0xFFD4AF37),
                    overlayColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                  child: Slider(
                    value: audioState.position.inSeconds.toDouble(),
                    max: audioState.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      context.read<AudioPlayerCubit>().seekTo(
                        Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // Controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip backward
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: () => context.read<AudioPlayerCubit>().skipBackward(),
                  ),

                  // Play/Pause
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 32,
                      ),
                      onPressed: () =>
                          context.read<AudioPlayerCubit>().togglePlayPause(),
                    ),
                  ),

                  // Skip forward
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: () => context.read<AudioPlayerCubit>().skipForward(),
                  ),
                ],
              ),

              // Time display
              if (audioState.duration.inSeconds > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, hadithState) {
        if (hadithState is! HadithLoaded) return const SizedBox.shrink();

        final totalPages = hadithState.hadiths.length;

        // Show simplified indicator for many pages
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_currentIndex',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / $totalPages',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getHadithText(String hadithText) {
    final lines = hadithText.split('\n');
    if (lines.length > 1) {
      return lines.skip(1).join('\n').trim();
    }
    return hadithText;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Custom markdown style for focused reading mode (dark theme)
  MarkdownStyleSheet _getFocusedMarkdownStyle(
    BuildContext context,
    double baseFontSize,
    bool isArabic,
  ) {
    const goldColor = Color(0xFFD4AF37);
    const whiteText = Colors.white;

    return MarkdownStyleSheet(
      // Headers
      h2: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.bold,
        color: goldColor,
        height: 1.4,
      ),
      h3: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w600,
        color: goldColor.withValues(alpha: 0.9),
        height: 1.3,
      ),

      // Paragraphs
      p: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize,
        height: 1.8,
        color: whiteText.withValues(alpha: 0.85),
      ),

      // Strong (bold)
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: goldColor,
      ),

      // Emphasis (italic)
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: whiteText.withValues(alpha: 0.9),
      ),

      // Lists
      listBullet: TextStyle(
        fontSize: baseFontSize,
        color: goldColor,
      ),
      listIndent: 20.0,

      // Blockquote
      blockquote: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize,
        fontStyle: FontStyle.italic,
        color: whiteText.withValues(alpha: 0.8),
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: isArabic
              ? BorderSide.none
              : BorderSide(
                  color: goldColor.withValues(alpha: 0.5),
                  width: 3,
                ),
          right: isArabic
              ? BorderSide(
                  color: goldColor.withValues(alpha: 0.5),
                  width: 3,
                )
              : BorderSide.none,
        ),
        color: whiteText.withValues(alpha: 0.05),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),

      // Spacing
      h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
      pPadding: const EdgeInsets.only(bottom: 10),
      blockSpacing: 10.0,
    );
  }
}
