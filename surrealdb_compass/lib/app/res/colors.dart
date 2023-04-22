import 'package:flutter/material.dart' hide Colors;

class Colors {
  static const _bluePrimaryValue = 0xFF2196F3;
  static const bluePrimarySwatch = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  static const primaryGradientOne = Color(0xFFFF009E);
  static const primaryGradientTwo = Color(0xFF8700FF);
  static const background = Color(0xFF1A202D);
  static const cardBackground = Color(0xFF272E3C);
  static const divider = Color(0xFF363c4e);
  static const border = divider;
  static const navigationBackground = Color(0xFF1D1E25);

  static const textTitle = white;
  static const textContent = Color(0xFF989cad);
  static const textFieldContent = Color(0xFF02F36A);
  static const textFieldBg = Color(0xFF1D232D);

  static const icon = textContent;

  static const databaseBackground = Color(0xFF282636);
  static const listTileSelectedBackground = databaseBackground;
}
