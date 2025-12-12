import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/hadith_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/hadith_state.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/services/hadith_loader.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for HadithLoader
class MockHadithLoader extends Mock {
  static Future<List<Hadith>> Function()? _mockLoadHadiths;

  static void setMockLoadHadiths(Future<List<Hadith>> Function() fn) {
    _mockLoadHadiths = fn;
  }

  static void reset() {
    _mockLoadHadiths = null;
  }
}

void main() {
  group('HadithState', () {
    test('HadithInitial props are empty', () {
      expect(HadithInitial().props, []);
    });

    test('HadithLoading props are empty', () {
      expect(HadithLoading().props, []);
    });

    test('HadithLoaded props contain hadiths list', () {
      final hadiths = [
        Hadith(hadith: 'الحديث 1', description: 'شرح 1'),
        Hadith(hadith: 'الحديث 2', description: 'شرح 2'),
      ];
      final state = HadithLoaded(hadiths);

      expect(state.props, [hadiths]);
      expect(state.hadiths, hadiths);
      expect(state.hadiths.length, 2);
    });

    test('HadithError props contain message', () {
      const message = 'خطأ في التحميل';
      final state = HadithError(message);

      expect(state.props, [message]);
      expect(state.message, message);
    });

    test('HadithLoaded with empty list', () {
      final state = HadithLoaded([]);

      expect(state.hadiths, isEmpty);
      expect(state.props, [[]]);
    });

    test('HadithLoaded equality', () {
      final hadiths = [Hadith(hadith: 'الحديث', description: 'شرح')];
      final state1 = HadithLoaded(hadiths);
      final state2 = HadithLoaded(hadiths);

      expect(state1, equals(state2));
    });

    test('HadithError equality', () {
      const message = 'خطأ';
      final state1 = HadithError(message);
      final state2 = HadithError(message);

      expect(state1, equals(state2));
    });

    test('Different HadithError messages are not equal', () {
      final state1 = HadithError('خطأ 1');
      final state2 = HadithError('خطأ 2');

      expect(state1, isNot(equals(state2)));
    });
  });

  group('HadithCubit', () {
    test('initial state is HadithInitial', () {
      final cubit = HadithCubit();
      expect(cubit.state, isA<HadithInitial>());
      cubit.close();
    });

    // Note: Testing fetchHadiths requires mocking rootBundle
    // which is complex in unit tests. Integration tests would be more appropriate
    // for testing the full loading flow.
  });

  group('HadithLoadException', () {
    test('creates exception with message only', () {
      final exception = HadithLoadException('خطأ في التحميل');

      expect(exception.message, 'خطأ في التحميل');
      expect(exception.originalError, isNull);
      expect(exception.toString(), 'HadithLoadException: خطأ في التحميل');
    });

    test('creates exception with message and original error', () {
      final originalError = FormatException('Invalid JSON');
      final exception = HadithLoadException('خطأ في التنسيق', originalError);

      expect(exception.message, 'خطأ في التنسيق');
      expect(exception.originalError, originalError);
    });

    test('toString returns formatted message', () {
      final exception = HadithLoadException('رسالة الخطأ');

      expect(exception.toString(), contains('HadithLoadException'));
      expect(exception.toString(), contains('رسالة الخطأ'));
    });
  });
}
