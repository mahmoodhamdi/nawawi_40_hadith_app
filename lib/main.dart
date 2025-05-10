import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/strings.dart';
// If BouncingScrollWrapper is not found, comment out or remove its usage.
// import 'package:responsive_framework/bouncing_scroll_wrapper.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  runApp(const NawawiApp());
}

class NawawiApp extends StatefulWidget {
  const NawawiApp({super.key});

  @override
  State<NawawiApp> createState() => _NawawiAppState();
}

class _NawawiAppState extends State<NawawiApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode? mode) {
    if (mode != null) {
      setState(() => _themeMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
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

      builder:
          (context, widget) => Directionality(
            textDirection: TextDirection.rtl,
            child: ResponsiveBreakpoints.builder(
              child: widget!,
              breakpoints: [
                const Breakpoint(start: 0, end: 359, name: 'MOBILE'),
                const Breakpoint(start: 360, end: 599, name: 'MOBILE'),
                const Breakpoint(start: 600, end: 799, name: 'TABLET'),
                const Breakpoint(start: 800, end: 999, name: 'TABLET'),
                const Breakpoint(start: 1000, end: 1200, name: 'DESKTOP'),
              ],
            ),
          ),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomeScreen(onThemeChange: _changeTheme, currentTheme: _themeMode),
    );
  }
}
