import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure occurred']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database Failure occurred']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location Failure occurred']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission Failure occurred']);
}

class BackgroundServiceFailure extends Failure {
  const BackgroundServiceFailure([
    super.message = 'Background Service Failure occurred',
  ]);
}
