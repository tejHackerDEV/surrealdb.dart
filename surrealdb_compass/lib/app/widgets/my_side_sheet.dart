import 'package:flutter/material.dart' hide Colors;

import '../res/colors.dart';
import 'my_icon_button.dart';

enum SheetSide { left, right }

Future<T?> showSideSheet<T extends Object?>({
  required BuildContext context,
  required SheetSide side,
  required String title,
  required RoutePageBuilder pageBuilder,
  double? width,
  BorderRadius? borderRadius,
  bool barrierDismissible = false,
  String? barrierLabel,
  Color barrierColor = const Color(0x80000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  double elevation = 14.0,
  bool useRootNavigator = true,
  Color backgroundColor = Colors.background,
  EdgeInsets padding = const EdgeInsets.symmetric(
    vertical: 16.0,
    horizontal: 24.0,
  ),
}) {
  final Offset beginOffset;
  final Alignment alignment;
  switch (side) {
    case SheetSide.left:
      beginOffset = const Offset(-1.0, 0.0);
      alignment = Alignment.centerLeft;
      break;
    case SheetSide.right:
      beginOffset = const Offset(1.0, 0.0);
      alignment = Alignment.centerRight;
      break;
  }
  if (barrierDismissible) {
    barrierLabel ??= '';
  }
  return showGeneralDialog(
    context: context,
    barrierLabel: barrierLabel,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    useRootNavigator: useRootNavigator,
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween(
          begin: beginOffset,
          end: const Offset(0, 0),
        ).animate(animation),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      if (width == null) {
        final size = MediaQuery.of(context).size;
        if (size.width > 1024) {
          // laptop & desktop
          width = size.width * 0.3;
        } else if (size.width > 640) {
          // tablet
          width = size.width * 0.5;
        } else {
          // mobile
          width = size.width;
        }
      }
      return Align(
        alignment: alignment,
        child: Material(
          elevation: elevation,
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: Container(
            width: width,
            height: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyIconButton(
                        Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                pageBuilder(
                  context,
                  animation,
                  secondaryAnimation,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
