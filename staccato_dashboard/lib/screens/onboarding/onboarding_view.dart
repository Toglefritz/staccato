import 'package:flutter/material.dart';
import '../../components/backgrounds/shifting_gradient.dart';
import '../../theme/insets.dart';
import 'components/custom_tabbed_card.dart';
import 'onboarding_controller.dart';

/// View widget for the onboarding screen that handles UI presentation.
///
/// This StatelessWidget receives the controller as a parameter and uses it to access state and trigger actions. The
/// view contains no business logic and is purely declarative, displaying the authentication interface with tabbed
/// navigation.
class OnboardingView extends StatelessWidget {
  /// Creates the onboarding view with the required controller.
  const OnboardingView(this.state, {super.key});

  /// Controller instance that manages state and business logic.
  ///
  /// Used to access the current authentication state and trigger form actions.
  final OnboardingController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          const ShiftingGradient(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Insets.medium),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: CustomTabbedCard(
                    controller: state,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
