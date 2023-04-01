import 'dart:async';

import '../helpers/typedefs.dart';

class Pinger {
  final Duration duration;

  Pinger([
    this.duration = const Duration(seconds: 30),
  ]);

  Timer? _timer;

  /// Starts calling the [callback] function for every
  /// `x` amount of time passed as a [duration].
  void start(VoidCallback callback) {
    stop();
    _timer = Timer(duration, callback);
  }

  /// Stops calling the callback passed via [start] function.
  void stop() {
    _timer?.cancel();
  }
}
