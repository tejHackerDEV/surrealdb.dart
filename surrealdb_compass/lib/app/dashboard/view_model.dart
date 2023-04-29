import 'package:flutter/widgets.dart' hide Table;
import 'package:surrealdb_compass/utils/extensions/string.dart';

import '../../domain/entities/info/helpers/table.dart';
import '../../use_cases/delete_table_record_by_thing.dart';
import '../../use_cases/get_db_info.dart';
import '../../use_cases/get_records_count.dart';
import '../../use_cases/get_table_records.dart';
import '../view_model.dart';

class DashboardPageViewModel extends ViewModel {
  final GetDBInfoUseCase _getDBInfoUseCase;
  final GetTableRecordsUseCase _getTableRecordsUseCase;
  final GetRecordsCountUseCase _getRecordsCountUseCase;
  final DeleteTableRecordByThingUseCase _deleteTableRecordsUseCase;
  DashboardPageViewModel(
    this._getDBInfoUseCase,
    this._getTableRecordsUseCase,
    this._getRecordsCountUseCase,
    this._deleteTableRecordsUseCase,
  );

  final scrollController = ScrollController();

  final _isFetching = ValueNotifier(false);
  final _tables = <Table>[];
  final currentOpenedTableIndex = ValueNotifier<int?>(null);
  final currentHoveredOpenedTableIndex = ValueNotifier<int?>(null);
  final openedTables = ValueNotifier(<Table>[]);

  /// Stores the count of the records for a particular table
  /// <br>
  /// `key` will the tableName & `value` will be the count of the records.
  final tableRecordsCount = <String, ValueNotifier<int?>>{};

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

  Future<Iterable<Map<String, dynamic>>> getTableRecords(
    String tableName, {
    String? whereClause,
  }) {
    return _getTableRecordsUseCase.call(
      tableName,
      whereClause: whereClause,
    );
  }

  Future<int> getRecordsCount(
    String tableName, {
    String? whereClause,
  }) {
    return _getRecordsCountUseCase.call(tableName, whereClause: whereClause);
  }

  Future<void> deleteRecordByThing(String thing) {
    return _deleteTableRecordsUseCase.call(thing).then((_) {
      decreaseTableRecordCount(thing.tableName, 1);
    });
  }

  void loadTableRecordsCount(String tableName) {
    tableRecordsCount.update(tableName, (countNotifier) {
      getRecordsCount(tableName).then((value) => countNotifier.value = value);
      return countNotifier;
    }, ifAbsent: () {
      final countNotifier = ValueNotifier<int?>(null);
      getRecordsCount(tableName).then((value) => countNotifier.value = value);
      return countNotifier;
    });
  }

  void decreaseTableRecordCount(String tableName, int by) {
    final countNotifier = tableRecordsCount[tableName]!;
    countNotifier.value = countNotifier.value! - by;
  }

  void removeOpenedTableAt(int index) {
    List<Table> call() {
      final openedTables = this.openedTables.value;
      openedTables.removeAt(index);
      // if tableNames are empty then
      // don't select anything
      if (openedTables.isEmpty) {
        currentOpenedTableIndex.value = null;
        return openedTables;
      }
      // if the removed tableName index is less than
      // the selectedIndex or selectedIndex & tableName index
      // were lastIndex of then we need to decrease
      // 1 from the selectedIndex.
      if ((index < currentOpenedTableIndex.value!) ||
          (openedTables.length == index &&
              index == currentOpenedTableIndex.value)) {
        currentOpenedTableIndex.value = currentOpenedTableIndex.value! - 1;
      }
      if (currentOpenedTableIndex.value?.isNegative == true) {
        currentOpenedTableIndex.value = null;
        return openedTables;
      }
      return openedTables;
    }

    openedTables.value = [...call()];
  }

  void addOpenedTable(
    Table table, {
    bool duplicate = false,
  }) {
    List<Table> call() {
      loadTableRecordsCount(table.name);
      final tableToAdd = table.copyWith(openedAt: DateTime.now());
      final openedTables = this.openedTables.value;
      // insert/updated the tableName at the selectedIndex
      if (currentOpenedTableIndex.value == null || duplicate) {
        openedTables.add(tableToAdd);
        currentOpenedTableIndex.value = openedTables.length - 1;
        return openedTables;
      }
      openedTables[currentOpenedTableIndex.value!] = tableToAdd;
      return openedTables;
    }

    openedTables.value = [...call()];
  }

  void setCurrentOpenedTableIndex(int? index) {
    currentOpenedTableIndex.value = index;
  }

  void setCurrentHoveredOpenedTableIndex(bool isHovered, int index) {
    if (!isHovered) {
      currentHoveredOpenedTableIndex.value = null;
      return;
    }
    currentHoveredOpenedTableIndex.value = index;
  }

  ValueNotifier<bool> get isFetching => _isFetching;

  Iterable<Table> get tables => _tables;
}
