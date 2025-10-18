import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'onboarding_controller.dart';

/// View widget for the onboarding screen that handles UI presentation.
///
/// This StatelessWidget receives the controller as a parameter and uses it to access state and trigger actions. The
/// view contains no business logic and is purely declarative, displaying the icon selection game interface.
class OnboardingView extends StatelessWidget {
  /// Creates the onboarding view with the required controller.
  const OnboardingView(this.state, {super.key});

  /// Controller instance that manages state and business logic.
  ///
  /// Used to access the current game state and trigger icon selection actions.
  final OnboardingController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.welcome),
      ),
      body: Center(
        child: Image.network(
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExcGN3aHVndno3YXRrczB5bGJvd3JqbTB6aWl1OHE0cDNwcHpmdXBxZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/YeRz5g1sHuCGEGvdNs/giphy.gif',
        ),
      ),
    );
  }
}
