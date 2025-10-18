import 'dart:async';

import 'package:flutter/material.dart';

import 'idle_route.dart';
import 'idle_view.dart';

/// Controller for the idle screen that manages state and business logic.
///
/// Extends `State<IdleRoute>` to provide state management capabilities and serves as the bridge between the route and
/// view components. Manages the animated background and the digital clock.
class IdleController extends State<IdleRoute> {
  /// A timer that updates the screen every second to refresh the clock.
  late final Timer timer;

  /// The current date and time, updated every second.
  late DateTime now;

  @override
  void initState() {
    // Initialize clock timer
    _initializeClockTimer();

    super.initState();
  }

  /// Initializes the timer used for the clock displayed on this screen.
  void _initializeClockTimer() {
    now = DateTime.now();

    // Tick the clock once per second.
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  /// Called when any part of the idle screen is tapped.
  void onTap() => _dismissIdleScreen();

  // TODO(Toglefritz): listen for user identification or wake word events

  /// Resumes the normal activity of the Staccato dashboard app.
  ///
  /// This [IdleRoute] is presented when no interaction has occurred with the Staccato dashboard app for a period
  /// of time. "Interaction" occurs under several conditions including when the user taps on the screen, when the
  /// user identification module notifies the app of the presence of a user, or when a voice wake word is uttered
  /// and detected by the system. If any of these interactions occur, this idle screen will be dismissed.
  void _dismissIdleScreen() {
    // Simply pop back to the previous screen.
    Navigator.of(context).pop();
  }

  /// Builds the widget tree for the idle screen.
  ///
  /// Returns an [IdleView] instance, passing `this` controller to it.
  @override
  Widget build(BuildContext context) => IdleView(this);

  /// Disposes the resources used by the controller.
  ///
  /// This method cancels the timer and disposes the animation controller to prevent memory leaks.
  @override
  void dispose() {
    // Dismiss the clock timer
    timer.cancel();

    super.dispose();
  }
}
