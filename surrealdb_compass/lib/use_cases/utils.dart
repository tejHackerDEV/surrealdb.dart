class Utils {
  static List<dynamic> generateQuery(
    String tableName, {
    String? whereClause,
  }) {
    final result = [];
    final stringBuffer = StringBuffer(
      'SELECT * FROM type::table(\$table_name)',
    );
    if (whereClause != null) {
      stringBuffer.write(' WHERE $whereClause');
    }
    result.add(stringBuffer.toString());
    result.add({
      'table_name': tableName,
    });
    return result;
  }
}
