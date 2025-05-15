import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_tile.dart';

import '../core/strings.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode?)? onThemeChange;
  final ThemeMode? currentTheme;
  const HomeScreen({super.key, this.onThemeChange, this.currentTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
                  PopupMenuButton<ThemeMode>(
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'تغيير الثيم',
                    onSelected: widget.onThemeChange,
                    initialValue: widget.currentTheme,
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: ThemeMode.light,
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
                            value: ThemeMode.dark,
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
                            value: ThemeMode.system,
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
