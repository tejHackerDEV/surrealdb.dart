import 'package:flutter/material.dart' hide Colors;

import '../constants.dart';
import '../res/colors.dart';
import '../res/strings.dart';

class SurrealDBText extends StatelessWidget {
  final TextStyle? style;
  const SurrealDBText({Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Strings.surreal,
          style: style,
        ),
        ShaderMask(
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
            Strings.db,
            style: TextStyle(
              fontSize: style?.fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
