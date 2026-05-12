import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'notes_state.dart';

/// Manages per-hadith private notes, stored as a JSON-encoded map under a
/// single SharedPreferences key. All persistence is local — notes never
/// leave the device unless the user explicitly exports them via the backup
/// service.
///
/// The schema is `{"1": "...", "14": "..."}` — string keys because JSON
/// doesn't allow integer object keys; we re-parse to int on load.
class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState(isLoading: true)) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(PreferenceKeys.hadithNotes);
      if (raw == null || raw.isEmpty) {
        emit(const NotesState(isLoading: false));
        return;
      }

      final decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('NotesCubit: stored notes are not a JSON object, ignoring');
        emit(const NotesState(isLoading: false));
        return;
      }

      final parsed = <int, String>{};
      decoded.forEach((k, v) {
        final idx = int.tryParse(k);
        if (idx == null) return;
        if (idx < ValidationConstants.minHadithIndex ||
            idx > ValidationConstants.maxHadithIndex) {
          return;
        }
        if (v is String && v.isNotEmpty) {
          parsed[idx] = v;
        }
      });
      emit(NotesState(notes: parsed, isLoading: false));
    } catch (e) {
      debugPrint('NotesCubit: error loading notes: $e');
      emit(const NotesState(isLoading: false));
    }
  }

  /// Set or update the note for a given hadith index. Passing an empty or
  /// whitespace-only string removes the note (equivalent to [removeNote]).
  Future<void> setNote(int index, String note) async {
    if (index < ValidationConstants.minHadithIndex ||
        index > ValidationConstants.maxHadithIndex) {
      return;
    }
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      await removeNote(index);
      return;
    }

    final updated = Map<int, String>.from(state.notes);
    updated[index] = trimmed;
    emit(state.copyWith(notes: updated));
    await _persist(updated);
  }

  /// Remove a note. No-op if no note exists for that index.
  Future<void> removeNote(int index) async {
    if (!state.notes.containsKey(index)) return;
    final updated = Map<int, String>.from(state.notes);
    updated.remove(index);
    emit(state.copyWith(notes: updated));
    await _persist(updated);
  }

  /// Clear all notes. Settings-screen action.
  Future<void> clearAll() async {
    emit(const NotesState(notes: {}, isLoading: false));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.hadithNotes);
  }

  Future<void> _persist(Map<int, String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    if (notes.isEmpty) {
      await prefs.remove(PreferenceKeys.hadithNotes);
      return;
    }
    final serializable = notes.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(
      PreferenceKeys.hadithNotes,
      json.encode(serializable),
    );
  }
}
