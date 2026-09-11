import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, primary: const Color(0xFFD32F2F), secondary: const Color(0xFFB71C1C)),
  textTheme: GoogleFonts.oswaldTextTheme(),
  appBarTheme: const AppBarTheme(centerTitle: true),
);
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.dark, primary: const Color(0xFFEF5350)),
  textTheme: GoogleFonts.oswaldTextTheme(ThemeData.dark().textTheme),
);
