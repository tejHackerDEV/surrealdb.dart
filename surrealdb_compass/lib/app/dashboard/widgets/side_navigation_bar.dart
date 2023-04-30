import 'package:flutter/material.dart' hide Colors, Table;

import '../../../domain/entities/info/helpers/table.dart';
import '../../constants.dart';
import '../../res/assets.dart';
import '../../res/colors.dart';
import '../../res/strings.dart';
import '../../widgets/my_icon_button.dart';
import '../../widgets/my_list_tile.dart';
import '../../widgets/my_list_view.dart';
import '../../widgets/my_text_form_field.dart';

typedef TablesCallback = Future<Iterable<Table>> Function();

class SideNavigationBar extends StatefulWidget {
  final ValueChanged<Table> onTableSelected;
  final TablesCallback onTablesRefresh;
  const SideNavigationBar({
    Key? key,
    required this.onTableSelected,
    required this.onTablesRefresh,
  }) : super(key: key);

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  /// Holds the tables that were present in the db
  Iterable<Table>? _tables;

  /// Holds any error that occurs while loading the tables
  Object? _tablesError;

  /// Check this variable before accessing [_tables] or [_tablesError]
  /// as they will be populated correctly only after this returns true
  final _isLoaded = ValueNotifier(false);

  final _filteredTables = ValueNotifier<Iterable<Table>>([]);
  final _selectedTable = ValueNotifier<Table?>(null);

  final _filterTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _filterTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    _isLoaded.value = false;
    await widget.onTablesRefresh().then((value) {
      _tables = value;
      _tablesError = null; // reset error value in case of success result
    }).catchError((error) {
      _tablesError = error;
      _tables = null; // reset success value in case of error result
    }).whenComplete(() {
      _filterTables();
      _isLoaded.value = true;
    });
  }

  void _filterTables() {
    if (_filterTextEditingController.text.isEmpty) {
      _filteredTables.value = _tables!;
      return;
    }
    _filteredTables.value = _tables?.where(
          (table) => table.name.contains(_filterTextEditingController.text),
        ) ??
        [];
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
                child: ValueListenableBuilder(
                    valueListenable: _isLoaded,
                    builder: (_, isLoaded, __) {
                      Widget child;
                      ValueChanged<String>? onSearch;
                      if (!isLoaded) {
                        child = const SizedBox.shrink();
                      } else {
                        if (_tablesError != null) {
                          child = Center(
                            child: Text(_tablesError.toString()),
                          );
                        } else {
                          onSearch = (_) => _filterTables();

                          child = ValueListenableBuilder(
                              valueListenable: _filteredTables,
                              builder: (_, filteredTables, __) {
                                return ValueListenableBuilder(
                                    valueListenable: _selectedTable,
                                    builder: (_, selectedTable, __) =>
                                        MyListView(
                                          padding: const EdgeInsets.all(4.0),
                                          itemCount: filteredTables.length,
                                          emptyBuilder: (_) => const Text(
                                              Strings.tablesNotFound),
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(
                                            height: 8.0,
                                          ),
                                          itemBuilder: (_, index) {
                                            final table =
                                                filteredTables.elementAt(index);
                                            return MyListTile(
                                              onTap: () =>
                                                  widget.onTableSelected(
                                                _selectedTable.value = table,
                                              ),
                                              isSelected: table.name ==
                                                  selectedTable?.name,
                                              leading: Icons.grid_on_outlined,
                                              title: table.name,
                                            );
                                          },
                                        ));
                              });
                        }
                      }
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.table_chart_outlined),
                            title: const Text(Strings.tables),
                            trailing: MyIconButton(
                              Icons.refresh_outlined,
                              size: 24.0,
                              onTap: _loadTables,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          MyTextFormField(
                            controller: _filterTextEditingController,
                            hintText: Strings.search,
                            onChanged: onSearch,
                          ),
                          const SizedBox(height: 16.0),
                          Expanded(
                            child: child,
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
