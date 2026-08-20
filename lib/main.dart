import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'cubit/audio_player_cubit.dart';
import 'cubit/favorites_cubit.dart';
import 'cubit/font_size_cubit.dart';
import 'cubit/hadith_cubit.dart';
import 'cubit/language_cubit.dart';
import 'cubit/language_state.dart';
import 'cubit/last_read_cubit.dart';
import 'cubit/memorize_cubit.dart';
import 'cubit/notes_cubit.dart';
import 'cubit/quiz_cubit.dart';
import 'cubit/reading_stats_cubit.dart';
import 'cubit/reading_streaks_cubit.dart';
import 'cubit/reminder_cubit.dart';
import 'cubit/search_history_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/theme_state.dart';
import 'cubit/hadith_state.dart';
import 'screens/hadith_details_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service.
  //
  // Deliberately non-fatal: reminders are a secondary feature, and the
  // plugin can throw for reasons outside our control (a missing drawable
  // after resource shrinking, an unresolvable timezone on a device with a
  // broken clock config). Letting that propagate would mean `runApp` is
  // never reached and the user stares at the splash screen forever — which
  // is exactly what happened once. Reading hadiths must never depend on
  // notifications working.
  try {
    await NotificationService.initialize();
  } catch (e, stackTrace) {
    debugPrint('Notification init failed (reminders disabled): $e');
    debugPrint('$stackTrace');
  }

  runApp(const NawawiApp());
}

class NawawiApp extends StatefulWidget {
  const NawawiApp({super.key});

  @override
  State<NawawiApp> createState() => _NawawiAppState();
}

class _NawawiAppState extends State<NawawiApp> {
  /// Lets the notification handler push a route from outside the widget tree.
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    NotificationService.onNotificationTap = _openHadith;
    // A notification that cold-starts the app is not delivered through the
    // tap callback, so ask for it once the first frame is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _openHadith(await NotificationService.launchPayload());
    });
  }

  /// Opens the hadith a reminder points at. Silently does nothing when the
  /// payload is absent or unparseable, or when the collection has not loaded
  /// — the user then simply stays on the home screen.
  void _openHadith(String? payload) {
    final number = int.tryParse(payload ?? '');
    if (number == null) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    final hadithState = navigator.context.read<HadithCubit>().state;
    if (hadithState is! HadithLoaded) return;
    if (number < 1 || number > hadithState.hadiths.length) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => HadithDetailsScreen(
          index: number,
          hadith: hadithState.hadiths[number - 1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => LastReadCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          create: (context) {
            final cubit = HadithCubit();
            cubit.fetchHadiths();
            return cubit;
          },
        ),
        BlocProvider(create: (context) => FontSizeCubit()),
        BlocProvider(create: (context) => AudioPlayerCubit()),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => ReadingStatsCubit()),
        BlocProvider(create: (context) => ReadingStreaksCubit()),
        BlocProvider(create: (context) => ReminderCubit()),
        BlocProvider(create: (context) => SearchHistoryCubit()),
        BlocProvider(create: (context) => NotesCubit()),
        BlocProvider(create: (context) => MemorizeCubit()),
        BlocProvider(create: (context) => QuizCubit()),
      ],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final themeMode = AppTheme.themeTypeToMode(themeState.themeType);
              final l10n = AppLocalizations(languageState.language);

              return MaterialApp(
                title: l10n.appTitle,
                debugShowCheckedModeBanner: false,
                navigatorKey: _navigatorKey,

                // Support both Arabic and English
                locale: languageState.locale,
                supportedLocales: const [Locale('ar'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                builder: (context, widget) => ResponsiveBreakpoints.builder(
                  child: Directionality(
                    textDirection: languageState.textDirection,
                    child: widget!,
                  ),
                  breakpoints: [
                    const Breakpoint(start: 0, end: 359, name: 'MOBILE'),
                    const Breakpoint(start: 360, end: 599, name: 'MOBILE'),
                    const Breakpoint(start: 600, end: 799, name: 'TABLET'),
                    const Breakpoint(start: 800, end: 999, name: 'TABLET'),
                    const Breakpoint(start: 1000, end: 1200, name: 'DESKTOP'),
                  ],
                ),
                theme: AppTheme.byType(themeState.themeType),
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
