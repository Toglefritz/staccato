import 'package:flutter/material.dart';
import 'onboarding_controller.dart';

/// Route widget for the onboarding screen.
///
/// Following MVC patterns, this route serves only as the entry point and delegates all logic to the
/// OnboardingController through createState().
class OnboardingRoute extends StatefulWidget {
  /// Creates the onboarding route widget.
  const OnboardingRoute({super.key});

  @override
  State<OnboardingRoute> createState() => OnboardingController();
}
