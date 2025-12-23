# Search Enhancements Feature Plan ✅ COMPLETED
# خطة تحسينات البحث ✅ مكتمل

> **الحالة | Status**: تم التنفيذ بنجاح | Successfully Implemented
> **الإصدار | Version**: 1.2.1

## Overview
Enhance the search functionality with two key features:
1. **Search by hadith number** - Allow users to quickly find a specific hadith by number ✅
2. **Search history** - Save and display recent search queries ✅

## Feature 1: Search by Hadith Number

### Requirements
- Support multiple input formats:
  - Direct number: `1`, `15`, `42`
  - With hash: `#1`, `#15`
  - With Arabic/English prefix: `حديث 1`, `hadith 1`, `Hadith 15`
- Show the exact hadith match at the top of results
- Handle both Arabic and English numbers

### Implementation

#### Changes to `home_screen.dart`
1. Add `_parseHadithNumber(String query)` method to extract hadith number from query
2. Modify `_hadithMatchesQuery()` to prioritize number matches
3. Sort results to show number-matched hadith first

```dart
/// Extracts hadith number from various query formats
/// Returns null if no valid number found
int? _parseHadithNumber(String query) {
  final trimmed = query.trim();

  // Direct number: "1", "15", "42"
  final directNumber = int.tryParse(trimmed);
  if (directNumber != null && directNumber >= 1 && directNumber <= 42) {
    return directNumber;
  }

  // With hash: "#1", "#15"
  if (trimmed.startsWith('#')) {
    final num = int.tryParse(trimmed.substring(1));
    if (num != null && num >= 1 && num <= 42) return num;
  }

  // Arabic prefix: "حديث 1", "الحديث 1"
  final arabicPattern = RegExp(r'(?:الحديث|حديث)\s*(\d+)');
  final arabicMatch = arabicPattern.firstMatch(trimmed);
  if (arabicMatch != null) {
    final num = int.tryParse(arabicMatch.group(1)!);
    if (num != null && num >= 1 && num <= 42) return num;
  }

  // English prefix: "hadith 1", "Hadith 15"
  final englishPattern = RegExp(r'hadith\s*(\d+)', caseSensitive: false);
  final englishMatch = englishPattern.firstMatch(trimmed);
  if (englishMatch != null) {
    final num = int.tryParse(englishMatch.group(1)!);
    if (num != null && num >= 1 && num <= 42) return num;
  }

  return null;
}
```

## Feature 2: Search History

### Requirements
- Save up to 10 recent search queries
- Display history when search field is focused and empty
- Allow clearing individual history items or all history
- Persist history across app restarts
- Tapping a history item fills the search field

### Implementation

#### New Files

##### `lib/cubit/search_history_state.dart`
```dart
import 'package:equatable/equatable.dart';

class SearchHistoryState extends Equatable {
  final List<String> history;
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

  @override
  List<Object> get props => [history, isLoading];
}
```

##### `lib/cubit/search_history_cubit.dart`
```dart
class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  static const int maxHistoryItems = 10;

  SearchHistoryCubit() : super(const SearchHistoryState(isLoading: true)) {
    loadHistory();
  }

  Future<void> loadHistory() async { ... }
  Future<void> addSearchQuery(String query) async { ... }
  Future<void> removeQuery(String query) async { ... }
  Future<void> clearHistory() async { ... }
}
```

#### Changes to Constants

##### `lib/core/constants.dart`
Add new preference key:
```dart
/// Key for storing search history
static const String searchHistory = 'search_history';
```

Add search history constants:
```dart
/// Maximum number of search history items
static const int maxHistoryItems = 10;

/// Minimum query length to save in history
static const int minQueryLengthForHistory = 2;
```

#### Changes to Localizations

##### `lib/core/l10n/app_localizations.dart`
Add new strings:
```dart
// Search History
String get searchHistory => isArabic ? 'سجل البحث' : 'Search History';
String get clearHistory => isArabic ? 'مسح السجل' : 'Clear History';
String get noSearchHistory => isArabic ? 'لا يوجد سجل بحث' : 'No search history';
String get recentSearches => isArabic ? 'عمليات البحث الأخيرة' : 'Recent Searches';
```

#### UI Changes in `home_screen.dart`

1. Add `FocusNode` for search field
2. Add boolean `_showSearchHistory` to track when to show history
3. Build search history overlay/dropdown when field is focused and empty

```dart
// State variables
final FocusNode _searchFocusNode = FocusNode();
bool _showSearchHistory = false;

// In initState
_searchFocusNode.addListener(() {
  setState(() {
    _showSearchHistory = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
  });
});

// Search history widget
Widget _buildSearchHistoryDropdown(BuildContext context) {
  return BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
    builder: (context, state) {
      if (state.history.isEmpty) return const SizedBox.shrink();

      return Card(
        child: Column(
          children: [
            ListTile(
              title: Text(l10n.recentSearches),
              trailing: TextButton(
                onPressed: () => context.read<SearchHistoryCubit>().clearHistory(),
                child: Text(l10n.clearHistory),
              ),
            ),
            ...state.history.map((query) => ListTile(
              leading: Icon(Icons.history),
              title: Text(query),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => context.read<SearchHistoryCubit>().removeQuery(query),
              ),
              onTap: () {
                _searchController.text = query;
                _onSearchChanged(query);
                _searchFocusNode.unfocus();
              },
            )),
          ],
        ),
      );
    },
  );
}
```

## Testing Plan

### Unit Tests (`test/cubit/search_history_cubit_test.dart`)
1. Initial state is loading
2. loadHistory returns empty list when no saved history
3. loadHistory returns saved history items
4. addSearchQuery adds new item to history
5. addSearchQuery moves existing item to top
6. addSearchQuery limits history to maxHistoryItems
7. addSearchQuery ignores queries shorter than minQueryLength
8. removeQuery removes specific item
9. clearHistory removes all items
10. History persists after reload

### Integration Tests
1. Search by number shows correct hadith
2. Search history appears when field focused
3. Tapping history item fills search field
4. Clear history removes all items

## Files to Create/Modify

### New Files
- `lib/cubit/search_history_state.dart`
- `lib/cubit/search_history_cubit.dart`
- `test/cubit/search_history_cubit_test.dart`

### Modified Files
- `lib/core/constants.dart` - Add preference keys and constants
- `lib/core/l10n/app_localizations.dart` - Add localized strings
- `lib/screens/home_screen.dart` - Integrate search enhancements
- `lib/main.dart` - Add SearchHistoryCubit provider

## Execution Order
1. Add constants and preference keys
2. Add localization strings
3. Create SearchHistoryCubit and state
4. Write unit tests for SearchHistoryCubit
5. Modify home_screen.dart for search by number
6. Modify home_screen.dart for search history UI
7. Update main.dart to provide SearchHistoryCubit
8. Run all tests and verify
9. Commit and push
