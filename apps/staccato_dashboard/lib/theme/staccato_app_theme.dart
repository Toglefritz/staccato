part of '../staccato_dashboard_app.dart';

/// Provides theme information for this application.
class _StaccatoAppTheme {
  /// The primary color swatch used as the basis for building the app's color scheme.
  static const MaterialColor _primarySwatch = Colors.teal;

  /// Standard text color for the app.
  static const Color _textColor = Color(0xFF212121);

  /// Theme data for the `Card` widgets.
  static final CardThemeData _cardTheme = CardThemeData(
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    ),
  );

  /// Theme data for `TabBar` widgets.
  static const TabBarThemeData _tabBarTheme = TabBarThemeData(
    unselectedLabelColor: Colors.white30,
  );

  /// Theme data for input fields.
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primarySwatch, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: _textColor.withValues(alpha: 0.6)),
        labelStyle: const TextStyle(color: _textColor),
      );

  /// Theme data for elevated buttons.
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
        ),
      );

  /// The light theme for the dashboard app.
  static ThemeData lightThemeData = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
    ),
    cardTheme: _cardTheme.copyWith(
      color: Colors.white70,
    ),
    tabBarTheme: _tabBarTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textColor),
      bodyMedium: TextStyle(color: _textColor),
      bodySmall: TextStyle(color: _textColor),
      headlineLarge: TextStyle(color: _textColor),
      headlineMedium: TextStyle(color: _textColor),
      headlineSmall: TextStyle(color: _textColor),
      titleLarge: TextStyle(color: _textColor),
      titleMedium: TextStyle(color: _textColor),
      titleSmall: TextStyle(color: _textColor),
      labelLarge: TextStyle(color: _textColor),
      labelMedium: TextStyle(color: _textColor),
      labelSmall: TextStyle(color: _textColor),
    ),
  );

  /// The dark theme for the dashboard app.
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: _primarySwatch,
    ),
    cardTheme: _cardTheme.copyWith(
      color: Colors.white60,
    ),
    tabBarTheme: _tabBarTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textColor),
      bodyMedium: TextStyle(color: _textColor),
      bodySmall: TextStyle(color: _textColor),
      headlineLarge: TextStyle(color: _textColor),
      headlineMedium: TextStyle(color: _textColor),
      headlineSmall: TextStyle(color: _textColor),
      titleLarge: TextStyle(color: _textColor),
      titleMedium: TextStyle(color: _textColor),
      titleSmall: TextStyle(color: _textColor),
      labelLarge: TextStyle(color: _textColor),
      labelMedium: TextStyle(color: _textColor),
      labelSmall: TextStyle(color: _textColor),
    ),
  );
}
