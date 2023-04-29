import 'package:flutter/material.dart' hide Colors;

import '../../res/colors.dart';
import '../../res/strings.dart';
import '../../widgets/animations/scaling_animation.dart';
import '../../widgets/my_rounded_elevated_button.dart';
import '../../widgets/my_text_form_field.dart';
import 'record.dart';

typedef GetRecords = Future<Iterable<Map<String, dynamic>>> Function(
  String tableName, {
  String? whereClause,
});
typedef DeleteRecordByThing = Future Function(String thing);

class TableExplorer extends StatefulWidget {
  final String tableName;
  final GetRecords getRecords;
  final DeleteRecordByThing onDeleteRecordByThing;
  const TableExplorer({
    Key? key,
    required this.tableName,
    required this.getRecords,
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

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _whereClauseTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    // key should be changed everytime to force the
    // widget to re-render otherwise even through
    // we get latest records list will show the previous ones
    _animatedListKey = GlobalKey();
    String? whereClause = _whereClauseTextEditingController.text.trim();
    if (whereClause.isEmpty) {
      whereClause = null;
    }
    _isLoaded = false;
    if (mounted) {
      setState(() {});
    }
    await widget
        .getRecords(widget.tableName, whereClause: whereClause)
        .then((value) {
      _records = value.toList();
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
          InkWell(
            onTap: () => widget
                .onDeleteRecordByThing(
              recordJson['id'],
            )
                .then((_) {
              _records!.removeAt(index);
              _animatedListKey.currentState!.removeItem(
                index,
                (context, animation) => _buildRecord(
                  index,
                  animation,
                  recordJson,
                ),
              );
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.delete,
                size: 14.0,
              ),
            ),
          ),
        ],
      );

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
              onTap: _loadRecords,
            ),
          ],
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
