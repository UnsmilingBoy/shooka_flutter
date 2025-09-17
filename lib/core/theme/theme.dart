import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[800],
    scaffoldBackgroundColor: Colors.white,
    hintColor: Colors.grey,
    colorScheme: ColorScheme.light(
      primary: Colors.blue[800]!,
      secondary: Colors.amber[500]!,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.black, // controls icons & title color
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.vazirmatnTextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1565C0),
    scaffoldBackgroundColor: Color.fromARGB(255, 24, 27, 41),

    colorScheme: ColorScheme.dark(
      primary: Colors.blue[800]!,
      secondary: Colors.amber[900]!,
      surface: Color.fromARGB(255, 35, 39, 58),
      error: Colors.red.shade900,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 24, 27, 41),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.vazirmatn(
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: TextTheme(
      // Display
      displayLarge: GoogleFonts.vazirmatn(
        fontSize: 57,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.vazirmatn(
        fontSize: 45,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.vazirmatn(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),

      // Headline
      headlineLarge: GoogleFonts.vazirmatn(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),

      // Title
      titleLarge: GoogleFonts.vazirmatn(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.vazirmatn(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
      ),

      // Label
      labelLarge: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.vazirmatn(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.grey,
      ),
    ),
  );
}
