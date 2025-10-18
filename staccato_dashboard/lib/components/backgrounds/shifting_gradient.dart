import 'package:flutter/material.dart';

/// A gradient that slowly shifts colors over time.
///
/// This widget is intended to be used as a decorative background element. It implements a liear gradient between
/// color colors. Those two colors slowly shift over time.
class ShiftingGradient extends StatefulWidget {
  /// Creates a new [ShiftingGradient] widget.
  const ShiftingGradient({
    super.key,
  });

  @override
  State<ShiftingGradient> createState() => _ShiftingGradientState();
}

/// The state for the [ShiftingGradient] widget.
class _ShiftingGradientState extends State<ShiftingGradient> with SingleTickerProviderStateMixin {
  /// The animation controller for the background gradient.
  late final AnimationController animationController;

  /// The first color animation for the background gradient.
  late final Animation<Color?> colorAnimation1;

  /// The second color animation for the background gradient.
  late final Animation<Color?> colorAnimation2;

  /// Initializes the state for the idle screen.
  @override
  void initState() {
    super.initState();

    // Initialize the background gradient animation.
    _initializeAnimation();
  }

  /// Initializes the background gradient animation.
  void _initializeAnimation() {
    // Long-running controller that continuously loops.
    animationController = AnimationController(
      duration: const Duration(minutes: 3), // Slow, gentle shift
      vsync: this,
    )..repeat();

    // Color palette to travel through (loops back to the start).
    final List<Color> palette = <Color>[
      Colors.purple.shade800,
      Colors.indigo.shade700,
      Colors.blue.shade700,
      Colors.cyan.shade700,
      Colors.teal.shade700,
      Colors.green.shade700,
      Colors.lime.shade600,
      Colors.amber.shade700,
      Colors.orange.shade700,
      Colors.purple.shade800, // close the loop
    ];

    // Helper to build a smooth looping sequence across the palette.
    TweenSequence<Color?> buildSequence(List<Color> colors) {
      final List<TweenSequenceItem<Color?>> items = <TweenSequenceItem<Color?>>[];
      for (int i = 0; i < colors.length - 1; i++) {
        items.add(
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: colors[i], end: colors[i + 1]),
            weight: 1.0,
          ),
        );
      }
      return TweenSequence<Color?>(items);
    }

    // First color animates through the palette in order.
    final TweenSequence<Color?> sequence1 = buildSequence(palette);

    // Second color is phase-shifted by half the palette for a moving gradient.
    final int half = (palette.length / 2).floor();
    final List<Color> rotated = <Color>[...palette.sublist(half), ...palette.sublist(0, half)];
    final TweenSequence<Color?> sequence2 = buildSequence(rotated);

    colorAnimation1 = sequence1.animate(animationController);
    colorAnimation2 = sequence2.animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorAnimation1.value!, colorAnimation2.value!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  /// Disposes the resources used by the controller.
  ///
  /// This method cancels the timer and disposes the animation controller to prevent memory leaks.
  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }
}
