import 'package:flutter/material.dart' hide Colors;
import 'package:gradient_borders/gradient_borders.dart';

import '../constants.dart';
import '../res/colors.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool autoFocus;
  const MyTextFormField({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.maxLines = 1,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    );
    return TextFormField(
      autofocus: autoFocus,
      controller: controller,
      style: const TextStyle(color: Colors.textFieldContent),
      onChanged: onChanged,
      // https://github.com/flutter/flutter/issues/116707#issuecomment-1344060320
      textInputAction:
          maxLines > 1 ? TextInputAction.none : TextInputAction.done,
      minLines: 1,
      maxLines: maxLines,
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
