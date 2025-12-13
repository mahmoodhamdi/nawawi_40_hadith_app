import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/markdown_style.dart';
import '../cubit/audio_player_cubit.dart';
import '../cubit/language_cubit.dart';
import '../screens/focused_reading_screen.dart';
import '../services/share_image_service.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../cubit/font_size_cubit.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../cubit/last_read_cubit.dart';
import '../cubit/reading_stats_cubit.dart';
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

  // Save the current hadith as last read and mark as read
  void _saveLastReadHadith() {
    context.read<LastReadCubit>().updateLastReadHadith(widget.index);
    // Mark this hadith as read for statistics
    context.read<ReadingStatsCubit>().markAsRead(widget.index);
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize Cubits
    _initializeCubits();
    
    // Update last read information when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveLastReadHadith();
    });
  }
  
  void _initializeCubits() {
    // Initialize FontSizeCubit by loading saved preferences
    context.read<FontSizeCubit>().loadFontSizePreferences();
    
    // Initialize AudioPlayerCubit by loading the current hadith's audio
    context.read<AudioPlayerCubit>().loadAudio(widget.index);
  }



  @override
  void dispose() {
    // Cleanup is handled by the Cubits
    super.dispose();
  }



  String _getCurrentLanguageCode() {
    return context.read<LanguageCubit>().state.language.code;
  }

  void _shareHadithOnly() {
    final languageCode = _getCurrentLanguageCode();
    SharePlus.instance.share(ShareParams(text: widget.hadith.getHadith(languageCode)));
  }

  void _shareDescriptionOnly() {
    final languageCode = _getCurrentLanguageCode();
    SharePlus.instance.share(ShareParams(text: widget.hadith.getDescription(languageCode)));
  }

  void _shareBoth() {
    final languageCode = _getCurrentLanguageCode();
    final hadithText = widget.hadith.getHadith(languageCode);
    final descriptionText = widget.hadith.getDescription(languageCode);
    SharePlus.instance.share(ShareParams(text: '$hadithText\n\n$descriptionText'));
  }

  // Font size adjustment methods - now uses FontSizeCubit
  void _increaseHadithFontSize() {
    context.read<FontSizeCubit>().increaseHadithFontSize();
  }

  void _decreaseHadithFontSize() {
    context.read<FontSizeCubit>().decreaseHadithFontSize();
  }

  void _increaseDescriptionFontSize() {
    context.read<FontSizeCubit>().increaseDescriptionFontSize();
  }

  void _decreaseDescriptionFontSize() {
    context.read<FontSizeCubit>().decreaseDescriptionFontSize();
  }

  void _enterFocusedReadingMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusedReadingScreen(
          initialIndex: widget.index,
          initialHadith: widget.hadith,
        ),
      ),
    );
  }

  void _showShareOptions() {
    final l10n = AppLocalizations.read(context);
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
              title: Text(l10n.shareHadithOnly),
              onTap: () {
                Navigator.pop(context);
                _shareHadithOnly();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(l10n.shareDescriptionOnly),
              onTap: () {
                Navigator.pop(context);
                _shareDescriptionOnly();
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: Text(l10n.shareBoth),
              onTap: () {
                Navigator.pop(context);
                _shareBoth();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(l10n.shareAsImage),
              subtitle: Text(l10n.isArabic ? 'صورة جميلة للحديث' : 'Beautiful hadith image'),
              onTap: () {
                Navigator.pop(context);
                _showShareAsImageDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareAsImageDialog() {
    ShareImageTheme selectedTheme = ShareImageTheme.green;
    bool includeDescription = false;
    final repaintKey = GlobalKey();
    final l10n = AppLocalizations.read(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          l10n.shareAsImage,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Preview
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Image preview
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RepaintBoundary(
                              key: repaintKey,
                              child: ShareableHadithCard(
                                index: widget.index,
                                hadith: widget.hadith,
                                includeDescription: includeDescription,
                                backgroundColor: selectedTheme.backgroundColor,
                                accentColor: selectedTheme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Theme selection
                          Text(
                            l10n.selectTheme,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ShareImageTheme.values.map((theme) {
                              final isSelected = theme == selectedTheme;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedTheme = theme;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.accentColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: theme.accentColor,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Include description toggle
                          SwitchListTile(
                            title: Text(l10n.isArabic ? 'تضمين الشرح' : 'Include explanation'),
                            subtitle: Text(l10n.isArabic ? 'إضافة شرح الحديث للصورة' : 'Add hadith explanation to image'),
                            value: includeDescription,
                            onChanged: (value) {
                              setDialogState(() {
                                includeDescription = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Share button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // Wait for widget to render
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );

                            // Share the image
                            await ShareImageService.shareHadithAsImage(
                              repaintKey: repaintKey,
                              hadithIndex: widget.index,
                            );

                            // Close loading and dialog
                            if (context.mounted) {
                              Navigator.pop(context); // Loading
                              Navigator.pop(context); // Dialog
                            }
                          } catch (e) {
                            // Close loading
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            // Show error
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.isArabic
                                      ? 'حدث خطأ أثناء إنشاء الصورة'
                                      : 'Error creating image'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: Text(l10n.share),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LanguageCubit>().state.language.code;
    final hadithText = widget.hadith.getHadith(languageCode);
    final descriptionText = widget.hadith.getDescription(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hadithTitle(widget.index)),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoritesState) {
              final isFavorite = favoritesState.isFavorite(widget.index);
              return Semantics(
                label: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                button: true,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<FavoritesCubit>().toggleFavorite(widget.index);
                  },
                  tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _enterFocusedReadingMode,
            tooltip: l10n.focusedReading,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
            tooltip: l10n.share,
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
                                l10n.isArabic ? 'الحديث:' : 'Hadith:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.text_increase),
                                    onPressed: _increaseHadithFontSize,
                                    tooltip: l10n.hadithFontSize,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease),
                                    onPressed: _decreaseHadithFontSize,
                                    tooltip: l10n.hadithFontSize,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Hadith Text with BlocBuilder for Font Size
                          BlocBuilder<FontSizeCubit, FontSizeState>(
                            builder: (context, fontState) {
                              // Get the hadith text without the first line (title)
                              final lines = hadithText.split('\n');
                              final displayText = lines.length > 1
                                  ? lines.skip(1).join('\n').trim()
                                  : hadithText;
                              return SelectableText(
                                displayText,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontState.hadithFontSize,
                                    ),
                                textAlign: TextAlign.start,
                                contextMenuBuilder: (context, editableTextState) {
                                  return AdaptiveTextSelectionToolbar.editableText(
                                    editableTextState: editableTextState,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Audio Player Widget
                          BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                            builder: (context, audioState) {
                              return audioState.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : AudioPlayerWidget(
                                    // We don't pass the player directly anymore
                                    player: null, // Not used with Cubit
                                    isPlaying: audioState.isPlaying,
                                    duration: audioState.duration,
                                    position: audioState.position,
                                    isLoading: audioState.isLoading,
                                    onPlayPause: () => context.read<AudioPlayerCubit>().togglePlayPause(),
                                    onReplay: () => context.read<AudioPlayerCubit>().replay(),
                                    onSkipForward: () => context.read<AudioPlayerCubit>().skipForward(),
                                    onSkipBackward: () => context.read<AudioPlayerCubit>().skipBackward(),
                                    onSeek: (pos) => context.read<AudioPlayerCubit>().seekTo(pos),
                                    onSpeedChanged: (speed) => context.read<AudioPlayerCubit>().changePlaybackSpeed(speed),
                                    playbackSpeed: audioState.playbackSpeed,
                                  );
                            },
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
                                l10n.explanation,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.text_increase),
                                    onPressed: _increaseDescriptionFontSize,
                                    tooltip: l10n.descriptionFontSize,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease),
                                    onPressed: _decreaseDescriptionFontSize,
                                    tooltip: l10n.descriptionFontSize,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Description text with markdown rendering
                          BlocBuilder<FontSizeCubit, FontSizeState>(
                            builder: (context, fontState) {
                              final isArabic = l10n.isArabic;
                              final markdownStyle = isArabic
                                  ? getArabicMarkdownStyle(
                                      context,
                                      baseFontSize: fontState.descriptionFontSize,
                                    )
                                  : getHadithMarkdownStyle(
                                      context,
                                      baseFontSize: fontState.descriptionFontSize,
                                    );

                              return MarkdownBody(
                                data: descriptionText,
                                styleSheet: markdownStyle,
                                selectable: true,
                                softLineBreak: true,
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
                  child: BlocBuilder<HadithCubit, HadithState>(
                    builder: (context, hadithState) {
                      // Get total hadith count dynamically
                      final totalHadiths = hadithState is HadithLoaded
                          ? hadithState.hadiths.length
                          : 0;

                      // Check if RTL for proper button order
                      final isRtl = Directionality.of(context) == TextDirection.rtl;

                      final previousButton = _buildNavigationButton(
                        context: context,
                        icon: Icons.arrow_back_ios_rounded,
                        label: l10n.previousHadith,
                        onPressed: widget.index > 1
                            ? () => _navigateToPreviousHadith(context)
                            : null,
                      );

                      final nextButton = _buildNavigationButton(
                        context: context,
                        icon: Icons.arrow_forward_ios_rounded,
                        label: l10n.nextHadith,
                        onPressed: widget.index < totalHadiths
                            ? () => _navigateToNextHadith(context)
                            : null,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 30.0, left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: isRtl
                              ? [nextButton, previousButton]  // RTL: Next on left, Previous on right
                              : [previousButton, nextButton], // LTR: Previous on left, Next on right
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigate to next hadith
  void _navigateToNextHadith(BuildContext context) async {
    final audioCubit = context.read<AudioPlayerCubit>();
    final hadithCubit = context.read<HadithCubit>();
    final navigator = Navigator.of(context);

    // Pause audio if playing
    await audioCubit.pause();

    // Get the current hadith state
    final hadithState = hadithCubit.state;

    // If hadiths aren't loaded yet, load them first
    if (hadithState is! HadithLoaded) {
      await hadithCubit.fetchHadiths();
    }

    // Check again after potential loading
    final currentState = hadithCubit.state;

    if (currentState is HadithLoaded && mounted) {
      final hadiths = currentState.hadiths;
      final nextIndex = widget.index + 1;

      if (nextIndex <= hadiths.length) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => HadithDetailsScreen(
              index: nextIndex,
              hadith: hadiths[nextIndex - 1], // Adjust for 0-based index
            ),
          ),
        );
      }
    }
  }

  // Navigate to previous hadith
  void _navigateToPreviousHadith(BuildContext context) async {
    final audioCubit = context.read<AudioPlayerCubit>();
    final hadithCubit = context.read<HadithCubit>();
    final navigator = Navigator.of(context);

    // Pause audio if playing
    await audioCubit.pause();

    // Get the current hadith state
    final hadithState = hadithCubit.state;

    // If hadiths aren't loaded yet, load them first
    if (hadithState is! HadithLoaded) {
      await hadithCubit.fetchHadiths();
    }

    // Check again after potential loading
    final currentState = hadithCubit.state;

    if (currentState is HadithLoaded && mounted) {
      final hadiths = currentState.hadiths;
      final prevIndex = widget.index - 1;

      if (prevIndex > 0) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => HadithDetailsScreen(
              index: prevIndex,
              hadith: hadiths[prevIndex - 1], // Adjust for 0-based index
            ),
          ),
        );
      }
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
    final l10n = AppLocalizations.read(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Mirror the icon in RTL mode
    Widget iconWidget = Icon(icon, size: 18);
    if (isRtl) {
      iconWidget = Transform.scale(
        scaleX: -1,
        child: iconWidget,
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Semantics(
          label: label,
          hint: isDisabled
              ? (l10n.isArabic ? 'غير متاح' : 'Not available')
              : (l10n.isArabic ? 'انقر للانتقال' : 'Tap to navigate'),
          enabled: !isDisabled,
          button: true,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? theme.disabledColor.withValues(alpha: 0.1)
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
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
