import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/scheduler.dart';

import '../constants.dart';
import '../res/colors.dart';
import '../widgets/my_icon_button.dart';
import 'widgets/side_navigation_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final scrollController = ScrollController();
  List<String> tableNames = [];
  int? selectedIndex;
  int? hoveredIndex;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SideNavigationBar(
              onTableSelected: (tableName) => setState(() {
                // insert/updated the tableName at the selectedIndex
                if (selectedIndex == null) {
                  tableNames.add(tableName);
                  selectedIndex = 0;
                  return;
                }
                tableNames[selectedIndex!] = tableName;
              }),
            ),
          ),
          Expanded(
            flex: 4,
            child: tableNames.isEmpty
                ? Container()
                : Column(
                    children: [
                      Container(
                        height: Constants.kTopNavigationBarHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.border),
                          ),
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          controller: scrollController,
                          children: [
                            ...List.generate(tableNames.length, (index) {
                              return _buildTable(
                                index: index,
                                tableName: tableNames.elementAt(index),
                                isHovered: hoveredIndex == index,
                                isSelected: selectedIndex == index,
                              );
                            }),
                            const SizedBox(width: 12.0),
                            Align(
                              alignment: const Alignment(0, -0.1),
                              child: MyIconButton(
                                onTap: () => setState(() {
                                  tableNames.add(
                                    tableNames.elementAt(selectedIndex!),
                                  );
                                  selectedIndex = tableNames.length - 1;
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      curve: Curves.easeOut,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    );
                                  });
                                }),
                                icon: Icons.add_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable({
    required int index,
    required String tableName,
    required bool isHovered,
    required bool isSelected,
  }) {
    double closeIconOpacity = 0.0;
    BorderSide bottomSide = BorderSide.none;
    Color? leadingIconColor;
    Color? textColor;
    if (isHovered) {
      closeIconOpacity = 1.0;
      bottomSide = const BorderSide(
        color: Colors.primaryGradientOne,
        width: 0.5,
      );
      leadingIconColor = Colors.primaryGradientOne;
      textColor = Colors.primaryGradientOne;
    }
    if (isSelected) {
      bottomSide = const BorderSide(
        color: Colors.primaryGradientOne,
        width: 3.0,
      );
      leadingIconColor = Colors.primaryGradientOne;
      textColor = Colors.white;
    }
    return InkWell(
      onTap: () => setState(() {
        selectedIndex = index;
      }),
      onHover: (value) => setState(() {
        if (!value) {
          hoveredIndex = null;
          return;
        }
        hoveredIndex = index;
      }),
      child: Container(
        width: 175.0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
          border: Border(
            right: const BorderSide(
              color: Colors.border,
            ),
            bottom: bottomSide,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.grid_on_outlined,
              size: 16.0,
              color: leadingIconColor,
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text(
                tableName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            Opacity(
              opacity: closeIconOpacity,
              child: MyIconButton(
                onTap: () => setState(() {
                  tableNames.removeAt(index);
                  // if tableNames are empty then
                  // don't select anything
                  if (tableNames.isEmpty) {
                    selectedIndex = null;
                    return;
                  }
                  // if the removed tableName index is less than
                  // the selectedIndex or selectedIndex & tableName index
                  // were lastIndex of then we need to decrease
                  // 1 from the selectedIndex.
                  if ((index < selectedIndex!) ||
                      (tableNames.length == index && index == selectedIndex)) {
                    selectedIndex = selectedIndex! - 1;
                  }
                  if (selectedIndex?.isNegative == true) {
                    selectedIndex = null;
                    return;
                  }
                }),
                icon: Icons.close_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
