import 'package:flutter/material.dart' hide Colors;
import 'package:gradient_borders/gradient_borders.dart';

import '../constants.dart';
import '../res/colors.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  const MyTextFormField({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    );
    return TextFormField(
      style: const TextStyle(color: Colors.textFieldContent),
      decoration: InputDecoration(
        fillColor: Colors.textFieldBg,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.textContent.withOpacity(0.4),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: GradientOutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          gradient: Constants.kPrimaryGradient,
          width: 2,
        ),
      ),
    );
  }
}
