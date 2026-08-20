import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/main.dart';
import 'package:hadith_nawawi_audio/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NotificationService.onNotificationTap = null;
  });

  testWidgets('app installs the notification tap handler on startup', (
    tester,
  ) async {
    expect(NotificationService.onNotificationTap, isNull);

    await tester.pumpWidget(const NawawiApp());
    await tester.pump();

    // Without this hook a tapped reminder just reopens whatever screen the
    // user was on instead of the hadith the notification names.
    expect(NotificationService.onNotificationTap, isNotNull);
  });

  testWidgets('startup survives a notification plugin that is not initialised', (
    tester,
  ) async {
    // `launchPayload()` runs in a post-frame callback and talks to the plugin;
    // in a test there is no platform implementation behind it. It must swallow
    // that rather than take the first frame down with it.
    await tester.pumpWidget(const NawawiApp());
    // Not pumpAndSettle: the home screen shows a progress indicator while the
    // collection loads, so the frame scheduler never goes quiet in a test.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  test(
    'launchPayload returns null instead of throwing when unavailable',
    () async {
      expect(await NotificationService.launchPayload(), isNull);
    },
  );
}
