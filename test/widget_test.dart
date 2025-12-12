import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NawawiApp());

    // Pump a few frames to allow initial build
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that our app title is displayed in the AppBar.
    expect(find.text('الأربعون النووية'), findsOneWidget);
  });
}
