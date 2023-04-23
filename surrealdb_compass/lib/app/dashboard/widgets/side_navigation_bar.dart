import 'package:flutter/material.dart' hide Colors;

import '../../constants.dart';
import '../../res/assets.dart';
import '../../res/colors.dart';
import '../../res/strings.dart';
import '../../widgets/my_list_tile.dart';
import '../../widgets/my_list_view.dart';
import '../../widgets/my_text_form_field.dart';

class SideNavigationBar extends StatefulWidget {
  final ValueChanged<String> onTableSelected;
  const SideNavigationBar({
    Key? key,
    required this.onTableSelected,
  }) : super(key: key);

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  final tableNames = [
    'user',
    'profile',
    'token',
  ];
  late Iterable<String> filteredTableNames = tableNames;
  String? selectedTableName;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 12.0,
    );
    return Container(
      decoration: const BoxDecoration(
        color: Colors.navigationBackground,
        border: Border(
          right: BorderSide(color: Colors.border),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: Constants.kTopNavigationBarHeight,
            padding: padding,
            decoration: const BoxDecoration(
              color: Colors.databaseBackground,
              border: Border(
                bottom: BorderSide(color: Colors.border),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  Assets.pngs.logo,
                  width: 35.0,
                  height: 35.0,
                ),
                const SizedBox(width: 8.0),
                const Flexible(
                  child: Text(
                    'Database Name',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            // https://stackoverflow.com/a/68570066
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: padding,
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.table_chart_outlined),
                      title: Text(Strings.tables),
                      trailing: Icon(Icons.refresh_outlined),
                    ),
                    const SizedBox(height: 16.0),
                    MyTextFormField(
                      hintText: Strings.search,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredTableNames = tableNames;
                            return;
                          }
                          filteredTableNames = tableNames.where(
                            (tableName) => tableName.contains(value),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: MyListView(
                        padding: const EdgeInsets.all(4.0),
                        itemCount: filteredTableNames.length,
                        emptyBuilder: (_) => const Text(Strings.tablesNotFound),
                        separatorBuilder: (_, __) => const SizedBox(
                          height: 8.0,
                        ),
                        itemBuilder: (_, index) {
                          final tableName = filteredTableNames.elementAt(index);
                          return MyListTile(
                            onTap: () => setState(() {
                              widget.onTableSelected(
                                  selectedTableName = tableName);
                            }),
                            isSelected: tableName == selectedTableName,
                            leading: Icons.grid_on_outlined,
                            title: tableName,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
