import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/reminder_state.dart';

void main() {
  group('ReminderState', () {
    test('default state has correct initial values', () {
      const state = ReminderState();

      expect(state.isEnabled, false);
      expect(state.reminderTime, const TimeOfDay(hour: 8, minute: 0));
      expect(state.isLoading, true);
      expect(state.hasPermission, false);
    });

    test('defaultTime is 8:00 AM', () {
      expect(ReminderState.defaultTime, const TimeOfDay(hour: 8, minute: 0));
    });

    test('can create state with custom values', () {
      const customTime = TimeOfDay(hour: 14, minute: 30);
      const state = ReminderState(
        isEnabled: true,
        reminderTime: customTime,
        isLoading: false,
        hasPermission: true,
      );

      expect(state.isEnabled, true);
      expect(state.reminderTime, customTime);
      expect(state.isLoading, false);
      expect(state.hasPermission, true);
    });

    group('copyWith', () {
      test('updates isEnabled', () {
        const state = ReminderState();
        final updated = state.copyWith(isEnabled: true);

        expect(updated.isEnabled, true);
        expect(updated.reminderTime, state.reminderTime);
        expect(updated.isLoading, state.isLoading);
        expect(updated.hasPermission, state.hasPermission);
      });

      test('updates reminderTime', () {
        const state = ReminderState();
        const newTime = TimeOfDay(hour: 20, minute: 0);
        final updated = state.copyWith(reminderTime: newTime);

        expect(updated.reminderTime, newTime);
        expect(updated.isEnabled, state.isEnabled);
        expect(updated.isLoading, state.isLoading);
        expect(updated.hasPermission, state.hasPermission);
      });

      test('updates isLoading', () {
        const state = ReminderState();
        final updated = state.copyWith(isLoading: false);

        expect(updated.isLoading, false);
        expect(updated.isEnabled, state.isEnabled);
        expect(updated.reminderTime, state.reminderTime);
        expect(updated.hasPermission, state.hasPermission);
      });

      test('updates hasPermission', () {
        const state = ReminderState();
        final updated = state.copyWith(hasPermission: true);

        expect(updated.hasPermission, true);
        expect(updated.isEnabled, state.isEnabled);
        expect(updated.reminderTime, state.reminderTime);
        expect(updated.isLoading, state.isLoading);
      });

      test('can update multiple properties', () {
        const state = ReminderState();
        final updated = state.copyWith(
          isEnabled: true,
          hasPermission: true,
          isLoading: false,
        );

        expect(updated.isEnabled, true);
        expect(updated.hasPermission, true);
        expect(updated.isLoading, false);
        expect(updated.reminderTime, state.reminderTime);
      });
    });

    group('formattedTime', () {
      test('formats single digit hour and minute with leading zeros', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 5, minute: 3),
        );
        expect(state.formattedTime, '05:03');
      });

      test('formats double digit hour and minute correctly', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 14, minute: 30),
        );
        expect(state.formattedTime, '14:30');
      });

      test('formats midnight correctly', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 0, minute: 0),
        );
        expect(state.formattedTime, '00:00');
      });

      test('formats noon correctly', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 12, minute: 0),
        );
        expect(state.formattedTime, '12:00');
      });
    });

    group('formattedTimeArabic', () {
      test('formats morning time with صباحاً', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 8, minute: 30),
        );
        expect(state.formattedTimeArabic, '8:30 صباحاً');
      });

      test('formats afternoon time with مساءً', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 14, minute: 0),
        );
        expect(state.formattedTimeArabic, '2:00 مساءً');
      });

      test('formats midnight as 12:00 صباحاً', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 0, minute: 0),
        );
        expect(state.formattedTimeArabic, '12:00 صباحاً');
      });

      test('formats noon as 12:00 مساءً', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 12, minute: 0),
        );
        expect(state.formattedTimeArabic, '12:00 مساءً');
      });

      test('formats single digit minute with leading zero', () {
        const state = ReminderState(
          reminderTime: TimeOfDay(hour: 9, minute: 5),
        );
        expect(state.formattedTimeArabic, '9:05 صباحاً');
      });
    });

    group('props (Equatable)', () {
      test('contains all properties', () {
        const state = ReminderState(
          isEnabled: true,
          reminderTime: TimeOfDay(hour: 10, minute: 30),
          isLoading: false,
          hasPermission: true,
        );

        expect(state.props, [true, 10, 30, false, true]);
      });

      test('states with same values are equal', () {
        const state1 = ReminderState(
          isEnabled: true,
          reminderTime: TimeOfDay(hour: 8, minute: 0),
          isLoading: false,
          hasPermission: true,
        );
        const state2 = ReminderState(
          isEnabled: true,
          reminderTime: TimeOfDay(hour: 8, minute: 0),
          isLoading: false,
          hasPermission: true,
        );

        expect(state1, equals(state2));
      });

      test('states with different isEnabled are not equal', () {
        const state1 = ReminderState(isEnabled: true);
        const state2 = ReminderState(isEnabled: false);

        expect(state1, isNot(equals(state2)));
      });

      test('states with different reminderTime are not equal', () {
        const state1 = ReminderState(
          reminderTime: TimeOfDay(hour: 8, minute: 0),
        );
        const state2 = ReminderState(
          reminderTime: TimeOfDay(hour: 9, minute: 0),
        );

        expect(state1, isNot(equals(state2)));
      });

      test('states with different isLoading are not equal', () {
        const state1 = ReminderState(isLoading: true);
        const state2 = ReminderState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('states with different hasPermission are not equal', () {
        const state1 = ReminderState(hasPermission: true);
        const state2 = ReminderState(hasPermission: false);

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
