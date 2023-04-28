import 'package:flutter/material.dart' hide Colors;
import 'package:surrealdb_compass/app/widgets/gradient_text.dart';

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
        GradientText(
          Strings.db,
          fontSize: style?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
