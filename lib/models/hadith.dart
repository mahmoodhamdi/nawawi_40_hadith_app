class HadithCitation {
  final int number;
  final String narratorAr;
  final String narratorEn;
  final String collectionAr;
  final String collectionEn;
  final String sunnahUrl;

  const HadithCitation({
    required this.number,
    required this.narratorAr,
    required this.narratorEn,
    required this.collectionAr,
    required this.collectionEn,
    required this.sunnahUrl,
  });

  String getNarrator(String languageCode) =>
      languageCode == 'en' ? narratorEn : narratorAr;

  String getCollection(String languageCode) =>
      languageCode == 'en' ? collectionEn : collectionAr;

  factory HadithCitation.fromJson(
    Map<String, dynamic> citationAr, [
    Map<String, dynamic>? citationEn,
  ]) {
    return HadithCitation(
      number: citationAr['number'] as int,
      narratorAr: citationAr['narrator'] as String,
      narratorEn:
          (citationEn?['narrator'] as String?) ??
          citationAr['narrator'] as String,
      collectionAr: citationAr['collection'] as String,
      collectionEn:
          (citationEn?['collection'] as String?) ??
          citationAr['collection'] as String,
      sunnahUrl: citationAr['sunnah_url'] as String,
    );
  }
}

class Hadith {
  final String titleAr; // عنوان الحديث بالعربية
  final String titleEn; // عنوان الحديث بالإنجليزية
  final String hadithAr; // نص الحديث بالعربية
  final String hadithEn; // نص الحديث بالإنجليزية
  final String descriptionAr; // شرح الحديث بالعربية
  final String descriptionEn; // شرح الحديث بالإنجليزية
  final HadithCitation? citation; // مرجع الحديث (المصدر + الراوي + الرابط)

  /// Stable topic IDs (snake_case English) shared across all locales.
  /// Used to compute "related hadiths" — two hadiths are related when
  /// they share at least one topic ID. Identical for AR and EN JSONs.
  final List<String> topicIds;

  /// Arabic-language topic display labels, parallel-indexed with [topicIds].
  final List<String> topicLabelsAr;

  /// English-language topic display labels, parallel-indexed with [topicIds].
  /// Falls back to the Arabic labels when an English mapping is missing.
  final List<String> topicLabelsEn;

  /// Backwards-compatible accessor — picks the Arabic labels by default
  /// because the original (pre-bilingual) callers were Arabic-first.
  /// New code should use [topicLabelsFor].
  List<String> get topicLabels => topicLabelsAr;

  Hadith({
    required this.titleAr,
    required this.titleEn,
    required this.hadithAr,
    required this.hadithEn,
    required this.descriptionAr,
    required this.descriptionEn,
    this.citation,
    this.topicIds = const [],
    this.topicLabelsAr = const [],
    this.topicLabelsEn = const [],
  });

  /// Get title based on language code
  String getTitle(String languageCode) =>
      languageCode == 'en' ? titleEn : titleAr;

  /// Get hadith text based on language code
  String getHadith(String languageCode) =>
      languageCode == 'en' ? hadithEn : hadithAr;

  /// Get description text based on language code
  String getDescription(String languageCode) =>
      languageCode == 'en' ? descriptionEn : descriptionAr;

  /// Legacy getter for Arabic title (backward compatibility)
  String get title => titleAr;

  /// Legacy getter for Arabic hadith (backward compatibility)
  String get hadith => hadithAr;

  /// Legacy getter for Arabic description (backward compatibility)
  String get description => descriptionAr;

  factory Hadith.fromJson(
    Map<String, dynamic> jsonAr, [
    Map<String, dynamic>? jsonEn,
  ]) {
    final citationAr = jsonAr['citation'] as Map<String, dynamic>?;
    final citationEn = jsonEn?['citation'] as Map<String, dynamic>?;

    // Topic IDs are stable across locales — read from Arabic JSON (the
    // English file mirrors them).
    final topicIds =
        (jsonAr['topic_ids'] as List?)?.whereType<String>().toList() ??
        const <String>[];
    final labelsAr =
        (jsonAr['topics'] as List?)?.whereType<String>().toList() ??
        const <String>[];
    final labelsEn =
        (jsonEn?['topics'] as List?)?.whereType<String>().toList() ?? labelsAr;

    return Hadith(
      titleAr: jsonAr['title'] as String? ?? '',
      titleEn: jsonEn?['title'] as String? ?? jsonAr['title'] as String? ?? '',
      hadithAr: jsonAr['hadith'] as String,
      hadithEn: jsonEn?['hadith'] as String? ?? jsonAr['hadith'] as String,
      descriptionAr: jsonAr['description'] as String,
      descriptionEn:
          jsonEn?['description'] as String? ?? jsonAr['description'] as String,
      citation: citationAr != null
          ? HadithCitation.fromJson(citationAr, citationEn)
          : null,
      topicIds: topicIds,
      topicLabelsAr: labelsAr,
      topicLabelsEn: labelsEn,
    );
  }

  /// Return the localized topic labels for the given language. Falls back
  /// to Arabic labels when the requested language has none.
  List<String> topicLabelsFor(String languageCode) {
    if (languageCode == 'en') {
      return topicLabelsEn.isNotEmpty ? topicLabelsEn : topicLabelsAr;
    }
    return topicLabelsAr.isNotEmpty ? topicLabelsAr : topicLabelsEn;
  }

  /// Create from separate Arabic and English data
  factory Hadith.fromBilingual({
    required String titleAr,
    required String titleEn,
    required String hadithAr,
    required String hadithEn,
    required String descriptionAr,
    required String descriptionEn,
    HadithCitation? citation,
    List<String> topicIds = const [],
    List<String> topicLabelsAr = const [],
    List<String> topicLabelsEn = const [],
  }) {
    return Hadith(
      titleAr: titleAr,
      titleEn: titleEn,
      hadithAr: hadithAr,
      hadithEn: hadithEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      citation: citation,
      topicIds: topicIds,
      topicLabelsAr: topicLabelsAr,
      topicLabelsEn: topicLabelsEn,
    );
  }
}
