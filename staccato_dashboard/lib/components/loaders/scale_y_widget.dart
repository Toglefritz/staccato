part of 'wave_loader.dart';

/// A widget that scales its child along the Y-axis.
///
/// Used in [WaveLoader] to animate the bars with a scaling effect.
class ScaleYWidget extends AnimatedWidget {
  /// Creates a [ScaleYWidget] with the given animation.
  ///
  /// The [scaleY] animation controls the vertical scaling.
  const ScaleYWidget({
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  }) : super(listenable: scaleY);

  /// The child widget that will be scaled.
  final Widget child;

  /// The alignment used when applying the scaling transformation.
  final Alignment alignment;

  /// Retrieves the scale animation.
  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scaleByDouble(1.0, scale.value, 1.0, 1.0),
      alignment: alignment,
      child: child,
    );
  }
}
