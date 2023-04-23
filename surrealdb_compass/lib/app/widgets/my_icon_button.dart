import 'package:flutter/material.dart' hide Colors;

import '../res/colors.dart';

class MyIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  const MyIconButton({
    Key? key,
    required this.onTap,
    required this.icon,
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
      radius: 12.0,
      child: Icon(
        widget.icon,
        size: 16.0,
        color: !isHovered ? null : Colors.white,
      ),
    );
  }
}
