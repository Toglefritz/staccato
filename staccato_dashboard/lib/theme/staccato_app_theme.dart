part of '../staccato_dashboard_app.dart';

/// Provides theme information for this application.
class _StaccatoAppTheme {
  /// The primary color swatch used as the basis for building the app's color scheme.
  static const MaterialColor _primarySwatch = Colors.teal;

  /// The light theme for the dashboard app.
  static ThemeData lightThemeData = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
    ),
  );

  /// The dark theme for the dashboard app.
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: _primarySwatch,
    ),
  );
}
