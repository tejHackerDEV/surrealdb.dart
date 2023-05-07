import 'dart:async';

import 'package:flutter/material.dart' hide Colors;

import '../constants.dart';
import '../res/colors.dart';
import 'my_circular_progress_indicator.dart';

typedef ButtonCallBack = FutureOr Function();

class MyRoundedElevatedButton extends StatefulWidget {
  final String text;
  final EdgeInsets? padding;
  final ButtonCallBack? onTap;
  final bool isPrimary;
  final double fontSize;
  const MyRoundedElevatedButton(
    this.text, {
    Key? key,
    this.padding,
    required this.onTap,
    this.isPrimary = false,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  State<MyRoundedElevatedButton> createState() =>
      _MyRoundedElevatedButtonState();
}

class _MyRoundedElevatedButtonState extends State<MyRoundedElevatedButton> {
  bool _isInHoverState = false;
  bool _isLoading = false;

  bool get _shouldShowGradientBackground {
    if (widget.onTap == null) {
      return false;
    }
    return _isInHoverState || widget.isPrimary;
  }

  @override
  void didUpdateWidget(covariant MyRoundedElevatedButton oldWidget) {
    // reset hoverState if the onTap is set to null
    if (widget.onTap == null) {
      _isInHoverState = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    final borderRadius = BorderRadius.circular(24.0);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isLoading
          ? const MyCircularProgressIndicator()
          : TweenAnimationBuilder(
              duration: const Duration(milliseconds: 200),
              tween:
                  Tween<double>(begin: 1.0, end: !_isInHoverState ? 1.0 : 1.1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: !_isInHoverState
                        ? isDisabled
                            ? Colors.transparent
                            : Colors.border.withOpacity(0.5)
                        : Colors.focusedButtonOuterBorder,
                    width: !_isInHoverState ? 0.0 : 3.0,
                  ),
                  borderRadius: borderRadius,
                  color: _shouldShowGradientBackground
                      ? null
                      : Colors.unfocusedButtonBackground,
                  gradient: !_shouldShowGradientBackground
                      ? null
                      : Constants.kPrimaryGradient,
                  boxShadow: !_isInHoverState
                      ? isDisabled
                          ? null
                          : widget.isPrimary
                              ? null
                              : [
                                  const BoxShadow(
                                    color: Colors.unfocusedButtonBoxShadow,
                                    offset: Offset(0.0, -1.0),
                                    blurRadius: 1.0,
                                  ),
                                ]
                      : [
                          const BoxShadow(
                            color: Colors.focusedButtonBoxShadow1,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 20.0,
                          ),
                          const BoxShadow(
                            color: Colors.focusedButtonBoxShadow2,
                            offset: Offset(0.0, 4.0),
                            blurRadius: 12.0,
                          ),
                          const BoxShadow(
                            color: Colors.focusedButtonBoxShadow3,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 4.0,
                          ),
                          const BoxShadow(
                            color: Colors.focusedButtonBoxShadow4,
                            offset: Offset(0.0, -1.0),
                            blurRadius: 1.0,
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: isDisabled
                      ? null
                      : () async {
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            await widget.onTap!();
                          } finally {
                            _isLoading = false;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                  onHover: (value) {
                    setState(() {
                      _isInHoverState = value;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 36.0,
                          vertical: 20.0,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: borderRadius,
                    ),
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: !_shouldShowGradientBackground
                          ? isDisabled
                              ? Colors.textDisabled
                              : Colors.textContent
                          : Colors.white,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
