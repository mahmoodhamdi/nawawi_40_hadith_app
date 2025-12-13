import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Creates a customized MarkdownStyleSheet for hadith descriptions
MarkdownStyleSheet getHadithMarkdownStyle(
  BuildContext context, {
  double baseFontSize = 16.0,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return MarkdownStyleSheet(
    // Headers
    h1: TextStyle(
      fontSize: baseFontSize + 8,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
      height: 1.5,
    ),
    h2: TextStyle(
      fontSize: baseFontSize + 4,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
      height: 1.4,
    ),
    h3: TextStyle(
      fontSize: baseFontSize + 2,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.secondary,
      height: 1.3,
    ),

    // Paragraphs
    p: TextStyle(
      fontSize: baseFontSize,
      height: 1.8,
      color: theme.textTheme.bodyLarge?.color,
    ),

    // Strong (bold)
    strong: TextStyle(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    ),

    // Emphasis (italic)
    em: TextStyle(
      fontStyle: FontStyle.italic,
      color: theme.colorScheme.secondary,
    ),

    // Lists
    listBullet: TextStyle(
      fontSize: baseFontSize,
      color: theme.colorScheme.primary,
    ),
    listIndent: 24.0,

    // Blockquote
    blockquote: TextStyle(
      fontSize: baseFontSize,
      fontStyle: FontStyle.italic,
      color: isDark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.6,
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
          width: 4,
        ),
      ),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),

    // Horizontal Rule
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
    ),

    // Code
    code: TextStyle(
      fontSize: baseFontSize - 2,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      color: theme.colorScheme.primary,
      fontFamily: 'monospace',
    ),
    codeblockDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    codeblockPadding: const EdgeInsets.all(12),

    // Links
    a: TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),

    // Spacing
    h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
    h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
    h3Padding: const EdgeInsets.only(top: 12, bottom: 6),
    pPadding: const EdgeInsets.only(bottom: 12),
    blockSpacing: 12.0,
  );
}

/// Creates a MarkdownStyleSheet optimized for RTL Arabic text
MarkdownStyleSheet getArabicMarkdownStyle(
  BuildContext context, {
  double baseFontSize = 18.0,
}) {
  final baseStyle = getHadithMarkdownStyle(context, baseFontSize: baseFontSize);
  final theme = Theme.of(context);

  return baseStyle.copyWith(
    // Slightly larger text for Arabic readability
    p: baseStyle.p?.copyWith(
      fontSize: baseFontSize,
      height: 2.0,
    ),
    h2: baseStyle.h2?.copyWith(
      fontSize: baseFontSize + 6,
    ),
    blockquote: baseStyle.blockquote?.copyWith(
      fontSize: baseFontSize,
      height: 1.8,
    ),
    // RTL blockquote decoration (border on right)
    blockquoteDecoration: BoxDecoration(
      border: Border(
        right: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
          width: 4,
        ),
      ),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
    ),
  );
}
