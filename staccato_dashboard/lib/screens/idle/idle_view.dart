import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/backgrounds/shifting_gradient.dart';
import '../../theme/insets.dart';
import 'idle_controller.dart';

/// View widget for the idle screen that handles UI presentation.
///
/// This widget displays a digital clock with an animated background, intended for when the device is idle.
class IdleView extends StatelessWidget {
  /// Creates the idle view with the required controller.
  const IdleView(this.state, {super.key});

  /// Controller instance that manages state and business logic.
  final IdleController state;

  /// Builds the widget tree for the idle view.
  ///
  /// This method constructs the UI, including the animated gradient background and the digital clock, using state
  /// from the [state].
  @override
  Widget build(BuildContext context) {
    /// The hour value (12-hour time) for the current time, with a leading zero.
    // Convert to 12-hour format, ensuring midnight = 12 and not 0.
    final int hour12 = state.now.hour % 12 == 0 ? 12 : state.now.hour % 12;
    final String hour = hour12.toString().padLeft(2, '0');

    /// The minute value for the current time, with a leading zero.
    final String minute = state.now.minute.toString().padLeft(2, '0');

    /// AM/PM indicator text.
    final String meridiem = state.now.hour >= 12 ? 'PM' : 'AM';

    return GestureDetector(
      onTap: state.onTap,
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            const ShiftingGradient(),

            // Darken the background gradient
            Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),

            // Clock
            Center(
              child: Stack(
                children: [
                  // Hours and minutes
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hour
                      Padding(
                        padding: const EdgeInsets.only(right: Insets.small),
                        child: Text(
                          hour,
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.4,
                              fontWeight: FontWeight.w900,
                              color: Colors.white70,
                            ),
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        ),
                      ),

                      // Minutes
                      Padding(
                        padding: const EdgeInsets.only(top: Insets.medium),
                        child: Text(
                          minute,
                          style: GoogleFonts.robotoFlex(
                            textStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // AM/PM
                  Positioned(
                    right: Insets.medium,
                    bottom: 44,
                    child: Text(
                      meridiem,
                      style: GoogleFonts.robotoMono(
                        textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
