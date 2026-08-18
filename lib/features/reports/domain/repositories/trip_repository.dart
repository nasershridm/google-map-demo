import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

abstract class TripRepository {
  /// Fetches all trips from local persistence ordered by startTime descending.
  Future<List<Trip>> getTrips();

  /// Fetches a specific trip by its ID including its location points.
  Future<Trip?> getTripById(String id);

  /// Saves or creates a new trip.
  Future<void> saveTrip(Trip trip);

  /// Updates an existing trip (e.g. completion, distance, duration).
  Future<void> updateTrip(Trip trip);

  /// Deletes a trip and its associated location points.
  Future<void> deleteTrip(String id);

  /// Inserts a new recorded location point for a trip.
  Future<void> saveLocationPoint(LocationPoint point);

  /// Retrieves all location points recorded for a given trip ID.
  Future<List<LocationPoint>> getPointsForTrip(String tripId);

  /// Fetches summary metrics (total trips, total distance, total duration).
  Future<Map<String, dynamic>> getDashboardMetrics();

  /// Submits an incident report (Police, Accident, Traffic).
  Future<void> submitIncidentReport(IncidentReport report);

  /// Fetches all recorded incident reports.
  Future<List<IncidentReport>> getIncidentReports();

  /// Fetches recorded incident reports associated with a specific trip.
  Future<List<IncidentReport>> getIncidentReportsForTrip(String tripId);

  /// Deletes an incident report by ID.
  Future<void> deleteIncidentReport(int id);
}
