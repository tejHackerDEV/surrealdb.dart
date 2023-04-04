enum PatchOp {
  add,
  remove,
  replace,
  change,
}

class JsonPatch {
  /// Specifies the operation to be performed on the [path]
  final PatchOp _op;

  /// Specifies the path on which the [_op] to be performed
  final String path;

  /// Value that will be used while performing the [_op]
  /// on the [path] if required
  final dynamic value;

  JsonPatch.add({
    required this.path,
    required this.value,
  }) : _op = PatchOp.add {
    _validatePath();
  }

  JsonPatch.remove({
    required this.path,
  })  : _op = PatchOp.remove,
        value = null {
    _validatePath();
  }

  JsonPatch.replace({
    required this.path,
    required this.value,
  }) : _op = PatchOp.replace {
    _validatePath();
  }

  void _validatePath() {
    if (path[0] != '/') {
      throw ArgumentError.value(path, 'path', 'Path should starts with `/`');
    }
  }

  Map<String, dynamic> toJson() => {
        "op": _op.name,
        "path": path,
        if (_op != PatchOp.remove) "value": value,
      };

  @override
  String toString() {
    return 'JsonPatch{op: $_op, path: $path, value: $value}';
  }
}
