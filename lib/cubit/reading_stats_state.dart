import 'package:equatable/equatable.dart';

/// State for reading statistics
class ReadingStatsState extends Equatable {
  /// Set of hadith indices that have been read
  final Set<int> readHadithIndices;

  /// Whether the stats are currently loading
  final bool isLoading;

  /// Total number of hadiths in the app
  final int totalHadiths;

  /// Creates a ReadingStatsState
  const ReadingStatsState({
    this.readHadithIndices = const {},
    this.isLoading = false,
    this.totalHadiths = 42,
  });

  /// Number of hadiths that have been read
  int get readCount => readHadithIndices.length;

  /// Reading progress as a percentage (0.0 to 1.0)
  double get progressPercentage =>
      totalHadiths > 0 ? readCount / totalHadiths : 0.0;

  /// Reading progress as an integer percentage (0 to 100)
  int get progressPercent => (progressPercentage * 100).round();

  /// Whether all hadiths have been read
  bool get isComplete => readCount >= totalHadiths;

  /// Check if a specific hadith has been read
  bool isRead(int index) => readHadithIndices.contains(index);

  /// Number of hadiths remaining to read
  int get remainingCount => totalHadiths - readCount;

  /// Creates a copy with updated values
  ReadingStatsState copyWith({
    Set<int>? readHadithIndices,
    bool? isLoading,
    int? totalHadiths,
  }) {
    return ReadingStatsState(
      readHadithIndices: readHadithIndices ?? this.readHadithIndices,
      isLoading: isLoading ?? this.isLoading,
      totalHadiths: totalHadiths ?? this.totalHadiths,
    );
  }

  @override
  List<Object?> get props => [readHadithIndices, isLoading, totalHadiths];
}
