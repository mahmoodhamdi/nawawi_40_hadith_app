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
import '../widgets/audio_player_widget.dart';

/// Colours for the immersive reader, derived from the app's active theme.
///
/// This screen used to paint a fixed navy gradient with gold accents no
/// matter which theme was selected, so it looked like a different app the
/// moment you opened it. Everything here is now a function of the current
/// [ThemeData], which means light, dark, blue, purple and sepia each get a
/// reader that belongs to them.
class _ReaderPalette {
  final Color top;
  final Color middle;
  final Color bottom;
  final Color text;
  final Color muted;
  final Color accent;
  final Color panel;
  final Color panelBorder;
  final Color control;
  final Color onControl;

  const _ReaderPalette({
    required this.top,
    required this.middle,
    required this.bottom,
    required this.text,
    required this.muted,
    required this.accent,
    required this.panel,
    required this.panelBorder,
    required this.control,
    required this.onControl,
  });

  factory _ReaderPalette.of(ThemeData theme) {
    final scheme = theme.colorScheme;
    final base = scheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    Color tint(Color over, double alpha) =>
        Color.alphaBlend(over.withValues(alpha: alpha), base);

    return _ReaderPalette(
      // A gentle vertical wash rather than a hard three-stop gradient: the
      // page should read like paper, not like a splash screen.
      top: tint(scheme.primary, isDark ? 0.14 : 0.03),
      middle: base,
      bottom: tint(scheme.primary, isDark ? 0.06 : 0.09),
      text: scheme.onSurface,
      muted: scheme.onSurface.withValues(alpha: 0.55),
      accent: scheme.secondary,
      panel: tint(scheme.primary, isDark ? 0.16 : 0.06),
      panelBorder: scheme.primary.withValues(alpha: 0.22),
      control: scheme.primary,
      onControl: scheme.onPrimary,
    );
  }
}

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
    final palette = _ReaderPalette.of(Theme.of(context));

    return Scaffold(
      backgroundColor: palette.middle,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Background wash
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [palette.top, palette.middle, palette.bottom],
                ),
              ),
            ),

            // Main content - PageView for swiping
            BlocBuilder<HadithCubit, HadithState>(
              builder: (context, hadithState) {
                if (hadithState is! HadithLoaded) {
                  return Center(
                    child: CircularProgressIndicator(color: palette.control),
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
                        icon: Icon(Icons.close, color: palette.text, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Hadith number and title
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          final languageCode = context
                              .watch<LanguageCubit>()
                              .state
                              .language
                              .code;
                          final hadithState = context
                              .watch<HadithCubit>()
                              .state;
                          final hadithTitle = hadithState is HadithLoaded
                              ? hadithState.hadiths[_currentIndex - 1].getTitle(
                                  languageCode,
                                )
                              : '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: palette.panel,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: palette.panelBorder),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.hadithTitle(_currentIndex),
                                  style: TextStyle(
                                    color: palette.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hadithTitle.isNotEmpty)
                                  Text(
                                    hadithTitle,
                                    style: TextStyle(
                                      color: palette.muted,
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
                              _showDescription
                                  ? Icons.article
                                  : Icons.article_outlined,
                              color: _showDescription
                                  ? palette.control
                                  : palette.text,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _showDescription = !_showDescription;
                              });
                            },
                            tooltip: _showDescription
                                ? (l10n.isArabic
                                      ? 'إخفاء الشرح'
                                      : 'Hide explanation')
                                : (l10n.isArabic
                                      ? 'عرض الشرح'
                                      : 'Show explanation'),
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
                                  color: palette.muted,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.swipeToNavigate,
                                  style: TextStyle(
                                    color: palette.muted,
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
        final palette = _ReaderPalette.of(Theme.of(context));
        final languageCode = context.watch<LanguageCubit>().state.language.code;
        final l10n = AppLocalizations.of(context);
        final isArabic = l10n.isArabic;
        final hadithText = _getHadithText(hadith.getHadith(languageCode));
        final descriptionText = hadith.getDescription(languageCode);

        // Centre-aligning a long paragraph makes every line start in a
        // different place and the eye loses the thread. Short narrations
        // still look better centred.
        final align = hadithText.length > 220
            ? TextAlign.justify
            : TextAlign.center;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Center(
            child: ConstrainedBox(
              // Keeps the line length readable on tablets and landscape
              // instead of stretching a single line across the screen.
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Ornament(palette: palette),
                  const SizedBox(height: 36),

                  Text(
                    hadithText,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: fontState.hadithFontSize + 4,
                      height: 2.1,
                      color: palette.text,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: align,
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),

                  if (_showDescription && descriptionText.isNotEmpty) ...[
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: palette.panel,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.panelBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.explanation.replaceAll(':', ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: palette.control,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Directionality(
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: MarkdownBody(
                              data: descriptionText,
                              styleSheet: _getFocusedMarkdownStyle(
                                palette,
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

                  const SizedBox(height: 36),
                  _Ornament(palette: palette, flipped: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioControls() {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        final theme = Theme.of(context);
        final palette = _ReaderPalette.of(theme);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.panelBorder),
          ),
          // The reader used to carry its own trimmed-down copy of the player,
          // which quietly lacked replay, playback speed, the loading state and
          // the accessibility labels the details screen has. Sharing the one
          // widget keeps the two from drifting apart again.
          child: AudioPlayerWidget(
            isPlaying: audioState.isPlaying,
            duration: audioState.duration,
            position: audioState.position,
            isLoading: audioState.isLoading,
            onPlayPause: () =>
                context.read<AudioPlayerCubit>().togglePlayPause(),
            onReplay: () => context.read<AudioPlayerCubit>().replay(),
            onSkipForward: () => context.read<AudioPlayerCubit>().skipForward(),
            onSkipBackward: () =>
                context.read<AudioPlayerCubit>().skipBackward(),
            onSeek: (pos) => context.read<AudioPlayerCubit>().seekTo(pos),
            onSpeedChanged: (speed) =>
                context.read<AudioPlayerCubit>().changePlaybackSpeed(speed),
            playbackSpeed: audioState.playbackSpeed,
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
        final palette = _ReaderPalette.of(Theme.of(context));

        // Show simplified indicator for many pages
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_currentIndex',
              style: TextStyle(
                color: palette.control,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / $totalPages',
              style: TextStyle(color: palette.muted, fontSize: 16),
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

  /// Markdown style for the reader, keyed off the same palette as the rest
  /// of the screen so the explanation panel matches the active theme.
  MarkdownStyleSheet _getFocusedMarkdownStyle(
    _ReaderPalette palette,
    double baseFontSize,
    bool isArabic,
  ) {
    final heading = palette.control;
    final body = palette.text.withValues(alpha: 0.88);

    return MarkdownStyleSheet(
      h2: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.bold,
        color: heading,
        height: 1.4,
      ),
      h3: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w600,
        color: heading.withValues(alpha: 0.9),
        height: 1.3,
      ),
      p: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize,
        height: 1.9,
        color: body,
      ),
      strong: TextStyle(fontWeight: FontWeight.bold, color: heading),
      em: TextStyle(fontStyle: FontStyle.italic, color: body),
      listBullet: TextStyle(fontSize: baseFontSize, color: heading),
      listIndent: 20.0,
      blockquote: TextStyle(
        fontFamily: 'Cairo',
        fontSize: baseFontSize,
        fontStyle: FontStyle.italic,
        color: palette.muted,
        height: 1.7,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: isArabic
              ? BorderSide.none
              : BorderSide(color: palette.accent, width: 3),
          right: isArabic
              ? BorderSide(color: palette.accent, width: 3)
              : BorderSide.none,
        ),
        color: palette.control.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
      h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
      pPadding: const EdgeInsets.only(bottom: 10),
      blockSpacing: 10.0,
    );
  }
}

/// A slim rule with a centred diamond, used to frame the narration.
/// Replaces the flat gold bar the screen used to draw.
class _Ornament extends StatelessWidget {
  final _ReaderPalette palette;
  final bool flipped;

  const _Ornament({required this.palette, this.flipped = false});

  @override
  Widget build(BuildContext context) {
    final line = palette.control.withValues(alpha: 0.35);
    return SizedBox(
      width: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: flipped
                      ? [line, Colors.transparent]
                      : [Colors.transparent, line],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Transform.rotate(
              angle: 0.785398, // 45°, so the square reads as a diamond
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: flipped
                      ? [Colors.transparent, line]
                      : [line, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
