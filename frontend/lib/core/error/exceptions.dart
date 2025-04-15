// Core error exceptions

class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class ExpiredException implements Exception {
  final String message;
  
  ExpiredException(this.message);
  
  @override
  String toString() => 'ExpiredException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}