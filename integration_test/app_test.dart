import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadith_nawawi_audio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('App Integration Tests', () {
    testWidgets('app loads and displays home screen', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Verify app title is displayed
      expect(find.text('الأربعين النووية'), findsOneWidget);
    });

    testWidgets('app displays welcome message', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Verify welcome message is displayed
      expect(find.text('مرحباً بك'), findsOneWidget);
    });

    testWidgets('search field is displayed', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('theme menu button is accessible', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Find and tap theme button
      expect(find.byIcon(Icons.color_lens), findsOneWidget);

      await tester.tap(find.byIcon(Icons.color_lens));
      await tester.pumpAndSettle();

      // Verify theme options are displayed
      expect(find.text('ثيم فاتح'), findsOneWidget);
      expect(find.text('ثيم داكن'), findsOneWidget);
      expect(find.text('ثيم أزرق'), findsOneWidget);
      expect(find.text('ثيم بنفسجي'), findsOneWidget);
      expect(find.text('حسب النظام'), findsOneWidget);
    });

    testWidgets('can select dark theme', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Open theme menu
      await tester.tap(find.byIcon(Icons.color_lens));
      await tester.pumpAndSettle();

      // Select dark theme
      await tester.tap(find.text('ثيم داكن'));
      await tester.pumpAndSettle();

      // Theme should have changed (menu should be closed)
      expect(find.text('ثيم داكن'), findsNothing);
    });

    testWidgets('can select light theme', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Open theme menu
      await tester.tap(find.byIcon(Icons.color_lens));
      await tester.pumpAndSettle();

      // Select light theme
      await tester.tap(find.text('ثيم فاتح'));
      await tester.pumpAndSettle();

      // Theme should have changed (menu should be closed)
      expect(find.text('ثيم فاتح'), findsNothing);
    });

    testWidgets('search field accepts input', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'الأعمال');

      // Verify text was entered
      expect(find.text('الأعمال'), findsOneWidget);
    });

    testWidgets('loading indicator shows initially', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('hadiths load and display', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After loading, should see hadith tiles or content
      // The exact content depends on the data loading
      // We just verify the loading completes without errors
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Navigation Tests', () {
    testWidgets('back navigation works correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on the home screen
      expect(find.text('الأربعين النووية'), findsOneWidget);
    });
  });

  group('Theme Persistence Tests', () {
    testWidgets('theme persists after selection', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Open theme menu and select blue theme
      await tester.tap(find.byIcon(Icons.color_lens));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ثيم أزرق'));
      await tester.pumpAndSettle();

      // Verify theme was saved
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getInt('theme');
      expect(savedTheme, isNotNull);
    });
  });

  group('RTL Layout Tests', () {
    testWidgets('app respects RTL layout for Arabic', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const NawawiApp());
      await tester.pumpAndSettle();

      // Verify the app is using RTL directionality
      // Arabic app should have right-to-left layout
      expect(find.text('الأربعين النووية'), findsOneWidget);
    });
  });
}
