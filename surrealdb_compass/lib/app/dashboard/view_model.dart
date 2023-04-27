import 'package:flutter/widgets.dart' hide Table;

import '../../domain/entities/info/helpers/table.dart';
import '../../use_cases/get_db_info.dart';
import '../../use_cases/get_table_records.dart';
import '../view_model.dart';

class DashboardPageViewModel extends ViewModel {
  final GetDBInfoUseCase _getDBInfoUseCase;
  final GetTableRecordsUseCase _getTableRecordsUseCase;
  DashboardPageViewModel(
    this._getDBInfoUseCase,
    this._getTableRecordsUseCase,
  );

  final scrollController = ScrollController();

  final _isFetching = ValueNotifier(false);
  final _tables = <Table>[];
  int? _currentOpenedTableIndex;
  int? _currentHoveredOpenedTableIndex;
  final openedTables = ValueNotifier(<Table>[]);

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void getTables() {
    _isFetching.value = true;
    _getDBInfoUseCase.call().then((value) {
      _tables.clear();
      _tables.addAll(value.tables.entries.map(
        (entry) => Table(
          name: entry.key,
          query: entry.value,
        ),
      ));
    }).whenComplete(() => _isFetching.value = false);
  }

  Future<Iterable<Map<String, dynamic>>> getTableRecords(String tableName) {
    return _getTableRecordsUseCase.call(tableName);
  }

  void removeOpenedTableAt(int index) {
    call() {
      final tables = openedTables.value;
      tables.removeAt(index);
      // if tableNames are empty then
      // don't select anything
      if (tables.isEmpty) {
        _currentOpenedTableIndex = null;
        return;
      }
      // if the removed tableName index is less than
      // the selectedIndex or selectedIndex & tableName index
      // were lastIndex of then we need to decrease
      // 1 from the selectedIndex.
      if ((index < _currentOpenedTableIndex!) ||
          (tables.length == index && index == _currentOpenedTableIndex)) {
        _currentOpenedTableIndex = _currentOpenedTableIndex! - 1;
      }
      if (_currentOpenedTableIndex?.isNegative == true) {
        _currentOpenedTableIndex = null;
        return;
      }
    }

    call();
    openedTables.notifyListeners();
  }

  void addOpenedTable(
    Table table, {
    bool duplicate = false,
  }) {
    call() {
      // insert/updated the tableName at the selectedIndex
      final tables = openedTables.value;
      if (_currentOpenedTableIndex == null) {
        tables.add(table);
        _currentOpenedTableIndex = 0;
        return;
      }
      if (!duplicate) {
        tables[_currentOpenedTableIndex!] = table;
        return;
      }
      tables.add(table);
      _currentOpenedTableIndex = tables.length - 1;
    }

    call();
    openedTables.notifyListeners();
  }

  void setCurrentOpenedTableIndex(int? index) {
    _currentOpenedTableIndex = index;
    openedTables.notifyListeners();
  }

  void setCurrentHoveredOpenedTableIndex(bool isHovered, int index) {
    if (!isHovered) {
      _currentHoveredOpenedTableIndex = null;
      return;
    }
    _currentHoveredOpenedTableIndex = index;
    openedTables.notifyListeners();
  }

  ValueNotifier<bool> get isFetching => _isFetching;

  Iterable<Table> get tables => _tables;

  int? get currentOpenedTableIndex => _currentOpenedTableIndex;

  int? get currentHoveredOpenedTableIndex => _currentHoveredOpenedTableIndex;
}
