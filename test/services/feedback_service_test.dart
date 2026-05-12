import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/services/feedback_service.dart';

void main() {
  group('FeedbackService.buildBody', () {
    test('includes user message at top', () {
      final body = FeedbackService.buildBody(
        userMessage: 'The reminder did not fire yesterday',
        appVersion: '1.3.0+9',
        locale: 'ar',
      );
      expect(body, startsWith('The reminder did not fire yesterday'));
    });

    test('appends diagnostic block with version and locale', () {
      final body = FeedbackService.buildBody(
        userMessage: 'test',
        appVersion: '1.3.0+9',
        locale: 'en',
      );
      expect(body, contains('App: Forty Hadith Nawawi 1.3.0+9'));
      expect(body, contains('Locale: en'));
      expect(body, contains('Report channel:'));
      expect(body, contains(FeedbackService.issuesUrl));
    });

    test('trims whitespace from the user message', () {
      final body = FeedbackService.buildBody(
        userMessage: '   trailing space   \n',
        appVersion: '1.0.0',
        locale: 'ar',
      );
      expect(body.split('\n').first, 'trailing space');
    });

    test('handles empty user message gracefully', () {
      final body = FeedbackService.buildBody(
        userMessage: '',
        appVersion: '1.0.0',
        locale: 'en',
      );
      expect(body, contains('App: Forty Hadith Nawawi 1.0.0'));
    });

    test('issuesUrl points to the canonical repo issues endpoint', () {
      expect(FeedbackService.issuesUrl,
          'https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues/new');
    });
  });
}
