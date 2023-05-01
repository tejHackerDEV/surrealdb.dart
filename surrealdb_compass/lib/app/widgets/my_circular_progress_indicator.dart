import 'package:flutter/material.dart' hide Colors;

import '../constants.dart';

class MyCircularProgressIndicator extends StatelessWidget {
  const MyCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Constants.kPrimaryGradient.colors.first,
      backgroundColor: Constants.kPrimaryGradient.colors.last,
    );
  }
}
