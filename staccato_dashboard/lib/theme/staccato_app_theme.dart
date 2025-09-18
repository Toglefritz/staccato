part of '../staccato_dashboard_app.dart';

/// Provides theme information for this application.
class _StaccatoAppTheme {
  /// The light theme for the dashboard app.
  static ThemeData lightThemeData = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.amber,
    ),
  );

  /// The dark theme for the dashboard app.
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.amber,
    ),
  );
}
