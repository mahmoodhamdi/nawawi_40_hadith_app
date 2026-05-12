import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/l10n/app_localizations.dart';
import '../cubit/language_cubit.dart';
import '../models/hadith.dart';

/// Displays the source citation for a single hadith (narrator, primary
/// collection, canonical sunnah.com URL). Tapping the URL row copies it to
/// the clipboard — no `url_launcher` dependency is required, preserving the
/// app's strict offline-first guarantee.
class HadithCitationCard extends StatelessWidget {
  final HadithCitation citation;

  const HadithCitationCard({super.key, required this.citation});

  Future<void> _copyUrl(BuildContext context) async {
    final l10n = AppLocalizations.read(context);
    await Clipboard.setData(ClipboardData(text: citation.sunnahUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            l10n.isArabic ? 'تم نسخ الرابط' : 'Link copied',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LanguageCubit>().state.language.code;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;

    return Semantics(
      label: l10n.citation,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    l10n.citation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CitationRow(
                label: l10n.narrator,
                value: citation.getNarrator(languageCode),
                color: onSurface,
              ),
              const SizedBox(height: 8),
              _CitationRow(
                label: l10n.source,
                value: citation.getCollection(languageCode),
                color: onSurface,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _copyUrl(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          citation.sunnahUrl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accent,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.copy_rounded, size: 14, color: accent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CitationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CitationRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.withAlpha(160),
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
