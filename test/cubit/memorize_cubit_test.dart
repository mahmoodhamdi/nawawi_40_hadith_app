import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/memorize_cubit.dart';

void main() {
  group('MemorizeCubit', () {
    test('initial state is off (false)', () {
      expect(MemorizeCubit().state, false);
    });

    test('enter() switches on', () {
      final c = MemorizeCubit();
      c.enter();
      expect(c.state, true);
    });

    test('exit() switches off', () {
      final c = MemorizeCubit();
      c.enter();
      c.exit();
      expect(c.state, false);
    });

    test('toggle() flips the value', () {
      final c = MemorizeCubit();
      c.toggle();
      expect(c.state, true);
      c.toggle();
      expect(c.state, false);
    });

    test('repeated enter() / exit() are idempotent', () {
      final c = MemorizeCubit();
      c.enter();
      c.enter();
      expect(c.state, true);
      c.exit();
      c.exit();
      expect(c.state, false);
    });
  });
}
