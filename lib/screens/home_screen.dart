import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_tile.dart';

import '../core/strings.dart';
import '../core/theme/app_theme.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../models/hadith.dart';
import '../screens/hadith_details_screen.dart';
import '../services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  final void Function(AppThemeType)? onThemeChange;
  final AppThemeType? currentThemeType;
  const HomeScreen({super.key, this.onThemeChange, this.currentThemeType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _lastReadHadithIndex;
  DateTime? _lastReadTime;

  @override
  void initState() {
    super.initState();
    _loadLastReadInfo();
  }

  Future<void> _loadLastReadInfo() async {
    final lastIndex = await PreferencesService.getLastReadHadith();
    final lastTime = await PreferencesService.getLastReadTime();
    if (mounted) {
      setState(() {
        _lastReadHadithIndex = lastIndex;
        _lastReadTime = lastTime;
      });
    }
  }

  // Navigate to the last read hadith
  void _navigateToLastReadHadith(BuildContext context, List<Hadith> hadiths) {
    if (_lastReadHadithIndex == null ||
        _lastReadHadithIndex! <= 0 ||
        _lastReadHadithIndex! > hadiths.length)
      return;

    final hadith =
        hadiths[_lastReadHadithIndex! - 1]; // Adjust for 0-based index
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HadithDetailsScreen(
              index: _lastReadHadithIndex!,
              hadith: hadith,
            ),
      ),
    ).then((_) => _loadLastReadInfo()); // Refresh after returning
  }

  // Build the continue reading card
  Widget _buildContinueReadingCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Format the last read time
    String timeAgo = '';
    if (_lastReadTime != null) {
      final difference = DateTime.now().difference(_lastReadTime!);
      if (difference.inMinutes < 60) {
        timeAgo = AppStrings.minutesAgo.replaceAll(
          '{minutes}',
          '${difference.inMinutes}',
        );
      } else if (difference.inHours < 24) {
        timeAgo = AppStrings.hoursAgo.replaceAll(
          '{hours}',
          '${difference.inHours}',
        );
      } else {
        timeAgo = AppStrings.daysAgo.replaceAll(
          '{days}',
          '${difference.inDays}',
        );
      }
    }

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        if (state is HadithLoaded && _lastReadHadithIndex != null) {
          // Calculate progress percentage
          final progress = _lastReadHadithIndex! / state.hadiths.length;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            theme.colorScheme.primary.withOpacity(0.7),
                            theme.colorScheme.primary.withOpacity(0.3),
                          ]
                          : [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            () => _navigateToLastReadHadith(
                              context,
                              state.hadiths,
                            ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(AppStrings.continueReading),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? theme.colorScheme.surface : Colors.white,
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
                            AppStrings.lastRead,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${AppStrings.hadithNumber} $_lastReadHadithIndex',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.white,
                            ),
                          ),
                          if (_lastReadTime != null)
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
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white24 : Colors.white38,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : Colors.white,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_lastReadHadithIndex! * 100 ~/ state.hadiths.length)}% ${AppStrings.completed}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.white,
                    ),
                    textAlign: TextAlign.left,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final welcomeColor =
        isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary;
    final searchIconColor = theme.colorScheme.secondary;
    final searchFillColor = theme.cardColor;
    final borderColor =
        isDark
            ? theme.dividerColor
            : theme.colorScheme.secondary.withValues(alpha: 0.2);
    return BlocProvider(
      create: (_) => HadithCubit()..fetchHadiths(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text(
                  AppStrings.appTitle,
                  textAlign: TextAlign.right,
                ),
                centerTitle: true,
                floating: true,
                snap: true,
                actions: [
                  PopupMenuButton<AppThemeType>(
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'تغيير الثيم',
                    onSelected: widget.onThemeChange,
                    initialValue: widget.currentThemeType,
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: AppThemeType.light,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.light_mode,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ثيم فاتح',
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: AppThemeType.dark,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.dark_mode,
                                  color: Colors.blueGrey[700],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ثيم داكن',
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: AppThemeType.blue,
                            child: Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'ثيم أزرق',
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: AppThemeType.purple,
                            child: Row(
                              children: [
                                Icon(Icons.palette, color: Colors.purple[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'ثيم بنفسجي',
                                  textAlign: TextAlign.right,
                                ),
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
                                const Text(
                                  'حسب النظام',
                                  textAlign: TextAlign.right,
                                ),
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
                        AppStrings.welcome,

                        style: theme.textTheme.titleLarge?.copyWith(
                          color: welcomeColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(30),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: AppStrings.searchHint,
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
                            suffixIcon:
                                _searchQuery.isNotEmpty
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
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim();
                            });
                          },
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_lastReadHadithIndex != null)
                        _buildContinueReadingCard(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              BlocBuilder<HadithCubit, HadithState>(
                builder: (context, state) {
                  if (state is HadithLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is HadithLoaded) {
                    final filtered =
                        _searchQuery.isEmpty
                            ? state.hadiths
                            : state.hadiths
                                .where(
                                  (h) =>
                                      h.hadith.contains(_searchQuery) ||
                                      h.description.contains(_searchQuery),
                                )
                                .toList();

                    // Store hadiths for continue reading functionality
                    // We don't want to automatically navigate, just make the button available
                    if (filtered.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            AppStrings.noResults,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final hadith = filtered[index];
                        final originalIndex = state.hadiths.indexOf(hadith) + 1;
                        return HadithTile(
                          index: originalIndex,
                          hadith: hadith,
                          searchQuery: _searchQuery,
                        );
                      }, childCount: filtered.length),
                    );
                  } else if (state is HadithError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(state.message, textAlign: TextAlign.right),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
