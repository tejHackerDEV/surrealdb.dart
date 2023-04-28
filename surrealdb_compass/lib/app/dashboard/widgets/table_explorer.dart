import 'package:flutter/material.dart' hide Colors;

import '../../res/strings.dart';
import '../../widgets/my_list_view.dart';
import '../../widgets/my_rounded_elevated_button.dart';
import '../../widgets/my_text_form_field.dart';
import 'record.dart';

typedef GetRecords = Future<Iterable<Map<String, dynamic>>> Function(
  String tableName,
);

class TableExplorer extends StatefulWidget {
  final String tableName;
  final GetRecords getRecords;
  const TableExplorer({
    Key? key,
    required this.tableName,
    required this.getRecords,
  }) : super(key: key);

  @override
  State<TableExplorer> createState() => _TableExplorerState();
}

class _TableExplorerState extends State<TableExplorer> {
  late Future<Iterable<Map<String, dynamic>>> getRecordsFuture;

  @override
  void initState() {
    super.initState();
    getRecordsFuture = widget.getRecords(widget.tableName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyTextFormField(
                hintText: Strings.where,
                maxLines: 10,
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 16.0),
            MyRoundedElevatedButton(
              Strings.select,
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: FutureBuilder(
              future: getRecordsFuture,
              builder: (_, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                    if (!snapshot.hasData) {
                      return Text(snapshot.error.toString());
                    }
                    final records = snapshot.data!;
                    return MyListView(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 8.0,
                      ),
                      itemBuilder: (_, index) => Record(
                        json: records.elementAt(index),
                      ),
                    );
                }
              }),
        ),
      ],
    );
  }
}
