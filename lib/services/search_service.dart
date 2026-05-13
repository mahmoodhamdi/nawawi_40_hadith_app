import '../models/hadith.dart';

/// Smart hadith search that combines:
///   1. Arabic normalization (diacritic + letter-form folding)
///   2. Latin → Arabic transliteration of common Islamic terms
///   3. Substring matching against text + title + topics + citation
///   4. Levenshtein fuzzy match as a last-resort scorer
///
/// Pure functions only — no Flutter dependency, no I/O. Easy to test.
class SearchService {
  // ─── 1. Normalization ────────────────────────────────────────────

  static final RegExp _diacritics = RegExp('[ً-ٰٟۖ-ۭ]');

  /// Folds Arabic letter variants, strips diacritics + tatweel so that
  /// users typing "نوي" still find "نوى" / "نوي" / "نوّى" / "نوـى".
  static String normalize(String text) {
    return text
        .replaceAll(_diacritics, '')
        .replaceAll('ـ', '') // tatweel (U+0640) — visual only
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  // ─── 1b. Light Arabic stemming ──────────────────────────────────

  /// Common Arabic prefixes (after normalization, in their stripped form)
  /// that we strip when matching short query tokens. Order matters —
  /// longest first so "بال" wins over "ب".
  static const List<String> _prefixes = [
    'وال',
    'فال',
    'بال',
    'كال',
    'لل',
    'ال',
    'و',
    'ف',
    'ب',
    'ك',
    'ل',
    'س',
  ];

  /// Common Arabic suffixes stripped during stemming.
  static const List<String> _suffixes = [
    'ون',
    'ين',
    'ات',
    'وا',
    'تم',
    'تن',
    'نا',
    'ها',
    'هم',
    'هن',
    'كم',
    'كن',
    'ه',
    'ك',
    'ي',
    'ت',
    'ا',
  ];

  /// Stem a single token: strip one prefix (if any) and one suffix
  /// (if any), keeping at least a 2-char root. Lossy by design — many
  /// false matches are acceptable for *search recall*; precision is
  /// not the goal.
  ///
  /// Examples:
  ///   "بالنيات" → strip "بال" → "نيات" → strip "ات" → "ني"
  ///   "أحدكم"   → folds to "احدكم" → strip "كم" → "احد"
  ///   "نية"     → folds to "نيه" → strip "ه" → "ني"
  ///
  /// Both "نية" and "بالنيات" reduce to "ني" — search finds them.
  static String stem(String normalizedToken) {
    if (normalizedToken.length < 3) return normalizedToken;
    var t = normalizedToken;
    for (final p in _prefixes) {
      if (t.length - p.length >= 2 && t.startsWith(p)) {
        t = t.substring(p.length);
        break;
      }
    }
    for (final s in _suffixes) {
      if (t.length - s.length >= 2 && t.endsWith(s)) {
        t = t.substring(0, t.length - s.length);
        break;
      }
    }
    return t;
  }

  static List<String> _stemTokens(String text) {
    return normalize(
      text,
    ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).map(stem).toList();
  }

  // ─── 2. Latin → Arabic transliteration ──────────────────────────

  /// Common Islamic terms used by English-speaking Muslims, mapped to
  /// their canonical Arabic form. The list is conservative — only
  /// uncontroversial words. Adding here doesn't change rendering, only
  /// search recall.
  static const Map<String, String> _translitMap = {
    'allah': 'الله',
    'muhammad': 'محمد',
    'nabi': 'نبي',
    'rasul': 'رسول',
    'sunnah': 'سنة',
    'sunna': 'سنة',
    'hadith': 'حديث',
    'hadeeth': 'حديث',
    'quran': 'قرآن',
    "qur'an": 'قرآن',
    'iman': 'إيمان',
    'imaan': 'إيمان',
    'islam': 'إسلام',
    'ihsan': 'إحسان',
    'niyyah': 'نية',
    'niyah': 'نية',
    'niya': 'نية',
    'salah': 'صلاة',
    'salat': 'صلاة',
    'zakat': 'زكاة',
    'zakah': 'زكاة',
    'sawm': 'صوم',
    'sawn': 'صوم',
    'hajj': 'حج',
    'ramadan': 'رمضان',
    'ramadhan': 'رمضان',
    'sadaqah': 'صدقة',
    'sadaqa': 'صدقة',
    'jariyah': 'جارية',
    'dawah': 'دعوة',
    "da'wah": 'دعوة',
    'taqwa': 'تقوى',
    'sabr': 'صبر',
    'shukr': 'شكر',
    'tawbah': 'توبة',
    'tawba': 'توبة',
    'jannah': 'جنة',
    'nar': 'نار',
    'akhira': 'آخرة',
    'akhirah': 'آخرة',
    'dunya': 'دنيا',
    'shari': 'شريعة',
    "shari'ah": 'شريعة',
    'sahaba': 'صحابة',
    'sahabah': 'صحابة',
    'umar': 'عمر',
    'omar': 'عمر',
    'ali': 'علي',
    'uthman': 'عثمان',
    'abu bakr': 'أبو بكر',
    'abubakr': 'أبو بكر',
    'aisha': 'عائشة',
    'aishah': 'عائشة',
    'ibn': 'ابن',
    'abu': 'أبو',
    'masud': 'مسعود',
    'masoud': 'مسعود',
    "mas'ud": 'مسعود',
    'abbas': 'عباس',
    'hurayrah': 'هريرة',
    'huraira': 'هريرة',
    'nawawi': 'نووي',
    'bukhari': 'بخاري',
    'muslim': 'مسلم',
    'tirmidhi': 'ترمذي',
    'abu dawud': 'أبو داود',
    'ibn majah': 'ابن ماجه',
    'bidah': 'بدعة',
    "bid'ah": 'بدعة',
    'fitna': 'فتنة',
    'jihad': 'جهاد',
    'zuhd': 'زهد',
    'jumua': 'جمعة',
    "jumu'ah": 'جمعة',
    'jumuah': 'جمعة',
    'wudu': 'وضوء',
    'janazah': 'جنازة',
    'fitra': 'فطرة',
    'fitrah': 'فطرة',
    'dhikr': 'ذكر',
    'zikr': 'ذكر',
    'dua': 'دعاء',
    "du'a": 'دعاء',
    'fajr': 'فجر',
    'dhuhr': 'ظهر',
    'asr': 'عصر',
    'maghrib': 'مغرب',
    'isha': 'عشاء',
  };

  /// If [query] is in Latin script, return the Arabic equivalent for any
  /// recognized term. Multiple words are translated word-by-word. If
  /// nothing matches, returns the original query.
  static String transliterateQuery(String query) {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return query;
    // If the query already contains Arabic letters, don't try to translate.
    if (RegExp(r'[؀-ۿ]').hasMatch(lower)) return query;

    // First try a whole-string match (handles multi-word entries).
    if (_translitMap.containsKey(lower)) return _translitMap[lower]!;

    final translatedWords = lower.split(RegExp(r'\s+')).map((w) {
      return _translitMap[w] ?? w;
    }).toList();
    return translatedWords.join(' ');
  }

  // ─── 3. Levenshtein fuzzy match ─────────────────────────────────

  /// Edit distance between [a] and [b] using the dynamic-programming
  /// Levenshtein algorithm. O(|a| × |b|) time, O(min(|a|, |b|)) memory.
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    // Keep memory bounded by always iterating over the shorter string.
    final s = a.length < b.length ? a : b;
    final t = a.length < b.length ? b : a;

    final prev = List<int>.generate(s.length + 1, (i) => i);
    final curr = List<int>.filled(s.length + 1, 0);

    for (var j = 1; j <= t.length; j++) {
      curr[0] = j;
      for (var i = 1; i <= s.length; i++) {
        final cost = s.codeUnitAt(i - 1) == t.codeUnitAt(j - 1) ? 0 : 1;
        curr[i] = [
          prev[i] + 1, // deletion
          curr[i - 1] + 1, // insertion
          prev[i - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var k = 0; k <= s.length; k++) {
        prev[k] = curr[k];
      }
    }
    return prev[s.length];
  }

  /// Fuzzy match: returns true if normalized([query]) is within
  /// [maxEditDistance] characters of any whitespace-bounded token in
  /// [target]. Tries three increasingly lenient matchers:
  ///   1. Exact substring after normalisation
  ///   2. Light Arabic stem of query matches stem of any target token
  ///   3. Levenshtein distance of normalized query vs target tokens
  /// Short queries (< 4 chars after normalization) skip step 3.
  static bool fuzzyMatch(String query, String target, {int? maxEditDistance}) {
    final qn = normalize(query);
    if (qn.isEmpty) return false;
    final tn = normalize(target);

    // 1) Exact substring match — most precise, always tried first.
    if (tn.contains(qn)) return true;

    // 2) Stem-based matching. "نية" stems to "ني", "بالنيات" stems
    // to "ني" — same stem ⇒ match. This catches singular/plural and
    // common prefix variations without needing a full morphological
    // analyser.
    final qStem = stem(qn);
    if (qStem.length >= 2) {
      for (final tStem in _stemTokens(target)) {
        if (tStem == qStem) return true;
        // Also accept the stem appearing as a substring of a target
        // stem — covers cases where stripping was too aggressive on
        // one side.
        if (tStem.contains(qStem) ||
            qStem.contains(tStem) && tStem.length >= 3) {
          return true;
        }
      }
    }

    // 3) Levenshtein for medium-length queries. Skipped for short ones
    // because edit distance becomes too lossy at < 4 chars.
    if (qn.length < 4) return false;

    final limit = maxEditDistance ?? (qn.length <= 6 ? 1 : 2);
    for (final token in tn.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      if (levenshtein(qn, token) <= limit) return true;
    }
    return false;
  }

  // ─── 4. High-level match against Hadith ─────────────────────────

  /// Returns true if [query] matches [hadith] via any of:
  ///   - exact substring after normalization
  ///   - transliterated form
  ///   - fuzzy distance on a single token
  /// Searches the hadith body, title, description, and topic labels.
  static bool matches(
    String query,
    Hadith hadith, {
    bool includeDescription = true,
  }) {
    if (query.trim().isEmpty) return true;

    final candidates = <String>[
      hadith.hadithAr,
      hadith.titleAr,
      hadith.titleEn,
      ...hadith.topicLabelsAr,
      ...hadith.topicLabelsEn,
      if (includeDescription) hadith.descriptionAr,
      if (hadith.citation != null) hadith.citation!.narratorAr,
      if (hadith.citation != null) hadith.citation!.collectionAr,
    ];

    // Try transliteration once at the query boundary; fold to lower-case
    // so the substring check below is symmetrical.
    final translated = transliterateQuery(query);

    for (final c in candidates) {
      if (fuzzyMatch(query, c)) return true;
      if (translated != query && fuzzyMatch(translated, c)) return true;
    }
    return false;
  }
}
