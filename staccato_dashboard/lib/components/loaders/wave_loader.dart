library;

import 'dart:math' as math show pi, sin;

import 'package:flutter/widgets.dart';

// Parts
part 'delay_tween.dart';

part 'scale_y_widget.dart';

part 'wave_loader_type.dart';

/// A customizable wave-like loading animation widget.
///
/// The widget consists of multiple bars that scale up and down over time to create a "wave" effect.
class WaveLoader extends StatefulWidget {
  /// Creates a [WaveLoader] animation.
  ///
  /// Either [color] or [itemBuilder] must be specified.
  /// The [itemCount] must be at least 2.
  const WaveLoader({
    super.key,
    this.color,
    this.type = WaveLoaderType.start,
    this.size = 50.0,
    this.itemBuilder,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(
         !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
         'You should specify either an itemBuilder or a color',
       ),
       assert(itemCount >= 2, 'itemCount cannot be less than 2.');

  /// The color of the wave bars.
  ///
  /// Ignored if [itemBuilder] is provided.
  final Color? color;

  /// The number of wave bars in the animation.
  final int itemCount;

  /// The overall size of the animation.
  final double size;

  /// The animation type (start, end, or center wave effect).
  final WaveLoaderType type;

  /// A builder function to create custom wave bars.
  ///
  /// If provided, overrides the default bar appearance.
  final IndexedWidgetBuilder? itemBuilder;

  /// The duration of the animation cycle.
  final Duration duration;

  /// An optional [AnimationController] to control the animation externally.
  final AnimationController? controller;

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

/// The state of the [WaveLoader] widget.
///
/// Manages the animation controller and builds the wave animation.
class _WaveLoaderState extends State<WaveLoader> with SingleTickerProviderStateMixin {
  /// The animation controller for handling the wave animation.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // If a controller is provided, use it. Otherwise, create a new controller.
    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
  }

  /// Returns the animation delay values based on the selected wave type.
  List<double> _getAnimationDelays(int itemCount) {
    switch (widget.type) {
      case WaveLoaderType.start:
        return _startAnimationDelays(itemCount);
      case WaveLoaderType.end:
        return _endAnimationDelays(itemCount);
      case WaveLoaderType.center:
        return _centerAnimationDelays(itemCount);
    }
  }

  /// Generates animation delay values for a wave starting from the left.
  List<double> _startAnimationDelays(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 - (index * 0.1) - 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  /// Generates animation delay values for a wave starting from the right.
  List<double> _endAnimationDelays(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 + (index * 0.1) + 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  /// Generates animation delay values for a wave effect centered in the middle.
  List<double> _centerAnimationDelays(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 + (index * 0.2) + 0.2,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (int index) => -1.0 + (index * 0.2) + 0.2,
      ),
    ];
  }

  /// Builds an individual wave bar widget.
  Widget _buildItem(int index) {
    return widget.itemBuilder != null
        ? widget.itemBuilder!(context, index)
        : DecoratedBox(decoration: BoxDecoration(color: widget.color));
  }

  @override
  Widget build(BuildContext context) {
    final List<double> animationDelays = _getAnimationDelays(widget.itemCount);

    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 1.25, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(animationDelays.length, (int index) {
            return ScaleYWidget(
              scaleY: DelayTween(
                begin: 0.4,
                end: 1,
                delay: animationDelays[index],
              ).animate(_controller),
              child: SizedBox.fromSize(
                size: Size(widget.size / widget.itemCount, widget.size),
                child: _buildItem(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
