import 'package:flutter_test/flutter_test.dart';
import 'package:dndn/core/utils/formatters.dart';
import 'package:dndn/core/utils/location_calculator.dart';
import 'package:dndn/features/reports/data/models/incident_report_model.dart';
import 'package:dndn/features/reports/data/models/trip_model.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

void main() {
  group('LocationCalculator Unit Tests', () {
    test('Calculates distance between two known coordinates accurately', () {
      // Cairo Citadel (30.0299, 31.2611) to Cairo Tower (30.0459, 31.2243)
      final double distance = LocationCalculator.calculateDistanceMeters(
        startLatitude: 30.0299,
        startLongitude: 31.2611,
        endLatitude: 30.0459,
        endLongitude: 31.2243,
      );

      // Distance should be approximately 3.9 km - 4.1 km (3900 - 4100 meters)
      expect(distance, greaterThan(3800));
      expect(distance, lessThan(4200));
    });

    test('Calculates total distance for a list of points', () {
      final points = [
        LocationPoint(
          tripId: 'test_trip',
          latitude: 30.0000,
          longitude: 31.0000,
          timestamp: DateTime.now(),
        ),
        LocationPoint(
          tripId: 'test_trip',
          latitude: 30.0100,
          longitude: 31.0000,
          timestamp: DateTime.now(),
        ),
        LocationPoint(
          tripId: 'test_trip',
          latitude: 30.0200,
          longitude: 31.0000,
          timestamp: DateTime.now(),
        ),
      ];

      final totalDistance = LocationCalculator.calculateTotalDistanceMeters(
        points,
      );
      expect(totalDistance, greaterThan(2000));
    });

    test('Calculates average speed correctly', () {
      // 10,000 meters in 3600 seconds = 10 km/h
      final speed = LocationCalculator.calculateAverageSpeedKmh(
        distanceMeters: 10000,
        durationSeconds: 3600,
      );
      expect(speed, closeTo(10.0, 0.01));
    });
  });

  group('AppFormatters Unit Tests', () {
    test('Formats distance in meters and kilometers correctly', () {
      expect(AppFormatters.formatDistance(350), '350 m');
      expect(AppFormatters.formatDistance(1500), '1.50 km');
    });

    test('Formats duration correctly', () {
      expect(AppFormatters.formatDuration(45), '00:45');
      expect(AppFormatters.formatDuration(125), '02:05');
      expect(AppFormatters.formatDuration(3665), '01:01:05');
    });

    test('Formats speed correctly', () {
      expect(AppFormatters.formatSpeed(15.44), '15.4 km/h');
    });
  });

  group('Serialization Tests', () {
    test('LocationPointModel serializes to and from Map accurately', () {
      final now = DateTime.now();
      final point = LocationPointModel(
        id: 1,
        tripId: 'trip_123',
        latitude: 30.0444,
        longitude: 31.2357,
        speed: 15.5,
        accuracy: 4.2,
        altitude: 20.0,
        timestamp: now,
      );

      final map = point.toMap();
      final fromMap = LocationPointModel.fromMap(map);

      expect(fromMap.tripId, point.tripId);
      expect(fromMap.latitude, point.latitude);
      expect(fromMap.longitude, point.longitude);
      expect(fromMap.speed, point.speed);
      expect(fromMap.accuracy, point.accuracy);
      expect(
        fromMap.timestamp.millisecondsSinceEpoch,
        point.timestamp.millisecondsSinceEpoch,
      );
    });

    test('TripModel serializes to and from Map accurately', () {
      final now = DateTime.now();
      final trip = TripModel(
        id: 'trip_abc',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        totalDistanceMeters: 5200.0,
        durationSeconds: 1800,
        averageSpeedKmh: 10.4,
        maxSpeedKmh: 22.0,
        pointCount: 150,
        isCompleted: true,
      );

      final map = trip.toMap();
      final fromMap = TripModel.fromMap(map);

      expect(fromMap.id, trip.id);
      expect(fromMap.totalDistanceMeters, trip.totalDistanceMeters);
      expect(fromMap.durationSeconds, trip.durationSeconds);
      expect(fromMap.averageSpeedKmh, trip.averageSpeedKmh);
      expect(fromMap.maxSpeedKmh, trip.maxSpeedKmh);
      expect(fromMap.isCompleted, true);
    });

    test('IncidentReportModel serializes to and from Map accurately with tripId', () {
      final now = DateTime.now();
      final report = IncidentReportModel(
        id: 5,
        tripId: 'trip_xyz_789',
        type: IncidentType.police,
        latitude: 30.0511,
        longitude: 31.2422,
        timestamp: now,
        notes: 'Checkpoint on highway',
      );

      final map = report.toMap();
      final fromMap = IncidentReportModel.fromMap(map);

      expect(fromMap.id, report.id);
      expect(fromMap.tripId, 'trip_xyz_789');
      expect(fromMap.type, IncidentType.police);
      expect(fromMap.latitude, 30.0511);
      expect(fromMap.longitude, 31.2422);
      expect(fromMap.notes, 'Checkpoint on highway');
      expect(
        fromMap.timestamp.millisecondsSinceEpoch,
        report.timestamp.millisecondsSinceEpoch,
      );
    });
  });
}
