import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hadith.dart';

/// Service for generating and sharing hadith images
class ShareImageService {
  ShareImageService._();

  /// Captures a widget as an image and shares it
  static Future<void> shareHadithAsImage({
    required GlobalKey repaintKey,
    required int hadithIndex,
    double pixelRatio = 3.0,
  }) async {
    try {
      // Get the RenderRepaintBoundary
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find render boundary');
      }

      // Capture the image
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      final bytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'hadith_${hadithIndex}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share the image
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'الحديث رقم $hadithIndex من الأربعين النووية',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generates image bytes from a widget (for testing or direct use)
  static Future<Uint8List?> captureWidgetAsImage({
    required GlobalKey repaintKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}

/// Visual template choice for [ShareableHadithCard].
///
/// `classic` reproduces the original solid-gradient layout for backwards
/// compatibility. `minimalist` is a cream-background editorial layout
/// optimized for legibility and printing. `ornate` mimics the framed
/// decorative style of traditional Islamic manuscript pages.
enum ShareCardTemplate { classic, minimalist, ornate }

/// Widget that renders a hadith in a shareable card format.
///
/// Pass a different [template] to switch the visual style without
/// changing the call-site fields — colors are reinterpreted per template
/// (the `minimalist` template, for example, ignores the saturated
/// `backgroundColor` and uses cream + accent only).
class ShareableHadithCard extends StatelessWidget {
  final int index;
  final Hadith hadith;
  final bool includeDescription;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? accentColor;
  final ShareCardTemplate template;

  const ShareableHadithCard({
    super.key,
    required this.index,
    required this.hadith,
    this.includeDescription = false,
    this.backgroundColor,
    this.textColor,
    this.accentColor,
    this.template = ShareCardTemplate.classic,
  });

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ShareCardTemplate.classic:
        return _buildClassic();
      case ShareCardTemplate.minimalist:
        return _buildMinimalist();
      case ShareCardTemplate.ornate:
        return _buildOrnate();
    }
  }

  // ─── Classic — original solid-gradient design ─────────────────────

  Widget _buildClassic() {
    final bgColor = backgroundColor ?? const Color(0xFF1A5F4A);
    final txtColor = textColor ?? Colors.white;
    final accent = accentColor ?? const Color(0xFFD4AF37);

    return Container(
      width: 600,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor, bgColor.withValues(alpha: 0.9)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'الحديث رقم $index',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: bgColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getHadithText(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                height: 1.8,
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          if (includeDescription && hadith.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'الشرح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hadith.description,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      height: 1.6,
                      color: txtColor.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'الأربعون النووية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: txtColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Minimalist — editorial layout, generous whitespace ───────────

  Widget _buildMinimalist() {
    const bg = Color(0xFFFAFAF5); // cream
    const dark = Color(0xFF1A1A1A);
    final accent = accentColor ?? const Color(0xFF1F6E3A);
    final hadithCitation = hadith.citation;

    return Container(
      width: 600,
      padding: const EdgeInsets.fromLTRB(48, 56, 48, 56),
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiny number tag (no badge fill)
          Text(
            '$index / 42',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Thin separator
          Container(width: 40, height: 1, color: accent.withValues(alpha: 0.5)),
          const SizedBox(height: 32),
          Text(
            _getHadithText(),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              height: 1.85,
              color: dark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          if (hadithCitation != null) ...[
            const SizedBox(height: 28),
            Text(
              'رواه ${hadithCitation.collectionAr}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: dark.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
          const SizedBox(height: 40),
          Container(width: 40, height: 1, color: accent.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'الأربعون النووية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              letterSpacing: 1.5,
              color: dark.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Ornate — Quranic manuscript-inspired frame ───────────────────

  Widget _buildOrnate() {
    const bg = Color(0xFFF4ECD8); // sepia parchment
    const dark = Color(0xFF3A2A1E);
    final accent = accentColor ?? const Color(0xFFC9A961);

    return Container(
      width: 600,
      decoration: const BoxDecoration(color: bg),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: accent, width: 3),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.6), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OrnamentBar(color: accent),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accent, width: 1),
                ),
                child: Text(
                  'الحديث رقم $index',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: dark.withValues(alpha: 0.85),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 24),
              if (hadith.titleAr.isNotEmpty) ...[
                Text(
                  hadith.titleAr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E2C),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                _getHadithText(),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 21,
                  height: 1.85,
                  color: dark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              if (hadith.citation != null) ...[
                const SizedBox(height: 20),
                Text(
                  'رواه ${hadith.citation!.collectionAr}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: dark.withValues(alpha: 0.6),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
              const SizedBox(height: 22),
              _OrnamentBar(color: accent),
              const SizedBox(height: 18),
              Text(
                'الأربعون النووية · صدقة جارية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: dark.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHadithText() {
    final lines = hadith.hadith.split('\n');
    if (lines.length > 1) {
      return lines.skip(1).join('\n').trim();
    }
    return hadith.hadith;
  }
}

/// Repeating diamond ornament used in the [ShareCardTemplate.ornate]
/// layout to evoke the side margins of traditional Islamic manuscripts.
class _OrnamentBar extends StatelessWidget {
  final Color color;
  const _OrnamentBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 80, height: 1, color: color),
        const SizedBox(width: 6),
        Transform.rotate(
          angle: 0.7854, // 45deg
          child: Container(width: 8, height: 8, color: color),
        ),
        const SizedBox(width: 6),
        Container(width: 30, height: 1, color: color),
        const SizedBox(width: 6),
        Transform.rotate(
          angle: 0.7854,
          child: Container(width: 8, height: 8, color: color),
        ),
        const SizedBox(width: 6),
        Container(width: 80, height: 1, color: color),
      ],
    );
  }
}

/// Available color themes for sharing
enum ShareImageTheme {
  green,
  blue,
  purple,
  gold,
  dark,
}

/// Extension to get theme colors
extension ShareImageThemeColors on ShareImageTheme {
  Color get backgroundColor {
    switch (this) {
      case ShareImageTheme.green:
        return const Color(0xFF1A5F4A);
      case ShareImageTheme.blue:
        return const Color(0xFF1A4F7A);
      case ShareImageTheme.purple:
        return const Color(0xFF4A1A5F);
      case ShareImageTheme.gold:
        return const Color(0xFF5F4A1A);
      case ShareImageTheme.dark:
        return const Color(0xFF1A1A2E);
    }
  }

  Color get accentColor {
    switch (this) {
      case ShareImageTheme.green:
        return const Color(0xFFD4AF37);
      case ShareImageTheme.blue:
        return const Color(0xFF87CEEB);
      case ShareImageTheme.purple:
        return const Color(0xFFDDA0DD);
      case ShareImageTheme.gold:
        return const Color(0xFFFFD700);
      case ShareImageTheme.dark:
        return const Color(0xFFE94560);
    }
  }

  String get nameArabic {
    switch (this) {
      case ShareImageTheme.green:
        return 'أخضر';
      case ShareImageTheme.blue:
        return 'أزرق';
      case ShareImageTheme.purple:
        return 'بنفسجي';
      case ShareImageTheme.gold:
        return 'ذهبي';
      case ShareImageTheme.dark:
        return 'داكن';
    }
  }
}
