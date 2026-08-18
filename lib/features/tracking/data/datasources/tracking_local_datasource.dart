import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:dndn/core/errors/exceptions.dart';
import 'package:dndn/core/services/database_helper.dart';
import 'package:dndn/features/reports/data/models/incident_report_model.dart';
import 'package:dndn/features/reports/data/models/trip_model.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';

abstract class TrackingLocalDataSource {
  Future<void> insertTrip(TripModel trip);
  Future<void> updateTrip(TripModel trip);
  Future<List<TripModel>> getAllTrips();
  Future<TripModel?> getTripById(String id);
  Future<void> deleteTrip(String id);
  Future<void> insertLocationPoint(LocationPointModel point);
  Future<List<LocationPointModel>> getPointsForTrip(String tripId);
  Future<Map<String, dynamic>> getAggregatedMetrics();
  Future<void> insertIncidentReport(IncidentReportModel report);
  Future<List<IncidentReportModel>> getAllIncidentReports();
  Future<List<IncidentReportModel>> getIncidentReportsForTrip(String tripId);
  Future<void> deleteIncidentReport(int id);
}

class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  final DatabaseHelper databaseHelper;

  TrackingLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> insertTrip(TripModel trip) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        'trips',
        trip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert trip: $e');
    }
  }

  @override
  Future<void> updateTrip(TripModel trip) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'trips',
        trip.toMap(),
        where: 'id = ?',
        whereArgs: [trip.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update trip: $e');
    }
  }

  @override
  Future<List<TripModel>> getAllTrips() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query('trips', orderBy: 'start_time DESC');
      return results.map((map) => TripModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to query trips: $e');
    }
  }

  @override
  Future<TripModel?> getTripById(String id) async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        'trips',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final points = await getPointsForTrip(id);
      return TripModel.fromMap(results.first, points: points);
    } catch (e) {
      throw DatabaseException('Failed to get trip by id: $e');
    }
  }

  @override
  Future<void> deleteTrip(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete('trips', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete trip: $e');
    }
  }

  @override
  Future<void> insertLocationPoint(LocationPointModel point) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        'location_points',
        point.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Increment trip point count and update distance
      await db.rawUpdate(
        '''
        UPDATE trips 
        SET point_count = point_count + 1 
        WHERE id = ?
      ''',
        [point.tripId],
      );
    } catch (e) {
      throw DatabaseException('Failed to insert location point: $e');
    }
  }

  @override
  Future<List<LocationPointModel>> getPointsForTrip(String tripId) async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        'location_points',
        where: 'trip_id = ?',
        whereArgs: [tripId],
        orderBy: 'timestamp ASC',
      );
      return results.map((map) => LocationPointModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to query location points: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAggregatedMetrics() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_trips,
          COALESCE(SUM(total_distance), 0.0) as total_distance_meters,
          COALESCE(SUM(duration_seconds), 0) as total_duration_seconds,
          COALESCE(MAX(max_speed), 0.0) as max_speed_kmh
        FROM trips
      ''');

      if (result.isNotEmpty) {
        return {
          'totalTrips': result.first['total_trips'] as int? ?? 0,
          'totalDistanceMeters':
              (result.first['total_distance_meters'] as num?)?.toDouble() ??
              0.0,
          'totalDurationSeconds':
              result.first['total_duration_seconds'] as int? ?? 0,
          'maxSpeedKmh':
              (result.first['max_speed_kmh'] as num?)?.toDouble() ?? 0.0,
        };
      }
      return {
        'totalTrips': 0,
        'totalDistanceMeters': 0.0,
        'totalDurationSeconds': 0,
        'maxSpeedKmh': 0.0,
      };
    } catch (e) {
      throw DatabaseException('Failed to get aggregated metrics: $e');
    }
  }

  @override
  Future<void> insertIncidentReport(IncidentReportModel report) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        'incident_reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert incident report: $e');
    }
  }

  @override
  Future<List<IncidentReportModel>> getAllIncidentReports() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        'incident_reports',
        orderBy: 'timestamp DESC',
      );
      return results.map((m) => IncidentReportModel.fromMap(m)).toList();
    } catch (e) {
      throw DatabaseException('Failed to query incident reports: $e');
    }
  }

  @override
  Future<List<IncidentReportModel>> getIncidentReportsForTrip(String tripId) async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        'incident_reports',
        where: 'trip_id = ?',
        whereArgs: [tripId],
        orderBy: 'timestamp ASC',
      );
      return results.map((m) => IncidentReportModel.fromMap(m)).toList();
    } catch (e) {
      throw DatabaseException('Failed to query incident reports for trip $tripId: $e');
    }
  }

  @override
  Future<void> deleteIncidentReport(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete('incident_reports', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete incident report: $e');
    }
  }
}
