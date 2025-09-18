/// This library includes assets used for the [MaterialApp] widget at the
/// base of the widget tree for this application.
library;

import 'package:flutter/material.dart';
import 'screens/setup/setup_route.dart';

// Parts
part 'theme/staccato_app_theme.dart';

/// This library includes assets used for the [MaterialApp] widget at the base of the widget tree for this application.
class FamilyDashboardApp extends StatelessWidget {
  /// Creates a new instance of [FamilyDashboardApp].
  const FamilyDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staccato',
      debugShowCheckedModeBanner: false,
      theme: _StaccatoAppTheme.lightThemeData,
      darkTheme: _StaccatoAppTheme.darkTheme,
      home: const SetupRoute(),
    );
  }
}
