import 'package:flutter/material.dart' hide Colors;

import 'widgets/side_navigation_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: SideNavigationBar(),
          ),
          Expanded(flex: 4, child: Container()),
        ],
      ),
    );
  }
}
