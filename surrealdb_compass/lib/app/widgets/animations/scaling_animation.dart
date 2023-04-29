import 'dart:math' as math;

import 'package:flutter/material.dart' hide Colors;

class VerticalScalingAnimation extends AnimatedWidget {
  final Animation<double> value;
  final Widget child;
  final bool shouldAnimateOpacity;

  const VerticalScalingAnimation({
    Key? key,
    required this.value,
    required this.child,
    this.shouldAnimateOpacity = true,
  }) : super(key: key, listenable: value);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Opacity(
        opacity: !shouldAnimateOpacity ? 1.0 : value.value,
        child: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          heightFactor: math.max(value.value, 0.0),
          widthFactor: null,
          child: child,
        ),
      ),
    );
  }
}

class HorizontalScalingAnimation extends AnimatedWidget {
  final Animation<double> value;
  final Widget child;
  final bool shouldAnimateOpacity;

  const HorizontalScalingAnimation({
    Key? key,
    required this.value,
    required this.child,
    this.shouldAnimateOpacity = true,
  }) : super(key: key, listenable: value);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Opacity(
        opacity: !shouldAnimateOpacity ? 1.0 : value.value,
        child: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          heightFactor: null,
          widthFactor: math.max(value.value, 0.0),
          child: child,
        ),
      ),
    );
  }
}
