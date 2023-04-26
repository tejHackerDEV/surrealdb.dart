import 'package:flutter/material.dart' hide Colors, Table;

import '../../../domain/entities/info/helpers/table.dart';
import '../../constants.dart';
import '../../res/assets.dart';
import '../../res/colors.dart';
import '../../res/strings.dart';
import '../../widgets/my_list_tile.dart';
import '../../widgets/my_list_view.dart';
import '../../widgets/my_text_form_field.dart';

class SideNavigationBar extends StatefulWidget {
  final Iterable<Table> tables;
  final ValueChanged<Table> onTableSelected;
  const SideNavigationBar({
    Key? key,
    required this.tables,
    required this.onTableSelected,
  }) : super(key: key);

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  late Iterable<Table> tables;
  late Iterable<Table> filteredTables;
  Table? selectedTable;

  @override
  void initState() {
    super.initState();
    tables = widget.tables;
    filteredTables = tables;
  }

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
                            filteredTables = tables;
                            return;
                          }
                          filteredTables = tables.where(
                            (table) => table.name.contains(value),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: MyListView(
                        padding: const EdgeInsets.all(4.0),
                        itemCount: filteredTables.length,
                        emptyBuilder: (_) => const Text(Strings.tablesNotFound),
                        separatorBuilder: (_, __) => const SizedBox(
                          height: 8.0,
                        ),
                        itemBuilder: (_, index) {
                          final table = filteredTables.elementAt(index);
                          return MyListTile(
                            onTap: () => setState(() {
                              widget.onTableSelected(selectedTable = table);
                            }),
                            isSelected: table == selectedTable,
                            leading: Icons.grid_on_outlined,
                            title: table.name,
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
