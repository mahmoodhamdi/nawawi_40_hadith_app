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
import 'cubit/reading_stats_cubit.dart';
import 'cubit/reminder_cubit.dart';
import 'cubit/search_history_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/theme_state.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const NawawiApp());
}

class NawawiApp extends StatefulWidget {
  const NawawiApp({super.key});

  @override
  State<NawawiApp> createState() => _NawawiAppState();
}

class _NawawiAppState extends State<NawawiApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => LastReadCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) {
          final cubit = HadithCubit();
          cubit.fetchHadiths();
          return cubit;
        }),
        BlocProvider(create: (context) => FontSizeCubit()),
        BlocProvider(create: (context) => AudioPlayerCubit()),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => ReadingStatsCubit()),
        BlocProvider(create: (context) => ReminderCubit()),
        BlocProvider(create: (context) => SearchHistoryCubit()),
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

                // Support both Arabic and English
                locale: languageState.locale,
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                ],
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
