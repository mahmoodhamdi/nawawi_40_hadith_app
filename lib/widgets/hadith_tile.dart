import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/l10n/app_localizations.dart';
import '../cubit/language_cubit.dart';
import '../models/hadith.dart';
import '../screens/hadith_details_screen.dart';

class HadithTile extends StatelessWidget {
  final int index;
  final Hadith hadith;
  final String? searchQuery;

  const HadithTile({
    super.key,
    required this.index,
    required this.hadith,
    this.searchQuery,
  });

  TextSpan _highlightText(
    String text,
    String? query,
    TextStyle? style,
    TextStyle? highlightStyle,
  ) {
    if (query == null || query.isEmpty) {
      return TextSpan(text: text, style: style);
    }
    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int indexFound;
    while ((indexFound = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexFound > start) {
        matches.add(
          TextSpan(text: text.substring(start, indexFound), style: style),
        );
      }
      matches.add(
        TextSpan(
          text: text.substring(indexFound, indexFound + query.length),
          style: highlightStyle,
        ),
      );
      start = indexFound + query.length;
    }
    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start), style: style));
    }
    return TextSpan(children: matches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LanguageCubit>().state.language.code;
    final isArabic = l10n.isArabic;
    final hadithText = hadith.getHadith(languageCode);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final highlightStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.secondary,
      backgroundColor: theme.colorScheme.secondary.withAlpha(38),
      fontWeight: FontWeight.bold,
    );
    final normalStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = theme.textTheme.bodyMedium;
    final subtitleHighlight = subtitleStyle?.copyWith(
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.primary.withAlpha(20),
      fontWeight: FontWeight.bold,
    );

    final preview = hadithText.split('\n').first.trim();

    // Arrow icon that flips in RTL
    Widget arrowIcon = Icon(
      Icons.arrow_forward_ios,
      color: theme.colorScheme.primary,
    );
    if (isRtl) {
      arrowIcon = Transform.scale(
        scaleX: -1,
        child: arrowIcon,
      );
    }

    return Semantics(
      label: '${l10n.hadithNumber} $index. $preview',
      hint: isArabic ? 'انقر لعرض تفاصيل الحديث' : 'Tap to view hadith details',
      button: true,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          title: ExcludeSemantics(
            child: RichText(
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: _highlightText(
                preview,
                searchQuery,
                subtitleStyle,
                subtitleHighlight,
              ),
            ),
          ),
          subtitle: ExcludeSemantics(
            child: RichText(
              textAlign: TextAlign.start,
              text: _highlightText(
                _extractHadithMainStatement(hadithText),
                searchQuery,
                normalStyle,
                highlightStyle,
              ),
            ),
          ),
          trailing: ExcludeSemantics(child: arrowIcon),
          onTap: () {
            // Navigate to hadith details and update last read info via cubit
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HadithDetailsScreen(index: index, hadith: hadith),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper to extract main statement from the first quote in the hadith
  String _extractHadithMainStatement(String text) {
    // Try to find the first Arabic quote
    final quoteRegex = RegExp(r'["«"""„‟""❝❞"?","?;"?."»"]');
    final match = quoteRegex.firstMatch(text);
    if (match != null) {
      final start = match.end;
      // Find the closing quote after the opening
      final endMatch = quoteRegex.firstMatch(text.substring(start));
      if (endMatch != null) {
        final end = start + endMatch.start;
        return text.substring(start, end).trim();
      } else {
        // No closing quote, just take 10 words after the quote
        final after = text.substring(start).trim();
        final words = after.split(RegExp(r'\s+')).take(10).join(' ');
        return words;
      }
    } else {
      // No quote found, fallback to first 10 words
      return text.split(RegExp(r'\s+')).take(10).join(' ');
    }
  }
}
