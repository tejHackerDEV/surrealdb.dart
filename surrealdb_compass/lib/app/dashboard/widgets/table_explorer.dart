import 'dart:math' as math;

import 'package:flutter/material.dart' hide Colors;

import '../../constants.dart';
import '../../res/colors.dart';
import '../../res/strings.dart';
import '../../widgets/animations/scaling_animation.dart';
import '../../widgets/my_icon_button.dart';
import '../../widgets/my_rounded_elevated_button.dart';
import '../../widgets/my_text_form_field.dart';
import 'record.dart';

typedef GetRecords = Future<Iterable<Map<String, dynamic>>> Function(
  String tableName, {
  String? whereClause,
  int? limit,
  int? start,
});
typedef GetRecordsCount = Future<int> Function(
  String tableName, {
  String? whereClause,
  int? limit,
  int? start,
});
typedef DeleteRecordByThing = Future Function(String thing);

class TableExplorer extends StatefulWidget {
  final String tableName;
  final GetRecords getRecords;
  final GetRecordsCount getRecordsCount;
  final DeleteRecordByThing onDeleteRecordByThing;
  const TableExplorer({
    Key? key,
    required this.tableName,
    required this.getRecords,
    required this.getRecordsCount,
    required this.onDeleteRecordByThing,
  }) : super(key: key);

  @override
  State<TableExplorer> createState() => _TableExplorerState();
}

class _TableExplorerState extends State<TableExplorer> {
  late GlobalKey<AnimatedListState> _animatedListKey;

  /// Holds the records of a particular table which are currently
  /// being showing to the user
  List<Map<String, dynamic>>? _records;

  /// Holds any error that occurs while loading the records
  Object? _recordsError;

  /// Check this variable before accessing [_records] or [_recordsError]
  /// as they will be populated correctly only after this returns true
  bool _isLoaded = false;

  /// Holds the current index of the record on which the mouse is hovered
  int? _hoveredIndex;

  final _whereClauseTextEditingController = TextEditingController();

  /// Holds the number of records that exists in the table for the
  /// current filters user has applied
  final _recordsCount = ValueNotifier<int?>(null);

  /// Holds the number of the top record that is being showing in the page
  final _currentPageRecordStartsAt = ValueNotifier<int?>(null);

  /// Holds the number of the last record that is being showing in the page
  final _currentPageRecordEndsAt = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    _loadRecords(isInitialLoad: true);
  }

  @override
  void dispose() {
    _whereClauseTextEditingController.dispose();
    super.dispose();
  }

  /// Loads the records as per the current configuration applied.
  ///
  /// <br>
  /// [isInitialLoad] should be set to `true` only if we were
  /// loading records for the first time with the current configuration
  /// or when we were force reloading the records.
  ///
  /// <br>
  /// [shouldUpdateRecordEndsAt] should be set to `false` only if
  /// we were navigating back via pagination, otherwise there will be
  /// some wrong number being displayed
  Future<void> _loadRecords({
    required bool isInitialLoad,
    bool shouldUpdateRecordEndsAt = true,
  }) async {
    _loadRecordsCount();
    // key should be changed everytime to force the
    // widget to re-render otherwise even through
    // we get latest records list will show the previous ones
    _animatedListKey = GlobalKey();
    _isLoaded = false;
    if (mounted) {
      setState(() {});
    }
    await widget
        .getRecords(
      widget.tableName,
      whereClause: _whereClause,
      limit: Constants.kPaginationLimit,
      start: math.max(0, (_currentPageRecordStartsAt.value ?? 0) - 1),
    )
        .then((value) {
      _records = value.toList();
      _currentPageRecordStartsAt.value ??= 1;
      if (shouldUpdateRecordEndsAt) {
        if (!isInitialLoad) {
          _currentPageRecordEndsAt.value =
              (_currentPageRecordEndsAt.value ?? 0) + _records!.length;
        } else {
          _currentPageRecordEndsAt.value = _records!.length;
        }
      }
      _recordsError = null; // reset error value in case of success result
    }).catchError((error) {
      _recordsError = error;
      _records = null; // reset success value in case of error result
    }).whenComplete(() {
      _isLoaded = true;
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> _loadRecordsCount() {
    _recordsCount.value = null;

    return widget
        .getRecordsCount(widget.tableName, whereClause: _whereClause)
        .then((value) => _recordsCount.value = value)
        .catchError((_) => _recordsCount.value = -1);
  }

  void _setHoveredIndex(int? index) => setState(() {
        _hoveredIndex = index;
      });

  Widget _buildRecord(
    int index,
    Animation<double> animation,
    Map<String, dynamic> recordJson,
  ) =>
      VerticalScalingAnimation(
        value: animation,
        child: Column(
          children: [
            MouseRegion(
              onEnter: (_) => _setHoveredIndex(index),
              onExit: (_) => _setHoveredIndex(null),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.border,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Record(
                      json: recordJson,
                    ),
                    if (_hoveredIndex == index)
                      _buildRecordOptions(index, recordJson),
                  ],
                ),
              ),
            ),
            // https://github.com/flutter/flutter/issues/48226
            if (index != _records!.length - 1) const SizedBox(height: 8.0),
          ],
        ),
      );

  Widget _buildRecordOptions(int index, Map<String, dynamic> recordJson) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: MyIconButton(
              Icons.delete,
              size: 14.0,
              onTap: () => widget
                  .onDeleteRecordByThing(
                recordJson['id'],
              )
                  .then((_) {
                _records!.removeAt(index);
                _decreaseRecordCount(1);
                _animatedListKey.currentState!.removeItem(
                  index,
                  (context, animation) => _buildRecord(
                    index,
                    animation,
                    recordJson,
                  ),
                );
              }),
            ),
          ),
        ],
      );

  Widget _buildRecordsCount({
    int? recordsCount,
    int? currentPageRecordStartsAt,
    int? currentPageRecordEndsAt,
  }) {
    final stringBuffer = StringBuffer();
    VoidCallback? previousPageTap;
    VoidCallback? nextPageTap;
    if (recordsCount == null || recordsCount == 0) {
      stringBuffer.write('0 - 0 of 0');
    } else {
      currentPageRecordStartsAt ??= 0;
      currentPageRecordEndsAt ??= 0;
      stringBuffer.write(
        '$currentPageRecordStartsAt - $currentPageRecordEndsAt of $recordsCount',
      );
      // if we can go back then add the call back
      if (currentPageRecordStartsAt - 1 > 0) {
        previousPageTap = () {
          _currentPageRecordStartsAt.value =
              currentPageRecordStartsAt! - Constants.kPaginationLimit;
          _currentPageRecordEndsAt.value =
              currentPageRecordEndsAt! - _records!.length;
          _loadRecords(
            isInitialLoad: false,
            shouldUpdateRecordEndsAt: false,
          );
        };
      }
      if (currentPageRecordEndsAt < recordsCount) {
        nextPageTap = () {
          _currentPageRecordStartsAt.value =
              currentPageRecordStartsAt! + Constants.kPaginationLimit;
          _loadRecords(
            isInitialLoad: false,
          );
        };
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          stringBuffer.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16.0),
        MyIconButton(
          Icons.chevron_left_outlined,
          onTap: previousPageTap,
          size: 24.0,
        ),
        const SizedBox(width: 4.0),
        MyIconButton(
          Icons.chevron_right_outlined,
          onTap: nextPageTap,
          size: 24.0,
        ),
      ],
    );
  }

  void _decreaseRecordCount(int by) {
    _recordsCount.value = _recordsCount.value! - by;
  }

  String? get _whereClause {
    String? whereClause = _whereClauseTextEditingController.text.trim();
    if (whereClause.isEmpty) {
      whereClause = null;
    }
    return whereClause;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyTextFormField(
                controller: _whereClauseTextEditingController,
                hintText: Strings.where,
                maxLines: 10,
              ),
            ),
            const SizedBox(width: 16.0),
            MyRoundedElevatedButton(
              Strings.select,
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              onTap: () => _loadRecords(isInitialLoad: true),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        ValueListenableBuilder(
          valueListenable: _recordsCount,
          builder: (_, recordsCount, __) => ValueListenableBuilder(
            valueListenable: _currentPageRecordStartsAt,
            builder: (_, currentPageRecordStartsAt, __) =>
                ValueListenableBuilder(
              valueListenable: _currentPageRecordEndsAt,
              builder: (_, currentPageRecordEndAt, __) => _buildRecordsCount(
                recordsCount: recordsCount,
                currentPageRecordStartsAt: currentPageRecordStartsAt,
                currentPageRecordEndsAt: currentPageRecordEndAt,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Builder(builder: (context) {
            if (!_isLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_recordsError != null) {
              return Center(child: Text(_recordsError.toString()));
            }
            if (_records!.isEmpty) {
              return const Center(child: Text(Strings.recordsNotFound));
            }
            return AnimatedList(
              key: _animatedListKey,
              initialItemCount: _records!.length,
              itemBuilder: (_, index, animation) => _buildRecord(
                index,
                animation,
                _records!.elementAt(index),
              ),
            );
          }),
        ),
      ],
    );
  }
}
