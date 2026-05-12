import 'package:flutter_bloc/flutter_bloc.dart';

/// Memorization mode toggle.
///
/// When enabled, hadith bodies are hidden behind a "tap to reveal" surface.
/// The toggle is **session-only** by design — it does not persist across
/// app launches, because waking the app already in memorize mode would
/// confuse users who turned it on briefly. Restart resets to off.
///
/// State is a single bool to keep the public API obvious.
class MemorizeCubit extends Cubit<bool> {
  MemorizeCubit() : super(false);

  void enter() => emit(true);
  void exit() => emit(false);
  void toggle() => emit(!state);
}
