class ApiException implements Exception {
  final String message;
  final int? code;

  ApiException(this.message, {this.code});

  @override
  String toString() => 'ApiException($code): $message';
}
