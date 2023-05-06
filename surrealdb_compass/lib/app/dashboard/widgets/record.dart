import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Colors;

import '../../res/colors.dart';
import 'json_expansion_tile.dart';

class Record extends StatefulWidget {
  final Map<String, dynamic> json;
  final bool inEditMode;
  final VoidCallback? onUpdated;
  const Record(
    this.json, {
    Key? key,
    this.inEditMode = false,
    this.onUpdated,
  }) : super(key: key);

  @override
  State<Record> createState() => RecordState();
}

class RecordState extends State<Record> {
  late Map<String, dynamic> _json;

  /// Holds the keys that will be clashing
  /// because of the changes user is making in editMode.
  ///
  /// We actually need to store this because we will be
  /// inserting previous value of a `key` back into the
  /// `json`, if the `key` that is being clashing is
  /// removed by the user.
  final _clashingKeys = <List<String>, dynamic>{};

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    _json = Map.of(widget.json);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Map<String, dynamic> get json => _json;

  bool _isMap(dynamic value) => value is Map<String, dynamic>;

  bool _isIterable(dynamic value) => value is Iterable<dynamic>;

  bool _isString(dynamic value) => value is String;

  Widget _buildKey(
    List<String> keys, {
    bool forList = false,
  }) {
    final key = keys.last;
    return TextFormField(
      // this key is required inorder to reset state
      // while switching between normal & edit mode
      key: ValueKey(Object.hashAll([...keys, widget.inEditMode])),
      enabled: widget.inEditMode,
      readOnly: key == 'id' || forList,
      initialValue: key,
      maxLines: 1,
      onChanged: (newKey) {
        dynamic value = _json;
        for (int i = 0; i < keys.length; ++i) {
          dynamic key = keys.elementAt(i);
          if (i != keys.length - 1) {
            // This is not the lastKey, so simply keep looping
            // by taking the value
            if (value is List) {
              value = value[int.parse(key)];
            } else {
              value = value[key];
            }
          } else {
            // This is the lastKey so check for the cases
            // we want before updating the json
            if (!value.containsKey(newKey)) {
              // as newKey doesn't contain in the value simply
              // remove from old key value & add it under new key
              value[newKey] = value.remove(key);
              // Check if the previousKey is marked as clashing one
              // or not, if yes then add it back under the previousKey as
              // we have a newKey defined for that value by the user
              // & remove it from clashingKeys.
              for (int i = _clashingKeys.length - 1; i >= 0; --i) {
                final entry = _clashingKeys.entries.elementAt(i);
                if (!listEquals(entry.key, keys)) {
                  continue;
                }
                value[entry.key.last] = _clashingKeys.remove(entry.key);
              }
            } else {
              // there is a key already matching the newKey
              // so add it as clashingKey
              _clashingKeys[[...keys]..last = newKey] = value[newKey];
              value[newKey] = value.remove(key);
            }
            keys.last = newKey;
          }
        }
        widget.onUpdated?.call();
      },
      style: const TextStyle(
        color: Colors.primaryGradientOne,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 4.0,
        ),
      ),
    );
  }

  Widget _buildValue(
    dynamic value, {
    required List<String> keys,
    required double leftPadding,
  }) {
    Widget child;
    if (_isMap(value)) {
      child = const Text(
        'Map<String, dynamic>',
        style: TextStyle(
          color: Colors.textContent,
          fontSize: 12.0,
        ),
      );
    } else if (_isIterable(value)) {
      child = const Text(
        'List<dynamic>',
        style: TextStyle(
          color: Colors.textContent,
          fontSize: 12.0,
        ),
      );
    } else if (_isString(value)) {
      child = Text(
        '"$value"',
        style: const TextStyle(
          color: Colors.recordStringValue,
        ),
      );
    } else {
      child = Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.recordValue,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: child,
    );
  }

  Widget _buildJson(
    Map<String, dynamic> json, {
    required List<String> keys,
    required double leftPadding,
    bool forList = false,
  }) {
    // https://stackoverflow.com/a/68488055
    final id = json['id'];
    if (id != null) {
      json = {
        'id': id,
        ...json,
      };
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(json.length, (index) {
        final entry = json.entries.elementAt(index);
        final updatedKeys = [
          ...keys,
          entry.key,
        ];
        return JsonExpansionTile(
          isExpandable: _isMap(entry.value) || _isIterable(entry.value),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 4.0),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: IntrinsicWidth(
                  child: _buildKey(
                    updatedKeys,
                    forList: forList,
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              _buildValue(
                entry.value,
                keys: updatedKeys,
                leftPadding: leftPadding,
              ),
            ],
          ),
          children: [
            if (_isMap(entry.value))
              _buildJson(
                entry.value,
                keys: updatedKeys,
                leftPadding: leftPadding,
              ),
            if (_isIterable(entry.value))
              _buildList(
                entry.value,
                keys: updatedKeys,
                leftPadding: leftPadding,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildList(
    List<dynamic> list, {
    required List<String> keys,
    required double leftPadding,
  }) {
    final listJson = <String, dynamic>{};
    for (int i = 0; i < list.length; i++) {
      listJson['$i'] = list.elementAt(i);
    }
    return _buildJson(
      listJson,
      keys: keys,
      leftPadding: leftPadding,
      forList: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildJson(
      _json,
      keys: List.empty(),
      leftPadding: 8.0,
    );
  }
}
