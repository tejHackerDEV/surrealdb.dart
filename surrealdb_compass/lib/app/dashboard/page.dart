import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/scheduler.dart';

import '../constants.dart';
import '../res/colors.dart';
import '../res/strings.dart';
import '../widgets/my_icon_button.dart';
import '../widgets/my_list_view.dart';
import '../widgets/my_rounded_elevated_button.dart';
import '../widgets/my_text_form_field.dart';
import 'view_model.dart';
import 'widgets/record.dart';
import 'widgets/side_navigation_bar.dart';

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

  final json = <String, dynamic>{
    "_id": {"oid": "6444f98bf54d42670bc693dc"},
    "name": "Hey",
    "array": [1, 2, 3],
    "nestedArray": [
      1,
      2,
      3,
      {
        "name": "Hey",
        "array": [1, 2, 3]
      }
    ],
    "nested": {
      "name": "Hey",
      "array": [1, 2, 3]
    }
  };

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
                                  isHovered: _viewModel
                                          .currentHoveredOpenedTableIndex ==
                                      index,
                                  isSelected:
                                      _viewModel.currentOpenedTableIndex ==
                                          index,
                                );
                              }),
                              const SizedBox(width: 12.0),
                              Align(
                                alignment: const Alignment(0, -0.1),
                                child: MyIconButton(
                                  onTap: () {
                                    _viewModel.addOpenedTable(
                                      openedTables.elementAt(
                                        _viewModel.currentOpenedTableIndex!,
                                      ),
                                      duplicate: true,
                                    );
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((timeStamp) {
                                      _viewModel.scrollController.animateTo(
                                        _viewModel.scrollController.position
                                            .maxScrollExtent,
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
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            color: Colors.navigationBackground,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyTextFormField(
                                        hintText: Strings.where,
                                        maxLines: 10,
                                        onChanged: (value) {},
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    MyRoundedElevatedButton(
                                      Strings.select,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28.0,
                                        vertical: 16.0,
                                      ),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                Expanded(
                                  child: MyListView(
                                    itemCount: 20,
                                    separatorBuilder: (_, __) => const SizedBox(
                                      height: 8.0,
                                    ),
                                    itemBuilder: (_, __) => Record(
                                      json: json,
                                    ),
                                  ),
                                ),
                              ],
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
