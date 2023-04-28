import 'package:flutter/material.dart' hide Colors;

import '../../res/colors.dart';
import 'json_expansion_tile.dart';

class Record extends StatefulWidget {
  final Map<String, dynamic> json;
  const Record({Key? key, required this.json}) : super(key: key);

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.border,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _buildJson(
        widget.json,
        multiplier: 8.0,
      ),
    );
  }

  Widget _buildJson(Map<String, dynamic> json, {required double multiplier}) {
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
        return JsonExpansionTile(
          isExpandable: _isMap(entry.value) || _isIterable(entry.value),
          tilePadding: const EdgeInsets.symmetric(vertical: 4.0),
          childrenPadding: const EdgeInsets.only(left: 4.0),
          title: Row(
            children: [
              _buildKey(entry.key),
              _buildValue(entry.value, multiplier: multiplier),
            ],
          ),
          children: [
            if (_isMap(entry.value))
              _buildJson(entry.value, multiplier: multiplier),
            if (_isIterable(entry.value))
              _buildList(entry.value, multiplier: multiplier),
          ],
        );
      }),
    );
  }

  Widget _buildList(List<dynamic> list, {required double multiplier}) {
    final listJson = <String, dynamic>{};
    for (int i = 0; i < list.length; i++) {
      listJson['$i'] = list.elementAt(i);
    }
    return _buildJson(listJson, multiplier: multiplier);
  }

  Widget _buildKey(String key) => RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.primaryGradientOne,
            fontWeight: FontWeight.w600,
          ),
          text: key,
          children: const [
            TextSpan(
              text: ' :',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  Widget _buildValue(dynamic value, {required double multiplier}) {
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
      padding: EdgeInsets.only(left: multiplier),
      child: child,
    );
  }

  bool _isMap(dynamic value) => value is Map<String, dynamic>;

  bool _isIterable(dynamic value) => value is Iterable<dynamic>;

  bool _isString(dynamic value) => value is String;
}
