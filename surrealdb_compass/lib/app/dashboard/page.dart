import 'package:flutter/material.dart' hide Colors, Table;
import 'package:flutter/scheduler.dart';

import '../../domain/entities/info/helpers/table.dart';
import '../constants.dart';
import '../res/colors.dart';
import '../widgets/my_icon_button.dart';
import 'view_model.dart';
import 'widgets/side_navigation_bar.dart';
import 'widgets/table_explorer.dart';

class DashboardPage extends StatefulWidget {
  final DashboardPageViewModel _viewModel;
  const DashboardPage(
    this._viewModel, {
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget._viewModel;
    _viewModel.getTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _viewModel.isFetching,
        builder: (_, value, child) {
          if (value) {
            return const Center(child: CircularProgressIndicator());
          }
          return child!;
        },
        child: Row(
          children: [
            Expanded(
              child: SideNavigationBar(
                tables: _viewModel.tables,
                onTableSelected: _viewModel.addOpenedTable,
                onTablesRefresh: _viewModel.getTables,
              ),
            ),
            Expanded(
              flex: 4,
              child: ValueListenableBuilder(
                  valueListenable: _viewModel.openedTables,
                  builder: (_, openedTables, __) {
                    if (openedTables.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _viewModel.currentOpenedTableIndex,
                          builder: (_, currentOpenedTableIndex, child) {
                            return ValueListenableBuilder(
                              valueListenable:
                                  _viewModel.currentHoveredOpenedTableIndex,
                              builder:
                                  (_, currentHoveredOpenedTableIndex, __) =>
                                      _buildOpenedTableTabs(
                                openedTables,
                                currentHoveredOpenedTableIndex:
                                    currentHoveredOpenedTableIndex,
                                currentOpenedTableIndex:
                                    currentOpenedTableIndex,
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            color: Colors.navigationBackground,
                            child: ValueListenableBuilder(
                              valueListenable:
                                  _viewModel.currentOpenedTableIndex,
                              builder: (_, currentOpenedTableIndex, __) {
                                return IndexedStack(
                                  index: currentOpenedTableIndex,
                                  children: List.generate(openedTables.length,
                                      (index) {
                                    final openedTable =
                                        openedTables.elementAt(index);
                                    return TableExplorer(
                                      tableName: openedTable.name,
                                      getRecordsFuture:
                                          _viewModel.getTableRecords,
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenedTableTabs(
    Iterable<Table> openedTables, {
    int? currentHoveredOpenedTableIndex,
    int? currentOpenedTableIndex,
  }) =>
      Container(
        height: Constants.kTopNavigationBarHeight,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.border),
          ),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _viewModel.scrollController,
          children: [
            ...List.generate(openedTables.length, (index) {
              return _buildTable(
                index: index,
                tableName: openedTables.elementAt(index).name,
                isHovered: currentHoveredOpenedTableIndex == index,
                isSelected: currentOpenedTableIndex == index,
              );
            }),
            const SizedBox(width: 12.0),
            Align(
              alignment: const Alignment(0, -0.1),
              child: MyIconButton(
                onTap: () {
                  _viewModel.addOpenedTable(
                    openedTables.elementAt(
                      currentOpenedTableIndex!,
                    ),
                    duplicate: true,
                  );
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    _viewModel.scrollController.animateTo(
                      _viewModel.scrollController.position.maxScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                    );
                  });
                },
                icon: Icons.add_outlined,
              ),
            ),
          ],
        ),
      );

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
      onTap: () => _viewModel.setCurrentOpenedTableIndex(index),
      onHover: (value) =>
          _viewModel.setCurrentHoveredOpenedTableIndex(value, index),
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
                onTap: () => _viewModel.removeOpenedTableAt(index),
                icon: Icons.close_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
