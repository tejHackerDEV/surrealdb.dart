import 'package:flutter/material.dart' hide Colors;

import '../res/colors.dart';

class MyIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final double size;
  const MyIconButton(
    this.iconData, {
    Key? key,
    required this.onTap,
    this.size = 16.0,
  }) : super(key: key);

  @override
  State<MyIconButton> createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: widget.onTap,
      onHover: (value) => setState(() {
        isHovered = value;
      }),
      hoverColor: Colors.white.withOpacity(
        0.12,
      ),
      radius: widget.size - 4,
      child: Icon(
        widget.iconData,
        size: widget.size,
        color: !isHovered ? null : Colors.white,
      ),
    );
  }
}
