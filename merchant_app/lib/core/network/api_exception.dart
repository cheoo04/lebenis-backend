class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  ApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'ApiException($code): $message';
}
