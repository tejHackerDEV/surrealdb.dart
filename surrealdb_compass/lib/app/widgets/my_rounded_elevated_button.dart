import 'package:flutter/material.dart' hide Colors;

import '../constants.dart';
import '../res/colors.dart';
import '../res/strings.dart';

class MyRoundedElevatedButton extends StatefulWidget {
  const MyRoundedElevatedButton({Key? key}) : super(key: key);

  @override
  State<MyRoundedElevatedButton> createState() =>
      _MyRoundedElevatedButtonState();
}

class _MyRoundedElevatedButtonState extends State<MyRoundedElevatedButton> {
  bool isInHoverState = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24.0);
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1.0, end: !isInHoverState ? 1.0 : 1.1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: Constants.kPrimaryGradient,
          boxShadow: !isInHoverState
              ? null
              : [
                  const BoxShadow(
                    color: Colors.primaryGradientOne,
                    blurRadius: 6.0,
                  )
                ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          onHover: (value) {
            setState(() {
              isInHoverState = value;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: 36.0,
              vertical: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
          child: const Text(
            Strings.connect,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
