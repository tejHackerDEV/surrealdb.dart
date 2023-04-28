import 'package:flutter/material.dart' hide Colors;

import '../constants.dart';
import '../res/colors.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  const GradientText(
    this.text, {
    Key? key,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (size) => Constants.kPrimaryGradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
