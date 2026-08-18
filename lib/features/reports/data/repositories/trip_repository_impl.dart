import 'package:dndn/core/errors/exceptions.dart';
import 'package:dndn/core/services/websocket_emulator_service.dart';
import 'package:dndn/features/reports/data/models/incident_report_model.dart';
import 'package:dndn/features/reports/data/models/trip_model.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/reports/domain/repositories/trip_repository.dart';
import 'package:dndn/features/tracking/data/datasources/tracking_local_datasource.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class TripRepositoryImpl implements TripRepository {
  final TrackingLocalDataSource localDataSource;

  TripRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Trip>> getTrips() async {
    try {
      final tripModels = await localDataSource.getAllTrips();
      return tripModels.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch trips: $e');
    }
  }

  @override
  Future<Trip?> getTripById(String id) async {
    try {
      final model = await localDataSource.getTripById(id);
      return model?.toEntity();
    } catch (e) {
      throw DatabaseException('Failed to fetch trip $id: $e');
    }
  }

  @override
  Future<void> saveTrip(Trip trip) async {
    try {
      final model = TripModel.fromEntity(trip);
      await localDataSource.insertTrip(model);
    } catch (e) {
      throw DatabaseException('Failed to save trip: $e');
    }
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    try {
      final model = TripModel.fromEntity(trip);
      await localDataSource.updateTrip(model);
    } catch (e) {
      throw DatabaseException('Failed to update trip: $e');
    }
  }

  @override
  Future<void> deleteTrip(String id) async {
    try {
      await localDataSource.deleteTrip(id);
    } catch (e) {
      throw DatabaseException('Failed to delete trip $id: $e');
    }
  }

  @override
  Future<void> saveLocationPoint(LocationPoint point) async {
    try {
      final model = LocationPointModel.fromEntity(point);
      await localDataSource.insertLocationPoint(model);
    } catch (e) {
      throw DatabaseException('Failed to save location point: $e');
    }
  }

  @override
  Future<List<LocationPoint>> getPointsForTrip(String tripId) async {
    try {
      final models = await localDataSource.getPointsForTrip(tripId);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch points for trip $tripId: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      return await localDataSource.getAggregatedMetrics();
    } catch (e) {
      throw DatabaseException('Failed to fetch dashboard metrics: $e');
    }
  }

  @override
  Future<void> submitIncidentReport(IncidentReport report) async {
    try {
      final model = IncidentReportModel.fromEntity(report);
      await localDataSource.insertIncidentReport(model);
      // Simulate real-time WebSocket push
      WebSocketEmulatorService.emitIncident(report);
    } catch (e) {
      throw DatabaseException('Failed to submit incident report: $e');
    }
  }

  @override
  Future<List<IncidentReport>> getIncidentReports() async {
    try {
      final models = await localDataSource.getAllIncidentReports();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch incident reports: $e');
    }
  }

  @override
  Future<List<IncidentReport>> getIncidentReportsForTrip(String tripId) async {
    try {
      final models = await localDataSource.getIncidentReportsForTrip(tripId);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to fetch incident reports for trip $tripId: $e',
      );
    }
  }

  @override
  Future<void> deleteIncidentReport(int id) async {
    try {
      await localDataSource.deleteIncidentReport(id);
    } catch (e) {
      throw DatabaseException('Failed to delete incident report $id: $e');
    }
  }
}
