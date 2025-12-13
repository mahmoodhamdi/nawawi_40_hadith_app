import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_tile.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../cubit/language_cubit.dart';
import '../cubit/last_read_cubit.dart';
import '../cubit/last_read_state.dart';
import '../cubit/reading_stats_cubit.dart';
import '../cubit/reading_stats_state.dart';
import '../cubit/theme_cubit.dart';
import '../models/hadith.dart';
import '../screens/hadith_details_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  // Debounce timer for search optimization
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  // Navigate to the last read hadith
  void _navigateToLastReadHadith(
    BuildContext context,
    List<Hadith> hadiths,
    int lastReadIndex,
  ) {
    if (lastReadIndex <= 0 || lastReadIndex > hadiths.length) return;

    final hadith = hadiths[lastReadIndex - 1]; // Adjust for 0-based index
    final lastReadCubit = context.read<LastReadCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HadithDetailsScreen(index: lastReadIndex, hadith: hadith),
      ),
    ).then((_) {
      // Refresh the LastReadCubit when returning from HadithDetailsScreen
      if (mounted) {
        lastReadCubit.loadLastReadInfo();
      }
    });
  }

  // Build the continue reading card
  Widget _buildContinueReadingCard(
    BuildContext context,
    int? lastReadIndex,
    DateTime? lastReadTime,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Format the last read time
    String timeAgo = '';
    if (lastReadTime != null) {
      final difference = DateTime.now().difference(lastReadTime);
      if (difference.inMinutes < 1) {
        timeAgo = l10n.justNow;
      } else if (difference.inMinutes < 60) {
        timeAgo = l10n.minutesAgo(difference.inMinutes);
      } else if (difference.inHours < 24) {
        timeAgo = l10n.hoursAgo(difference.inHours);
      } else {
        timeAgo = l10n.daysAgo(difference.inDays);
      }
    }

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        if (state is HadithLoaded && lastReadIndex != null) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                        ]
                      : [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _navigateToLastReadHadith(
                      context,
                      state.hadiths,
                      lastReadIndex,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.continueReading),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? theme.colorScheme.surface
                          : Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.lastRead,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${l10n.hadithNumber} $lastReadIndex',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : Colors.white,
                        ),
                      ),
                      if (lastReadTime != null)
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Build the reading stats card
  Widget _buildReadingStatsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ReadingStatsCubit, ReadingStatsState>(
      builder: (context, statsState) {
        if (statsState.isLoading) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<HadithCubit, HadithState>(
          builder: (context, hadithState) {
            // Update total hadith count when loaded
            if (hadithState is HadithLoaded) {
              final totalCount = hadithState.hadiths.length;
              if (statsState.totalHadiths != totalCount) {
                context.read<ReadingStatsCubit>().setTotalHadiths(totalCount);
              }
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          statsState.isComplete
                              ? Icons.emoji_events
                              : Icons.menu_book,
                          color: statsState.isComplete
                              ? Colors.amber
                              : theme.colorScheme.primary,
                          size: 28,
                        ),
                        Text(
                          l10n.readingProgress,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          '${statsState.readCount}',
                          l10n.hadithsRead,
                          Icons.check_circle,
                          Colors.green,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildStatItem(
                          context,
                          '${statsState.remainingCount}',
                          l10n.remaining,
                          Icons.schedule,
                          Colors.orange,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildStatItem(
                          context,
                          '${statsState.progressPercent}%',
                          l10n.completed,
                          Icons.pie_chart,
                          theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: statsState.progressPercentage,
                        backgroundColor: isDark
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          statsState.isComplete
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    if (statsState.isComplete) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.isArabic
                            ? 'مبارك! لقد أتممت قراءة جميع الأحاديث'
                            : 'Congratulations! You have read all hadiths',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for stat items
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Ensure LastReadCubit is loaded when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LastReadCubit>().loadLastReadInfo();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Handles search input with debouncing for better performance
  void _onSearchChanged(String value) {
    // Cancel previous timer if still active
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim();
        });
      }
    });
  }

  /// Normalizes Arabic text for better search matching
  ///
  /// Removes diacritics (tashkeel) and normalizes common character variations
  String _normalizeArabicText(String text) {
    // Remove Arabic diacritics (tashkeel)
    final diacritics = RegExp(
      '[\u064B-\u065F\u0670\u06D6-\u06ED]',
    );

    // Normalize alef variations
    String normalized = text
        .replaceAll(diacritics, '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    return normalized;
  }

  /// Checks if hadith matches the search query
  bool _hadithMatchesQuery(Hadith hadith, String query) {
    if (query.isEmpty) return true;

    final normalizedQuery = _normalizeArabicText(query);
    final normalizedHadith = _normalizeArabicText(hadith.hadith);
    final normalizedDescription = _normalizeArabicText(hadith.description);

    return normalizedHadith.contains(normalizedQuery) ||
        normalizedDescription.contains(normalizedQuery);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final languageState = context.watch<LanguageCubit>().state;
    final welcomeColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;
    final searchIconColor = theme.colorScheme.secondary;
    final searchFillColor = theme.cardColor;
    final borderColor = isDark
        ? theme.dividerColor
        : theme.colorScheme.secondary.withValues(alpha: 0.2);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HadithCubit()..fetchHadiths()),
        // Use the existing LastReadCubit instance from the parent context
        BlocProvider.value(value: BlocProvider.of<LastReadCubit>(context)),
      ],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(l10n.appTitle),
              centerTitle: true,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: l10n.settings,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                PopupMenuButton<AppThemeType>(
                  icon: const Icon(Icons.color_lens),
                  tooltip: l10n.theme,
                  onSelected: (themeType) {
                    context.read<ThemeCubit>().changeTheme(themeType);
                  },
                  initialValue: context.read<ThemeCubit>().state.themeType,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: AppThemeType.light,
                      child: Row(
                        children: [
                          Icon(Icons.light_mode, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          Text(l10n.lightTheme),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppThemeType.dark,
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode, color: Colors.blueGrey[700]),
                          const SizedBox(width: 8),
                          Text(l10n.darkTheme),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppThemeType.blue,
                      child: Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(l10n.blueTheme),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppThemeType.purple,
                      child: Row(
                        children: [
                          Icon(Icons.palette, color: Colors.purple[700]),
                          const SizedBox(width: 8),
                          Text(l10n.purpleTheme),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppThemeType.system,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.brightness_auto,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.systemTheme),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      l10n.welcome,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: welcomeColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: languageState.isArabic ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(30),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: searchIconColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: searchFillColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: searchIconColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, favoritesState) {
                            return Semantics(
                              label: _showFavoritesOnly
                                  ? l10n.allHadiths
                                  : '${l10n.favorites} (${favoritesState.count})',
                              button: true,
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(30),
                                color: _showFavoritesOnly
                                    ? theme.colorScheme.primary
                                    : searchFillColor,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    setState(() {
                                      _showFavoritesOnly = !_showFavoritesOnly;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _showFavoritesOnly
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: _showFavoritesOnly
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        if (favoritesState.count > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '${favoritesState.count}',
                                            style: TextStyle(
                                              color: _showFavoritesOnly
                                                  ? Colors.white
                                                  : theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<LastReadCubit, LastReadState>(
                      builder: (context, lastReadState) {
                        if (lastReadState.hadithIndex != null) {
                          return _buildContinueReadingCard(
                            context,
                            lastReadState.hadithIndex,
                            lastReadState.lastReadTime,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildReadingStatsCard(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            BlocBuilder<HadithCubit, HadithState>(
              builder: (context, hadithState) {
                if (hadithState is HadithLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (hadithState is HadithLoaded) {
                  return BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favoritesState) {
                      // Apply search filter
                      var filtered = _searchQuery.isEmpty
                          ? hadithState.hadiths
                          : hadithState.hadiths
                              .where((h) => _hadithMatchesQuery(h, _searchQuery))
                              .toList();

                      // Apply favorites filter if enabled
                      if (_showFavoritesOnly) {
                        filtered = filtered.where((hadith) {
                          final originalIndex =
                              hadithState.hadiths.indexOf(hadith) + 1;
                          return favoritesState.isFavorite(originalIndex);
                        }).toList();
                      }

                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showFavoritesOnly
                                      ? Icons.favorite_border
                                      : Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _showFavoritesOnly
                                      ? l10n.noFavorites
                                      : l10n.noResults,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (_showFavoritesOnly) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.isArabic
                                        ? 'اضغط على القلب في صفحة الحديث لإضافته للمفضلة'
                                        : 'Tap the heart icon on the hadith page to add to favorites',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final hadith = filtered[index];
                          final originalIndex =
                              hadithState.hadiths.indexOf(hadith) + 1;
                          return HadithTile(
                            index: originalIndex,
                            hadith: hadith,
                            searchQuery: _searchQuery,
                          );
                        }, childCount: filtered.length),
                      );
                    },
                  );
                } else if (hadithState is HadithError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(hadithState.message, textAlign: TextAlign.center),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ],
        ),
      ),
    );
  }
}
