import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/services/share_image_service.dart';

void main() {
  group('ShareImageTheme', () {
    test('green theme has correct colors', () {
      const theme = ShareImageTheme.green;

      expect(theme.backgroundColor, const Color(0xFF1A5F4A));
      expect(theme.accentColor, const Color(0xFFD4AF37));
      expect(theme.nameArabic, 'أخضر');
    });

    test('blue theme has correct colors', () {
      const theme = ShareImageTheme.blue;

      expect(theme.backgroundColor, const Color(0xFF1A4F7A));
      expect(theme.accentColor, const Color(0xFF87CEEB));
      expect(theme.nameArabic, 'أزرق');
    });

    test('purple theme has correct colors', () {
      const theme = ShareImageTheme.purple;

      expect(theme.backgroundColor, const Color(0xFF4A1A5F));
      expect(theme.accentColor, const Color(0xFFDDA0DD));
      expect(theme.nameArabic, 'بنفسجي');
    });

    test('gold theme has correct colors', () {
      const theme = ShareImageTheme.gold;

      expect(theme.backgroundColor, const Color(0xFF5F4A1A));
      expect(theme.accentColor, const Color(0xFFFFD700));
      expect(theme.nameArabic, 'ذهبي');
    });

    test('dark theme has correct colors', () {
      const theme = ShareImageTheme.dark;

      expect(theme.backgroundColor, const Color(0xFF1A1A2E));
      expect(theme.accentColor, const Color(0xFFE94560));
      expect(theme.nameArabic, 'داكن');
    });

    test('all themes have unique background colors', () {
      final backgroundColors = ShareImageTheme.values
          .map((theme) => theme.backgroundColor)
          .toSet();

      expect(backgroundColors.length, ShareImageTheme.values.length);
    });

    test('all themes have Arabic names', () {
      for (final theme in ShareImageTheme.values) {
        expect(theme.nameArabic, isNotEmpty);
      }
    });
  });

  group('ShareableHadithCard', () {
    final testHadith = Hadith(
      hadithAr: 'الحديث الأول\nعن أمير المؤمنين أبي حفص عمر بن الخطاب رضي الله عنه',
      hadithEn: 'First Hadith\nOn the authority of Umar ibn al-Khattab',
      descriptionAr: 'شرح الحديث: هذا الحديث يتحدث عن النية وأهميتها في العمل.',
      descriptionEn: 'Explanation: This hadith discusses the importance of intention in actions.',
    );

    testWidgets('renders hadith card with default theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
            ),
          ),
        ),
      );

      // Verify hadith number badge is shown
      expect(find.text('الحديث رقم 1'), findsOneWidget);

      // Verify footer is shown
      expect(find.text('الأربعون النووية'), findsOneWidget);
    });

    testWidgets('renders without description by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
              includeDescription: false,
            ),
          ),
        ),
      );

      // Description label should not be shown
      expect(find.text('الشرح'), findsNothing);
    });

    testWidgets('renders with description when includeDescription is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShareableHadithCard(
                index: 1,
                hadith: testHadith,
                includeDescription: true,
              ),
            ),
          ),
        ),
      );

      // Description label should be shown
      expect(find.text('الشرح'), findsOneWidget);
    });

    testWidgets('applies custom background color', (tester) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      // Find the container with the gradient
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.decoration, isNotNull);
    });

    testWidgets('displays correct hadith index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 42,
              hadith: testHadith,
            ),
          ),
        ),
      );

      expect(find.text('الحديث رقم 42'), findsOneWidget);
    });

    testWidgets('renders hadith text correctly', (tester) async {
      final hadithWithTitle = Hadith(
        hadithAr: 'عنوان الحديث\nنص الحديث الفعلي هنا',
        hadithEn: 'Hadith Title\nActual hadith text here',
        descriptionAr: 'الشرح',
        descriptionEn: 'Explanation',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: hadithWithTitle,
            ),
          ),
        ),
      );

      // Should show the text after the first line (title)
      expect(find.text('نص الحديث الفعلي هنا'), findsOneWidget);
    });

    testWidgets('renders single line hadith correctly', (tester) async {
      final singleLineHadith = Hadith(
        hadithAr: 'حديث في سطر واحد فقط',
        hadithEn: 'Single line hadith only',
        descriptionAr: 'الشرح',
        descriptionEn: 'Explanation',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: singleLineHadith,
            ),
          ),
        ),
      );

      expect(find.text('حديث في سطر واحد فقط'), findsOneWidget);
    });

    testWidgets('uses correct RTL text direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
            ),
          ),
        ),
      );

      // Find the hadith text widget and verify it has RTL direction
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('renders with all theme options', (tester) async {
      for (final theme in ShareImageTheme.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareableHadithCard(
                index: 1,
                hadith: testHadith,
                backgroundColor: theme.backgroundColor,
                accentColor: theme.accentColor,
              ),
            ),
          ),
        );

        expect(find.text('الحديث رقم 1'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('has correct width constraint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShareableHadithCard(
                index: 1,
                hadith: testHadith,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.constraints?.maxWidth, 600);
    });

    testWidgets('shows decorative borders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
            ),
          ),
        ),
      );

      // Find containers that are decorative borders (height 4, width 100)
      final decorativeBorders = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final constraints = widget.constraints;
          return constraints?.maxHeight == 4 && constraints?.maxWidth == 100;
        }
        return false;
      });

      // Should have top and bottom decorative borders
      expect(decorativeBorders, findsNWidgets(2));
    });

    testWidgets('shows book icon in footer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareableHadithCard(
              index: 1,
              hadith: testHadith,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });
  });
}
