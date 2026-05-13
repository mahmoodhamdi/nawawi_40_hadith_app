import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';

void main() {
  group('Hadith topics', () {
    test('parses topic_ids and bilingual topic labels', () {
      final jsonAr = {
        'title': 'العنوان',
        'hadith': 'الحديث',
        'description': 'شرح',
        'topic_ids': ['intention', 'sincerity'],
        'topics': ['النية', 'الإخلاص'],
      };
      final jsonEn = {
        'title': 'Title',
        'hadith': 'Hadith',
        'description': 'desc',
        'topic_ids': ['intention', 'sincerity'],
        'topics': ['Intention', 'Sincerity'],
      };

      final h = Hadith.fromJson(jsonAr, jsonEn);
      expect(h.topicIds, ['intention', 'sincerity']);
      expect(h.topicLabelsAr, ['النية', 'الإخلاص']);
      expect(h.topicLabelsEn, ['Intention', 'Sincerity']);
      expect(h.topicLabelsFor('ar'), ['النية', 'الإخلاص']);
      expect(h.topicLabelsFor('en'), ['Intention', 'Sincerity']);
    });

    test('English labels fall back to Arabic when English JSON missing', () {
      final jsonAr = {
        'title': 'العنوان',
        'hadith': 'الحديث',
        'description': 'شرح',
        'topic_ids': ['intention'],
        'topics': ['النية'],
      };
      final h = Hadith.fromJson(jsonAr);
      expect(h.topicLabelsEn, ['النية']);
      expect(h.topicLabelsFor('en'), ['النية']);
    });

    test('hadith without topics defaults to empty lists', () {
      final jsonAr = {'title': 'a', 'hadith': 'b', 'description': 'c'};
      final h = Hadith.fromJson(jsonAr);
      expect(h.topicIds, isEmpty);
      expect(h.topicLabelsAr, isEmpty);
      expect(h.topicLabelsEn, isEmpty);
      expect(h.topicLabelsFor('ar'), isEmpty);
    });

    test('topicLabels legacy getter returns Arabic for backwards compat', () {
      final jsonAr = {
        'title': 'a',
        'hadith': 'b',
        'description': 'c',
        'topic_ids': ['intention'],
        'topics': ['النية'],
      };
      final jsonEn = {
        'title': 'a',
        'hadith': 'b',
        'description': 'c',
        'topic_ids': ['intention'],
        'topics': ['Intention'],
      };
      final h = Hadith.fromJson(jsonAr, jsonEn);
      expect(h.topicLabels, ['النية']);
    });
  });
}
