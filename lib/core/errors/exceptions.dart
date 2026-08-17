class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server Exception']);

  @override
  String toString() => 'ServerException: $message';
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Database Exception']);

  @override
  String toString() => 'DatabaseException: $message';
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'Location Exception']);

  @override
  String toString() => 'LocationException: $message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission Exception']);

  @override
  String toString() => 'PermissionException: $message';
}

class BackgroundServiceException implements Exception {
  final String message;
  const BackgroundServiceException([
    this.message = 'Background Service Exception',
  ]);

  @override
  String toString() => 'BackgroundServiceException: $message';
}
