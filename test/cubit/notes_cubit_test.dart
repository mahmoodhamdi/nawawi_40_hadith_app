import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/notes_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotesCubit', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('loads empty state when nothing stored', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.state.isLoading, false);
    });

    test('setNote writes and persists', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(1, 'Reflect on niyyah daily');
      expect(cubit.state.notes[1], 'Reflect on niyyah daily');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('hadith_notes');
      expect(raw, isNotNull);
      final parsed = json.decode(raw!);
      expect(parsed['1'], 'Reflect on niyyah daily');
    });

    test('setNote trims whitespace', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(2, '   leading and trailing   ');
      expect(cubit.state.notes[2], 'leading and trailing');
    });

    test('setNote with empty / whitespace removes the note', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(3, 'something');
      await cubit.setNote(3, '   ');
      expect(cubit.state.notes.containsKey(3), false);
    });

    test('removeNote clears the entry', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(5, 'note');
      await cubit.removeNote(5);
      expect(cubit.state.notes.containsKey(5), false);
    });

    test('rejects out-of-range indices', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(0, 'should be ignored');
      await cubit.setNote(999, 'also ignored');
      expect(cubit.state.notes, isEmpty);
    });

    test('clearAll wipes everything', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(1, 'a');
      await cubit.setNote(2, 'b');
      await cubit.clearAll();
      expect(cubit.state.notes, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('hadith_notes'), false);
    });

    test('load survives between cubit instances', () async {
      final cubit1 = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit1.setNote(7, 'persistent');
      await cubit1.close();

      final cubit2 = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      expect(cubit2.state.notes[7], 'persistent');
    });

    test('hasNoteFor and noteFor accessors', () async {
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      await cubit.setNote(4, 'four');
      expect(cubit.state.hasNoteFor(4), true);
      expect(cubit.state.hasNoteFor(5), false);
      expect(cubit.state.noteFor(4), 'four');
      expect(cubit.state.noteFor(5), '');
    });

    test('corrupted stored JSON is ignored gracefully', () async {
      SharedPreferences.setMockInitialValues({'hadith_notes': 'not json'});
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.notes, isEmpty);
      expect(cubit.state.isLoading, false);
    });

    test('non-string values inside stored map are filtered out', () async {
      SharedPreferences.setMockInitialValues({
        'hadith_notes': json.encode({'1': 'valid', '2': 42, '3': '', '4': null}),
      });
      final cubit = NotesCubit();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.notes, {1: 'valid'});
    });
  });
}
