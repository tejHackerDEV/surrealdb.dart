class Utils {
  static List<dynamic> generateQuery(
    String tableName, {
    String? whereClause,
    int? limit,
    int? start,
  }) {
    final result = [];
    final stringBuffer = StringBuffer(
      'SELECT * FROM type::table(\$table_name)',
    );
    if (whereClause != null) {
      stringBuffer.write(' WHERE $whereClause');
    }
    if (limit != null) {
      stringBuffer.write(' LIMIT type::int(\$limit)');
    }
    if (start != null) {
      stringBuffer.write(' START type::int(\$start)');
    }
    result.add(stringBuffer.toString());
    result.add({
      'table_name': tableName,
      'limit': limit,
      'start': start,
    });
    return result;
  }
}
