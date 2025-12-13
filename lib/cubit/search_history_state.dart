import 'package:equatable/equatable.dart';

/// State for search history management
class SearchHistoryState extends Equatable {
  /// List of recent search queries (most recent first)
  final List<String> history;

  /// Whether the history is currently being loaded
  final bool isLoading;

  const SearchHistoryState({
    this.history = const [],
    this.isLoading = false,
  });

  SearchHistoryState copyWith({
    List<String>? history,
    bool? isLoading,
  }) {
    return SearchHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Returns true if there are no saved searches
  bool get isEmpty => history.isEmpty;

  /// Returns true if there are saved searches
  bool get isNotEmpty => history.isNotEmpty;

  /// Returns the number of saved searches
  int get count => history.length;

  @override
  List<Object> get props => [history, isLoading];
}
