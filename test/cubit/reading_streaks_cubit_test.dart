import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/reading_streaks_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/reading_streaks_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test subclass that lets each test inject a deterministic "today".
class _FakeClockCubit extends ReadingStreaksCubit {
  DateTime fakeNow;
  _FakeClockCubit(this.fakeNow);

  @override
  @visibleForTesting
  DateTime nowLocal() => fakeNow;
}

DateTime _d(int year, int month, int day) => DateTime(year, month, day, 12, 0);

void main() {
  group('ReadingStreaksCubit', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    blocTest<_FakeClockCubit, ReadingStreaksState>(
      'first ever read starts streak at 1',
      build: () => _FakeClockCubit(_d(2026, 5, 12)),
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero); // let load complete
        await cubit.recordRead();
      },
      skip: 1, // skip the loadStreaks emission
      expect: () => [
        isA<ReadingStreaksState>()
            .having((s) => s.current, 'current', 1)
            .having((s) => s.longest, 'longest', 1),
      ],
    );

    test('recording twice on the same day does not increment', () async {
      final cubit = _FakeClockCubit(_d(2026, 5, 12));
      await Future<void>.delayed(Duration.zero);
      await cubit.recordRead();
      await cubit.recordRead();
      expect(cubit.state.current, 1);
      expect(cubit.state.longest, 1);
    });

    test('reading on consecutive days increments streak', () async {
      final cubit = _FakeClockCubit(_d(2026, 5, 12));
      await Future<void>.delayed(Duration.zero);
      await cubit.recordRead();

      // Move time forward one day.
      cubit.fakeNow = _d(2026, 5, 13);
      await cubit.recordRead();

      expect(cubit.state.current, 2);
      expect(cubit.state.longest, 2);
    });

    test(
      'reading after a 2+ day gap resets streak to 1, keeps longest',
      () async {
        final cubit = _FakeClockCubit(_d(2026, 5, 12));
        await Future<void>.delayed(Duration.zero);
        await cubit.recordRead();
        cubit.fakeNow = _d(2026, 5, 13);
        await cubit.recordRead();
        cubit.fakeNow = _d(2026, 5, 14);
        await cubit.recordRead();
        expect(cubit.state.current, 3);
        expect(cubit.state.longest, 3);

        // Skip 5/15 entirely, jump to 5/16
        cubit.fakeNow = _d(2026, 5, 16);
        await cubit.recordRead();
        expect(cubit.state.current, 1);
        expect(cubit.state.longest, 3, reason: 'Longest streak is preserved');
      },
    );

    test('streak data persists via SharedPreferences', () async {
      final cubit1 = _FakeClockCubit(_d(2026, 5, 12));
      await Future<void>.delayed(Duration.zero);
      await cubit1.recordRead();
      cubit1.fakeNow = _d(2026, 5, 13);
      await cubit1.recordRead();
      await cubit1.close();

      // Fresh cubit; loads from prefs and finds yesterday's date.
      // Important: pass the SAME "today" so the on-load gap check sees
      // gap=1 and keeps the streak intact (not gap>1 which would zero it).
      final cubit2 = _FakeClockCubit(_d(2026, 5, 13));
      await Future<void>.delayed(Duration.zero);
      expect(cubit2.state.current, 2);
      expect(cubit2.state.longest, 2);
      expect(cubit2.state.lastDate, isNotNull);
    });

    test(
      'on load, multi-day gap zeroes current but preserves longest',
      () async {
        // Seed prefs to look like the user had a 5-day streak that ended
        // on 2026-05-12.
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 10,
          'streak_last_date': _d(2026, 5, 12).toIso8601String(),
        });

        // Today is 5 days later.
        final cubit = _FakeClockCubit(_d(2026, 5, 17));
        await Future<void>.delayed(Duration.zero);
        expect(
          cubit.state.current,
          0,
          reason: 'Multi-day gap should display as broken on load',
        );
        expect(
          cubit.state.longest,
          10,
          reason: 'Longest is the hall-of-fame stat and must persist',
        );
      },
    );

    test('reset clears everything', () async {
      final cubit = _FakeClockCubit(_d(2026, 5, 12));
      await Future<void>.delayed(Duration.zero);
      await cubit.recordRead();
      await cubit.reset();
      expect(cubit.state.current, 0);
      expect(cubit.state.longest, 0);
      expect(cubit.state.lastDate, isNull);
    });
  });
}
