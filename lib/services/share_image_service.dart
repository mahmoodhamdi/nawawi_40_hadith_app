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

/// Widget that renders a hadith in a shareable card format
class ShareableHadithCard extends StatelessWidget {
  final int index;
  final Hadith hadith;
  final bool includeDescription;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? accentColor;

  const ShareableHadithCard({
    super.key,
    required this.index,
    required this.hadith,
    this.includeDescription = false,
    this.backgroundColor,
    this.textColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative top border
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Hadith number badge
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

          // Hadith text
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

          // Description (if included)
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

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: accent,
                size: 18,
              ),
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

          // Decorative bottom border
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

  String _getHadithText() {
    // Remove the first line if it contains the hadith title
    final lines = hadith.hadith.split('\n');
    if (lines.length > 1) {
      return lines.skip(1).join('\n').trim();
    }
    return hadith.hadith;
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
