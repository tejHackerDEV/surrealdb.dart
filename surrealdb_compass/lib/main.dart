import 'package:flutter/material.dart' hide Colors;

import 'app/res/colors.dart';
import 'app/sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultThemeData = Theme.of(context);
    return MaterialApp(
      title: 'SurrealDB Compass',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.background,
        cardTheme: defaultThemeData.cardTheme.copyWith(
          elevation: 8.0,
          color: Colors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.bluePrimarySwatch,
        ),
        textTheme: defaultThemeData.textTheme.apply(
          bodyColor: Colors.textContent,
        ),
        dividerColor: Colors.divider,
        iconTheme: defaultThemeData.iconTheme.copyWith(
          color: Colors.icon,
        ),
        listTileTheme: defaultThemeData.listTileTheme.copyWith(
          iconColor: Colors.icon,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
