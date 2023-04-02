import 'dart:async';

import '../entities/response.dart';

typedef EventName = String;
typedef EventMap = Map<EventName, Response?>;
typedef Listener = void Function(Response? response);

class Emitter<T extends EventMap> {
  final _events = <EventName, Set<Listener>>{};

  /// An wrapper around [once] function, which will help to
  /// consume the data as a [Future] instead as a callback as
  /// regular [once] function
  Future<Response> futureOnce(EventName eventName) {
    final completer = Completer<Response>();
    once(eventName, (arguments) {
      completer.complete(arguments);
    });
    return completer.future;
  }

  /// Adds the [listener] as a callback function for an [eventName]
  /// passed, so when ever something gets emitted via [emit] function
  /// with same [eventName], then the [listener] callback will get invoked
  /// everytime.
  void addListener(EventName eventName, Listener listener) {
    final listeners = _events.putIfAbsent(eventName, () => {});
    listeners.add(listener);
  }

  /// Removes a [listener] for a particular [eventName] added via
  /// [addListener] function. If a [listener] gets removed
  /// then it won't get invoked again, if something gets emitted
  /// with [eventName].
  ///
  /// <br>
  /// So, the [listener] should be same as the one that is passed
  /// as a listener via [on] function, otherwise nothing will happen.
  void removeListener(EventName eventName, Listener listener) {
    final listeners = _events[eventName];
    listeners?.remove(listener);
    if (listeners?.isEmpty == true) {
      _events.remove(eventName);
    }
  }

  /// Removes all listeners added to a [eventName]
  void removeListeners(EventName eventName) {
    _events.remove(eventName);
  }

  /// Works same as [addListener] function, but as [addListener] function
  /// invokes everytime, this will get invoked only one time & upon
  /// trigger one time, it will automatically calls
  /// [removeListener] function internally & removes the [listener] to
  /// stop further invocations.
  void once(EventName eventName, Listener listener) {
    void onceListener(Response? response) {
      removeListener(eventName, onceListener);
      listener.call(response);
    }

    return addListener(eventName, onceListener);
  }

  /// Emits [response] on [eventName], so all [listeners]
  /// that has been added to an [eventName] will get invoked
  /// with [response] passed into them as arguments.
  void emit(EventName eventName, Response? response) {
    final listeners = _events[eventName];
    if (listeners == null) {
      return;
    }
    for (int i = 0; i < listeners.length; ++i) {
      listeners.elementAt(i).call(response);
    }
  }
}
