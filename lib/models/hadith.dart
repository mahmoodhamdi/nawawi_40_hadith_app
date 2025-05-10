class Hadith {
  final String hadith; // نص الحديث
  final String description; // شرح الحديث

  Hadith({required this.hadith, required this.description});

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      hadith: json['hadith'] as String,
      description: json['description'] as String,
    );
  }
}
