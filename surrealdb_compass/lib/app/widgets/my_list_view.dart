import 'package:flutter/material.dart' hide Colors;

class MyListView extends StatelessWidget {
  final EdgeInsets? padding;
  final int itemCount;
  final IndexedWidgetBuilder separatorBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder? emptyBuilder;
  const MyListView({
    Key? key,
    this.padding,
    required this.itemCount,
    required this.separatorBuilder,
    required this.itemBuilder,
    this.emptyBuilder,
  })  : assert(itemCount >= 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: separatorBuilder,
      itemBuilder: itemBuilder,
    );
  }
}
