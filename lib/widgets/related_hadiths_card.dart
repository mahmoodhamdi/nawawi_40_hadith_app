import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/l10n/app_localizations.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../models/hadith.dart';
import '../screens/hadith_details_screen.dart';

/// "Related hadiths" card. Computes related entries by intersecting
/// [topicIds] with the current hadith — any other hadith sharing at
/// least one topic is shown. Capped at 5 to keep the UI light.
///
/// If the current hadith has no topic tags (e.g. an old build without
/// the migration), the card hides itself silently.
class RelatedHadithsCard extends StatelessWidget {
  final Hadith current;
  final int currentIndex;

  const RelatedHadithsCard({
    super.key,
    required this.current,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (current.topicIds.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        if (state is! HadithLoaded) return const SizedBox.shrink();

        final currentTopics = current.topicIds.toSet();
        final related = <_RelatedEntry>[];
        for (var i = 0; i < state.hadiths.length; i++) {
          final h = state.hadiths[i];
          if (i + 1 == currentIndex) continue; // skip self
          final overlap = h.topicIds.toSet().intersection(currentTopics);
          if (overlap.isEmpty) continue;
          related.add(_RelatedEntry(index: i + 1, hadith: h, overlap: overlap.length));
        }

        // Sort by overlap count desc, then ascending index for stability.
        related.sort((a, b) {
          final c = b.overlap.compareTo(a.overlap);
          return c != 0 ? c : a.index.compareTo(b.index);
        });
        final top = related.take(5).toList();
        if (top.isEmpty) return const SizedBox.shrink();

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.link_rounded,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.relatedHadiths,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Topic chips for current hadith (language-aware)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final label in current.topicLabelsFor(
                        l10n.isArabic ? 'ar' : 'en'))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final entry in top) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HadithDetailsScreen(
                          index: entry.index,
                          hadith: entry.hadith,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${entry.index}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.hadith.getTitle(l10n.isArabic ? 'ar' : 'en'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RelatedEntry {
  final int index;
  final Hadith hadith;
  final int overlap;
  _RelatedEntry({
    required this.index,
    required this.hadith,
    required this.overlap,
  });
}
