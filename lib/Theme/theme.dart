import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Color kPrimaryColor = Color(0xFF1976D2);
const Color kSecondaryColor = Color(0xFFF9A825);
const Color kErrorColor = Colors.redAccent;
const Color kBackgroundLight = Color(0xFFF8F9FB);
const Color kBackgroundDark = Color(0xFF121212);
const Color kSurfaceLight = Colors.white;
const Color kSurfaceDark = Color(0xFF1E1E2C);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.light,
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    error: kErrorColor,
    surface: kSurfaceLight,
  ),
  scaffoldBackgroundColor: kBackgroundLight,
  textTheme: GoogleFonts.ptSansTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: kSecondaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);