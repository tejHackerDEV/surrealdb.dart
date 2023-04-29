extension StringExtension on String {
  /// Extracts the tableName from the [thing]
  /// If the value is not of type [thing]
  /// then it may return or throw unexpected things
  String get tableName => split(':').first;
}
