import 'package:surrealdb_compass/utils/extensions/map.dart';

extension IterableExtension on Iterable<dynamic> {
  StringBuffer prettier({String indentation = ' ', int multiplier = 2}) {
    final buffer = StringBuffer();
    buffer.writeln('[');
    for (int i = 0; i < length; ++i) {
      final value = elementAt(i);
      buffer.write(indentation * multiplier);
      if (value is Map<String, dynamic>) {
        buffer.write(value.prettier(multiplier: multiplier + 2));
      } else if (value is Iterable<dynamic>) {
        buffer.write(value.prettier(multiplier: multiplier + 2));
      } else if (value is String) {
        buffer.write('"$value"');
      } else {
        buffer.write(value);
      }
      buffer.writeln(i == length - 1 ? '' : ',');
    }
    buffer
      ..write(indentation * (multiplier - 2))
      ..write(']');
    return buffer;
  }
}
