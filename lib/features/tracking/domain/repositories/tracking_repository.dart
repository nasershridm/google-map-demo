import 'package:dndn/features/tracking/domain/entities/location_point.dart';

abstract class TrackingRepository {
  /// Requests location permissions (foreground & background if needed).
  Future<bool> requestPermissions();

  /// Checks whether location service is enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Checks whether location permissions are granted.
  Future<bool> hasPermission();

  /// Starts live and background tracking for a specific tripId.
  Future<void> startTracking(String tripId);

  /// Stops tracking session.
  Future<void> stopTracking();

  /// Pauses tracking session.
  Future<void> pauseTracking();

  /// Resumes tracking session.
  Future<void> resumeTracking();

  /// Returns a stream of real-time filtered location points.
  Stream<LocationPoint> getLocationStream();

  /// Gets the current immediate location point.
  Future<LocationPoint> getCurrentLocation();

  /// Returns whether tracking is currently active.
  bool get isTracking;

  /// Returns the current active trip ID if any.
  String? get currentTripId;
}
