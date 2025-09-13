import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[800],
    scaffoldBackgroundColor: Colors.white,
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
    textTheme: GoogleFonts.vazirmatnTextTheme(),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue[800],
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[800]!,
      secondary: Colors.amber[500]!,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.vazirmatnTextTheme(),
  );
}
