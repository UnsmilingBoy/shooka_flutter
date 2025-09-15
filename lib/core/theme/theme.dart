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
      secondary: Colors.amber[500]!,
      surface: Color.fromARGB(255, 35, 39, 58),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 24, 27, 41),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.vazirmatnTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
