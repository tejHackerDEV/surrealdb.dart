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

  /// Holds the edit state of record present at a particular index
  final _recordsInEditMode = <int, bool>{};

  final _whereClauseTextEditingController = TextEditingController();

  /// Holds the number of records that exists in the table for the
  /// current filters user has applied
  final _recordsCount = ValueNotifier<int?>(null);

  /// Holds the number of the top record that is being showing in the page
  final _currentPageRecordStartsAt = ValueNotifier<int>(0);

  /// Holds the number of the last record that is being showing in the page
  final _currentPageRecordEndsAt = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadRecords(
      start: 0,
    );
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
    required int start,
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
      start: start,
    )
        .then((value) {
      _records = value.toList();
      // increment by 1 because we display the startAt by adding 1
      _currentPageRecordStartsAt.value = start + 1;

      if (shouldUpdateRecordEndsAt) {
        if (start != 0) {
          _currentPageRecordEndsAt.value += _records!.length;
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

  void _setRecordEditMode(int index, bool value) => setState(() {
        _recordsInEditMode[index] = value;
      });

  Widget _buildRecordOptions(int index, Map<String, dynamic> recordJson) {
    Widget buildOption(IconData iconData, {required VoidCallback onTap}) =>
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
            iconData,
            size: 14.0,
            onTap: onTap,
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildOption(Icons.edit_outlined,
            onTap: () => _setRecordEditMode(
                index, !(_recordsInEditMode[index] ?? false))),
        const SizedBox(width: 12.0),
        buildOption(
          Icons.delete,
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
      ],
    );
  }

  Widget _buildRecordEditStatButtons(
    String text, {
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) =>
      MyRoundedElevatedButton(
        text,
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        fontSize: 12.0,
        isPrimary: isPrimary,
        onTap: onTap,
      );

  Widget _buildRecord(
    int index,
    Animation<double> animation,
    Map<String, dynamic> recordJson,
  ) {
    bool isInEditMode = _recordsInEditMode[index] ?? false;
    const borderRadiusValue = 8.0;
    return VerticalScalingAnimatedWidget(
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
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(borderRadiusValue),
                  bottom: isInEditMode
                      ? Radius.zero
                      : const Radius.circular(borderRadiusValue),
                ),
              ),
              child: Stack(
                children: [
                  Record(
                    recordJson,
                  ),
                  if (_hoveredIndex == index)
                    _buildRecordOptions(index, recordJson),
                ],
              ),
            ),
          ),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 250),
            tween: Tween<double>(begin: 0.0, end: !isInEditMode ? 0.0 : 1.0),
            builder: (context, value, child) {
              return VerticalScalingWidget(
                value: value,
                child: child!,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.border.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(borderRadiusValue),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildRecordEditStatButtons(Strings.cancel, onTap: () {
                    _setRecordEditMode(index, false);
                  }),
                  const SizedBox(width: 16.0),
                  _buildRecordEditStatButtons(
                    Strings.update,
                    isPrimary: true,
                    onTap: null,
                  ),
                ],
              ),
            ),
          ),
          // https://github.com/flutter/flutter/issues/48226
          if (index != _records!.length - 1) const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildRecordsCount(
    int currentPageRecordStartsAt,
    int currentPageRecordEndsAt,
    int? recordsCount,
  ) {
    final stringBuffer = StringBuffer();
    VoidCallback? previousPageTap;
    VoidCallback? nextPageTap;
    if (recordsCount == null || recordsCount == 0) {
      stringBuffer.write('0 - 0 of 0');
    } else {
      stringBuffer.write(
        '$currentPageRecordStartsAt - $currentPageRecordEndsAt of $recordsCount',
      );
      // decrease by 1 because we display the startAt by adding 1
      int start = currentPageRecordStartsAt - 1;
      // if we can go back then add the call back
      if (start > 0) {
        previousPageTap = () {
          _currentPageRecordEndsAt.value =
              currentPageRecordEndsAt - _records!.length;
          _loadRecords(
            start: start - Constants.kPaginationLimit,
            shouldUpdateRecordEndsAt: false,
          );
        };
      }
      if (currentPageRecordEndsAt < recordsCount) {
        nextPageTap = () {
          _loadRecords(
            start: start + Constants.kPaginationLimit,
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
    _currentPageRecordEndsAt.value -= by;
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
              isPrimary: true,
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              onTap: () => _loadRecords(
                start: 0,
              ),
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
                currentPageRecordStartsAt,
                currentPageRecordEndAt,
                recordsCount,
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
