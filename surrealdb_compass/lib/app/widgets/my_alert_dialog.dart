import 'package:flutter/material.dart' hide Colors;

import 'my_icon_button.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  const MyAlertDialog(
    this.title, {
    Key? key,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      titlePadding: const EdgeInsets.only(
        left: 24.0,
        top: 16.0,
        right: 12.0,
        bottom: 48.0,
      ),
      contentPadding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      actionsPadding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      title: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: MyIconButton(
              Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 5.0,
            child: Text(title),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(minWidth: size.width * 0.5),
        child: content,
      ),
      actions: actions,
    );
  }
}
