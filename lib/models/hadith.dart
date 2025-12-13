class Hadith {
  final String titleAr; // عنوان الحديث بالعربية
  final String titleEn; // عنوان الحديث بالإنجليزية
  final String hadithAr; // نص الحديث بالعربية
  final String hadithEn; // نص الحديث بالإنجليزية
  final String descriptionAr; // شرح الحديث بالعربية
  final String descriptionEn; // شرح الحديث بالإنجليزية

  Hadith({
    required this.titleAr,
    required this.titleEn,
    required this.hadithAr,
    required this.hadithEn,
    required this.descriptionAr,
    required this.descriptionEn,
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

  factory Hadith.fromJson(Map<String, dynamic> jsonAr, [Map<String, dynamic>? jsonEn]) {
    return Hadith(
      titleAr: jsonAr['title'] as String? ?? '',
      titleEn: jsonEn?['title'] as String? ?? jsonAr['title'] as String? ?? '',
      hadithAr: jsonAr['hadith'] as String,
      hadithEn: jsonEn?['hadith'] as String? ?? jsonAr['hadith'] as String,
      descriptionAr: jsonAr['description'] as String,
      descriptionEn: jsonEn?['description'] as String? ?? jsonAr['description'] as String,
    );
  }

  /// Create from separate Arabic and English data
  factory Hadith.fromBilingual({
    required String titleAr,
    required String titleEn,
    required String hadithAr,
    required String hadithEn,
    required String descriptionAr,
    required String descriptionEn,
  }) {
    return Hadith(
      titleAr: titleAr,
      titleEn: titleEn,
      hadithAr: hadithAr,
      hadithEn: hadithEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
    );
  }
}
