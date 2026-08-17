import 'package:dndn/features/tracking/domain/entities/location_point.dart';
import 'package:dndn/features/tracking/domain/repositories/tracking_repository.dart';

class StartTrackingUseCase {
  final TrackingRepository repository;

  StartTrackingUseCase(this.repository);

  Future<void> call(String tripId) async {
    return repository.startTracking(tripId);
  }
}

class StopTrackingUseCase {
  final TrackingRepository repository;

  StopTrackingUseCase(this.repository);

  Future<void> call() async {
    return repository.stopTracking();
  }
}

class PauseTrackingUseCase {
  final TrackingRepository repository;

  PauseTrackingUseCase(this.repository);

  Future<void> call() async {
    return repository.pauseTracking();
  }
}

class ResumeTrackingUseCase {
  final TrackingRepository repository;

  ResumeTrackingUseCase(this.repository);

  Future<void> call() async {
    return repository.resumeTracking();
  }
}

class GetLocationStreamUseCase {
  final TrackingRepository repository;

  GetLocationStreamUseCase(this.repository);

  Stream<LocationPoint> call() {
    return repository.getLocationStream();
  }
}

class CheckLocationPermissionsUseCase {
  final TrackingRepository repository;

  CheckLocationPermissionsUseCase(this.repository);

  Future<bool> call() async {
    final hasPermission = await repository.hasPermission();
    if (!hasPermission) {
      return repository.requestPermissions();
    }
    return true;
  }
}

class GetCurrentLocationUseCase {
  final TrackingRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<LocationPoint> call() async {
    return repository.getCurrentLocation();
  }
}
