import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/language_cubit.dart';
import 'package:hadith_nawawi_audio/models/hadith.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_citation_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testCitation = HadithCitation(
  number: 1,
  narratorAr: 'عمر بن الخطاب رضي الله عنه',
  narratorEn: 'Umar ibn al-Khattab (RA)',
  collectionAr: 'البخاري ومسلم',
  collectionEn: 'al-Bukhari and Muslim',
  sunnahUrl: 'https://sunnah.com/nawawi40:1',
);

Widget _harness(Widget child, {bool arabic = true}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [BlocProvider(create: (_) => LanguageCubit())],
      child: Scaffold(body: child),
    ),
    locale: arabic ? const Locale('ar') : const Locale('en'),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders narrator + collection + URL row', (tester) async {
    await tester.pumpWidget(
      _harness(const HadithCitationCard(citation: _testCitation)),
    );
    await tester.pump();

    // The Arabic narrator + collection appear in default state
    expect(find.text('عمر بن الخطاب رضي الله عنه'), findsOneWidget);
    expect(find.text('البخاري ومسلم'), findsOneWidget);
    expect(find.text('https://sunnah.com/nawawi40:1'), findsOneWidget);
  });

  testWidgets('shows copy / link icons', (tester) async {
    await tester.pumpWidget(
      _harness(const HadithCitationCard(citation: _testCitation)),
    );
    await tester.pump();
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.byIcon(Icons.link_rounded), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets('tapping URL row copies to clipboard', (tester) async {
    final clipboard = <String, dynamic>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard['text'] = call.arguments['text'];
          }
          return null;
        });

    await tester.pumpWidget(
      _harness(const HadithCitationCard(citation: _testCitation)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(clipboard['text'], 'https://sunnah.com/nawawi40:1');
  });

  testWidgets('renders English when language is English', (tester) async {
    // The LanguageCubit reads its persisted language from the
    // 'app_language' key (not 'language' — that's a different cubit).
    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    await tester.pumpWidget(
      _harness(
        const HadithCitationCard(citation: _testCitation),
        arabic: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Umar ibn al-Khattab (RA)'), findsOneWidget);
    expect(find.text('al-Bukhari and Muslim'), findsOneWidget);
  });
}
