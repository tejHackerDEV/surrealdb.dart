import 'package:flutter/material.dart' hide Colors;
import 'package:surrealdb_compass/app/res/colors.dart';

class MyListTile extends StatefulWidget {
  final VoidCallback onTap;
  final IconData leading;
  final String title;
  final Widget? trailing;
  final bool isSelected;
  const MyListTile({
    Key? key,
    required this.onTap,
    required this.leading,
    required this.title,
    this.trailing,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  bool isInHoverState = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(6.0);
    Color? iconColor;
    Color? titleColor;
    FontWeight? titleFontWeight;
    BoxDecoration? boxDecoration;
    if (isInHoverState || widget.isSelected) {
      iconColor = Colors.primaryGradientOne;
      titleColor = Colors.white;
      titleFontWeight = FontWeight.w600;
      boxDecoration = BoxDecoration(
        color: Colors.listTileSelectedBackground,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(2.0, 2.0),
            blurRadius: 2.0,
          ),
        ],
      );
    }
    return InkWell(
      borderRadius: borderRadius,
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          isInHoverState = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: boxDecoration,
        child: Row(
          children: [
            Icon(widget.leading, color: iconColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: titleFontWeight,
                ),
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 16.0),
              widget.trailing!
            ],
          ],
        ),
      ),
    );
  }
}
