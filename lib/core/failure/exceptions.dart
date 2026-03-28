class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}

class NotFoundException implements Exception {
  final String? message;
  NotFoundException([this.message]);
}

class NoNetworkException implements Exception {}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = "An unexpected errror occured"]);
}

class InvalidInputException implements Exception {}

class InvalidArgException implements Exception {}
