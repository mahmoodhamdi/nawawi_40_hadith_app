import 'package:equatable/equatable.dart';

/// State for per-hadith private notes (kept entirely local on the device).
class NotesState extends Equatable {
  /// Map of hadith index (1-based) → user-written markdown note.
  /// Empty string and missing key mean "no note".
  final Map<int, String> notes;

  /// Whether the notes are still loading from disk.
  final bool isLoading;

  const NotesState({this.notes = const {}, this.isLoading = false});

  NotesState copyWith({Map<int, String>? notes, bool? isLoading}) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String noteFor(int index) => notes[index] ?? '';
  bool hasNoteFor(int index) => (notes[index] ?? '').isNotEmpty;

  @override
  List<Object?> get props => [notes, isLoading];
}
