import 'package:flutter/material.dart' hide Colors;
import 'package:get_it/get_it.dart';
import 'package:surrealdb_compass/app/router/index.dart';

import 'app/res/colors.dart';
import 'data/repository.dart';

void main() {
  GetIt.instance.registerSingleton(Repository());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    final defaultThemeData = Theme.of(context);
    return MaterialApp.router(
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
      routerConfig: appRouter.config,
    );
  }
}
