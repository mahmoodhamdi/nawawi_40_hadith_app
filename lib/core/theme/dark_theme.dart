import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
    titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.cairo(fontSize: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);
