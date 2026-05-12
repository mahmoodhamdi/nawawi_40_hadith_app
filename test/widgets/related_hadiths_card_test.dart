import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/hadith_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/hadith_state.dart';
import 'package:hadith_nawawi_audio/cubit/language_cubit.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/widgets/related_hadiths_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal HadithCubit replacement that emits a fixed loaded state — we
/// don't want test rigs to depend on the real asset loader.
class _FixedHadithCubit extends HadithCubit {
  final List<Hadith> _fixed;
  _FixedHadithCubit(this._fixed);
  @override
  Future<void> fetchHadiths() async {
    emit(HadithLoaded(_fixed));
  }
}

Hadith _h(int idx, {required List<String> topicIds,
    required List<String> labelsAr, required String title}) {
  return Hadith(
    titleAr: title,
    titleEn: title,
    hadithAr: 'hadith $idx',
    hadithEn: 'hadith $idx',
    descriptionAr: '',
    descriptionEn: '',
    topicIds: topicIds,
    topicLabelsAr: labelsAr,
    topicLabelsEn: labelsAr,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('hides itself when current hadith has no topics',
      (tester) async {
    final current = _h(1, topicIds: const [], labelsAr: const [], title: 't1');
    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider<HadithCubit>(
            create: (_) => _FixedHadithCubit([current])..fetchHadiths(),
          ),
        ],
        child: Scaffold(
          body: RelatedHadithsCard(current: current, currentIndex: 1),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // No card content
    expect(find.text('أحاديث ذات صلة'), findsNothing);
  });

  testWidgets('shows related hadiths sorted by topic overlap',
      (tester) async {
    final h1 = _h(1,
        topicIds: ['intention', 'sincerity'],
        labelsAr: ['النية', 'الإخلاص'],
        title: 'الأعمال بالنيات');
    // h2 shares two topics → strongest related
    final h2 = _h(2,
        topicIds: ['intention', 'sincerity'],
        labelsAr: ['النية', 'الإخلاص'],
        title: 'إنما الأعمال');
    // h3 shares one topic
    final h3 = _h(3,
        topicIds: ['intention'],
        labelsAr: ['النية'],
        title: 'النية محل');
    // h4 shares nothing
    final h4 = _h(4,
        topicIds: ['anger'],
        labelsAr: ['الغضب'],
        title: 'لا تغضب');

    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider<HadithCubit>(
            create: (_) =>
                _FixedHadithCubit([h1, h2, h3, h4])..fetchHadiths(),
          ),
        ],
        child: Scaffold(
          body: RelatedHadithsCard(current: h1, currentIndex: 1),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Card title
    expect(find.text('أحاديث ذات صلة'), findsOneWidget);
    // Topic chips for current hadith
    expect(find.text('النية'), findsWidgets);
    expect(find.text('الإخلاص'), findsOneWidget);
    // Related hadiths shown: h2 and h3, but NOT h4 (no topic overlap)
    expect(find.text('إنما الأعمال'), findsOneWidget);
    expect(find.text('النية محل'), findsOneWidget);
    expect(find.text('لا تغضب'), findsNothing);
  });
}
