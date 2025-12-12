import 'package:equatable/equatable.dart';

/// State class for managing favorite hadiths
class FavoritesState extends Equatable {
  /// Set of favorite hadith indices (1-based)
  final Set<int> favoriteIndices;

  /// Whether favorites are currently loading
  final bool isLoading;

  const FavoritesState({
    this.favoriteIndices = const {},
    this.isLoading = false,
  });

  /// Check if a hadith is in favorites
  bool isFavorite(int index) => favoriteIndices.contains(index);

  /// Get the count of favorites
  int get count => favoriteIndices.length;

  FavoritesState copyWith({
    Set<int>? favoriteIndices,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIndices: favoriteIndices ?? this.favoriteIndices,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [favoriteIndices, isLoading];
}
