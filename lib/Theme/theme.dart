import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Color kPrimaryColor = Color(0xFF9CDBDB);
const Color kSecondaryColor = Color(0xFFF9A825);
const Color kErrorColor = Colors.redAccent;
const Color kBackgroundLight = Colors.white;
const Color kBannerColor = Color(0xFFF9F7FF);
const Color kBackgroundDark = Color(0xFF121212);
const Color kSurfaceLight = Color(0xFFF0FFFF);
const Color kSurfaceDark = Color(0xFF1E1E2C);
const Color kButtonDark = Color(0xFF1662CC);
const Color kButtonLight = Color(0xFF4A90E2);
const Color kTextFormFill = Color(0xFF8f8e8e);



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