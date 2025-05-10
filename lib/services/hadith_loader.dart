import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith.dart';

class HadithLoader {
  static Future<List<Hadith>> loadHadiths() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/40-hadith-nawawi.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((item) => Hadith.fromJson(item)).toList();
  }
}
