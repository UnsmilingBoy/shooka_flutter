import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/constants.dart';
// Use local font family declared in pubspec.yaml (assets/fonts)

/// A [PageTransitionsBuilder] that skips the page transition animation on
/// desktop (wide) screens, where the persistent sidebar makes full-page
/// transitions feel clunky, while keeping the standard animation on mobile.
class ResponsivePageTransitionsBuilder extends PageTransitionsBuilder {
  const ResponsivePageTransitionsBuilder();

  /// The default builders used by [ThemeData] per platform, replicated here so
  /// mobile keeps its original transition animation.
  static const Map<TargetPlatform, PageTransitionsBuilder> _defaults = {
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
  };

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.sizeOf(context).width >= kDesktopBreakpoint) {
      return child;
    }
    final platform = Theme.of(context).platform;
    return (_defaults[platform] ?? const ZoomPageTransitionsBuilder())
        .buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ResponsivePageTransitionsBuilder(),
        TargetPlatform.iOS: ResponsivePageTransitionsBuilder(),
        TargetPlatform.macOS: ResponsivePageTransitionsBuilder(),
        TargetPlatform.windows: ResponsivePageTransitionsBuilder(),
        TargetPlatform.linux: ResponsivePageTransitionsBuilder(),
        TargetPlatform.fuchsia: ResponsivePageTransitionsBuilder(),
      },
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ResponsivePageTransitionsBuilder(),
        TargetPlatform.iOS: ResponsivePageTransitionsBuilder(),
        TargetPlatform.macOS: ResponsivePageTransitionsBuilder(),
        TargetPlatform.windows: ResponsivePageTransitionsBuilder(),
        TargetPlatform.linux: ResponsivePageTransitionsBuilder(),
        TargetPlatform.fuchsia: ResponsivePageTransitionsBuilder(),
      },
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
