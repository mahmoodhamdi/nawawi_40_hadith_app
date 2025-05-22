import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/strings.dart';
// If BouncingScrollWrapper is not found, comment out or remove its usage.
// import 'package:responsive_framework/bouncing_scroll_wrapper.dart';

import 'core/theme/app_theme.dart';
import 'cubit/last_read_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/theme_state.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        BlocProvider(create: (context) => LastReadCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final themeMode = AppTheme.themeTypeToMode(themeState.themeType);
          
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,

            // دعم RTL للعربية
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            builder: (context, widget) => ResponsiveBreakpoints.builder(
              child: widget!,
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
      ),
    );
  }
  }
