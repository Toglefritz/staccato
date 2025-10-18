import 'dart:async';

import 'package:flutter/material.dart';
import '../idle/idle_route.dart';
import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for the onboarding screen that manages state and business logic.
///
/// Extends `State<OnboardingRoute>` to provide state management capabilities and serves as the bridge between the
/// route and view components. Manages the icon selection game logic including randomization and user interactions.
class OnboardingController extends State<OnboardingRoute> {
  /// An inactivity timer used to change to the idle state after a period of inactivity.
  Timer? _inactivityTimer;

  @override
  void initState() {
    // Start a timer for switching to the idle state after a period of inactivity.
    _startIdleTimer();

    super.initState();
  }

  /// Starts a timer for switching to the idle state after a period of inactivity.
  Future<void> _startIdleTimer() async {
    _inactivityTimer = Timer(
      // TODO(Toglefritz): Investigate how long this timer should last
      const Duration(seconds: 3),
      () async {
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const IdleRoute(),
            ),
          );

          // Re-start the idle timer.
          await _startIdleTimer();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => OnboardingView(this);

  @override
  void dispose() {
    _inactivityTimer?.cancel();

    super.dispose();
  }
}
