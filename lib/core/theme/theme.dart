import 'package:flutter/material.dart';
// Use local font family declared in pubspec.yaml (assets/fonts)

class AppTheme {
  // Helper method to get font scale based on screen width
  static double getFontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 1.15; // Desktop: 30% larger
    } else if (width > 800) {
      return 1.15; // Tablet: 15% larger
    } else {
      return 1.0; // Mobile: base size
    }
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[500],
    scaffoldBackgroundColor: Colors.grey[100]!,
    hintColor: Colors.grey[600],
    colorScheme: ColorScheme.light(
      primary: Colors.blue[500]!,
      secondary: Colors.amber[700]!,
      surface: Colors.white,
      onPrimaryFixedVariant: Colors.grey[800]!,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[100]!,
      foregroundColor: Colors.black, // controls icons & title color
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    textTheme: TextTheme(
      // Display
      displayLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 57,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 45,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 36,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),

      // Headline
      headlineLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),

      // Title
      titleLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      titleSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
      ),

      // Label
      labelLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.grey,
      ),
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
      errorContainer: Colors.grey[700],
      onPrimaryFixedVariant: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 24, 27, 41),
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    textTheme: TextTheme(
      // Display
      displayLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 57,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 45,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 36,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
      ),

      // Headline
      headlineLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),

      // Title
      titleLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      titleSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body
      bodyLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
      ),

      // Label
      labelLarge: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.grey,
      ),
    ),
  );
}
