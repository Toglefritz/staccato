/// This library includes assets used for the [MaterialApp] widget at the base of the widget tree for this application.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/onboarding/onboarding_route.dart';
import 'screens/setup/setup_route.dart';

// Parts
part 'theme/staccato_app_theme.dart';

/// This library includes assets used for the [MaterialApp] widget at the base of the widget tree for this application.
class StaccatoDashboardApp extends StatelessWidget {
  /// Creates a new instance of [StaccatoDashboardApp].
  const StaccatoDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staccato',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _StaccatoAppTheme.lightThemeData,
      darkTheme: _StaccatoAppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder:
              (BuildContext context, AsyncSnapshot<User?> authStateSnapshot) {
                if (authStateSnapshot.hasData) {
                  return const SetupRoute();
                }
                return const OnboardingRoute();
              },
        ),
      ),
    );
  }
}
