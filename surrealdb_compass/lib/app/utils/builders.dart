import 'package:flutter/material.dart';
import 'package:surrealdb_compass/app/view_model.dart';

class AppRouteBuilder extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    dynamic viewModel,
  ) builder;

  final ViewModelBuilder? dependenciesBuilder;

  const AppRouteBuilder({
    Key? key,
    required this.builder,
    this.dependenciesBuilder,
  }) : super(key: key);

  @override
  State<AppRouteBuilder> createState() => _AppRouteBuilderState();
}

class _AppRouteBuilderState extends State<AppRouteBuilder> {
  ViewModel? viewModel;

  @override
  void initState() {
    viewModel = widget.dependenciesBuilder?.builder();
    super.initState();
  }

  @override
  void dispose() {
    viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context, viewModel);
}

abstract class ViewModelBuilder {
  ViewModel? builder();
}
