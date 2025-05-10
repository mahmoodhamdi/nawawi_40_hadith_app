import 'package:flutter/material.dart';

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
    final highlightStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.secondary,
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.15),
      fontWeight: FontWeight.bold,
    );
    final normalStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = theme.textTheme.bodyMedium;
    final subtitleHighlight = subtitleStyle?.copyWith(
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
      fontWeight: FontWeight.bold,
    );

    final preview = hadith.hadith.split('\n').first.trim();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: RichText(
          textAlign: TextAlign.end,
          text: _highlightText(
            'الحديث رقم $index',
            searchQuery,
            normalStyle,
            highlightStyle,
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: _highlightText(
            preview,
            searchQuery,
            subtitleStyle,
            subtitleHighlight,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithDetailsScreen(index: index, hadith: hadith),
            ),
          );
        },
      ),
    );
  }
}
