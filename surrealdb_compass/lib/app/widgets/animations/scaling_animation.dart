import 'dart:math' as math;

import 'package:flutter/material.dart' hide Colors;

class VerticalScalingAnimatedWidget extends AnimatedWidget {
  final Animation<double> value;
  final bool shouldAnimateOpacity;
  final Widget child;

  const VerticalScalingAnimatedWidget({
    Key? key,
    required this.value,
    this.shouldAnimateOpacity = true,
    required this.child,
  }) : super(key: key, listenable: value);

  @override
  Widget build(BuildContext context) {
    return VerticalScalingWidget(
      value: value.value,
      shouldAnimateOpacity: shouldAnimateOpacity,
      child: child,
    );
  }
}

class VerticalScalingWidget extends StatelessWidget {
  final double value;
  final Widget child;
  final bool shouldAnimateOpacity;

  const VerticalScalingWidget({
    Key? key,
    required this.value,
    required this.child,
    this.shouldAnimateOpacity = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationValue = math.max(value, 0.0);
    return ClipRect(
      child: Opacity(
        opacity: !shouldAnimateOpacity ? 1.0 : animationValue,
        child: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          heightFactor: animationValue,
          widthFactor: null,
          child: child,
        ),
      ),
    );
  }
}

class HorizontalScalingAnimatedWidget extends AnimatedWidget {
  final Animation<double> value;
  final bool shouldAnimateOpacity;
  final Widget child;

  const HorizontalScalingAnimatedWidget({
    Key? key,
    required this.value,
    this.shouldAnimateOpacity = true,
    required this.child,
  }) : super(key: key, listenable: value);

  @override
  Widget build(BuildContext context) {
    return HorizontalScalingWidget(
      value: value.value,
      shouldAnimateOpacity: shouldAnimateOpacity,
      child: child,
    );
  }
}

class HorizontalScalingWidget extends StatelessWidget {
  final double value;
  final Widget child;
  final bool shouldAnimateOpacity;

  const HorizontalScalingWidget({
    Key? key,
    required this.value,
    required this.child,
    this.shouldAnimateOpacity = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationValue = math.max(value, 0.0);
    return ClipRect(
      child: Opacity(
        opacity: !shouldAnimateOpacity ? 1.0 : animationValue,
        child: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          heightFactor: null,
          widthFactor: animationValue,
          child: child,
        ),
      ),
    );
  }
}
