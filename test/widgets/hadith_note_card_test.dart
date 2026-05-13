import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadith_nawawi_audio/cubit/language_cubit.dart';
import 'package:hadith_nawawi_audio/cubit/notes_cubit.dart';
import 'package:hadith_nawawi_audio/widgets/hadith_note_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => NotesCubit()),
      ],
      child: Scaffold(body: child),
    ),
    locale: const Locale('ar'),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows "Add note" affordance when no note exists', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const HadithNoteCard(hadithIndex: 1)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('opens edit dialog and persists a new note', (tester) async {
    await tester.pumpWidget(_harness(const HadithNoteCard(hadithIndex: 7)));
    await tester.pumpAndSettle();

    // Tap the "Add note" surface (the InkWell wrapping the Add icon).
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // The text field should be focused; enter text.
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Reflect on niyyah daily');

    // Harness locale is Arabic — the "Done" button shows as "تم"
    expect(find.text('تم'), findsOneWidget);
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();

    // The note is now displayed (markdown rendering wraps the text).
    expect(find.textContaining('Reflect on niyyah daily'), findsOneWidget);
  });

  testWidgets('renders existing note text with edit + delete icons', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'hadith_notes': '{"3":"My personal reflection"}',
    });
    await tester.pumpWidget(_harness(const HadithNoteCard(hadithIndex: 3)));
    await tester.pumpAndSettle();

    expect(find.textContaining('My personal reflection'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
