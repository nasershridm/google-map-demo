import 'dart:math' as math;
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

abstract class LocationCalculator {
  static const double _earthRadiusMeters = 6371000.0;

  /// Calculates the great-circle distance between two coordinates in meters
  /// using the Haversine formula (Pure Dart, no platform dependencies).
  static double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final double dLat = _toRadians(endLatitude - startLatitude);
    final double dLon = _toRadians(endLongitude - startLongitude);

    final double lat1Rad = _toRadians(startLatitude);
    final double lat2Rad = _toRadians(endLatitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// Calculates the total distance for a list of location points in meters.
  static double calculateTotalDistanceMeters(List<LocationPoint> points) {
    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistanceMeters(
        startLatitude: points[i].latitude,
        startLongitude: points[i].longitude,
        endLatitude: points[i + 1].latitude,
        endLongitude: points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  /// Calculates average speed in km/h given total distance in meters and duration in seconds.
  static double calculateAverageSpeedKmh({
    required double distanceMeters,
    required int durationSeconds,
  }) {
    if (durationSeconds <= 0 || distanceMeters <= 0) return 0.0;
    final double speedMps = distanceMeters / durationSeconds;
    return speedMps * 3.6; // Convert m/s to km/h
  }

  static double _toRadians(double degree) => degree * (math.pi / 180.0);
}
