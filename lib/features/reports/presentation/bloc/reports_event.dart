import 'package:equatable/equatable.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripsEvent extends ReportsEvent {
  const LoadTripsEvent();
}

class LoadTripDetailsEvent extends ReportsEvent {
  final String tripId;
  const LoadTripDetailsEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class DeleteTripEvent extends ReportsEvent {
  final String tripId;
  const DeleteTripEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class LoadDashboardMetricsEvent extends ReportsEvent {
  const LoadDashboardMetricsEvent();
}

// ── Incident Report Events ────────────────────────────────────────────────────
class LoadIncidentReportsEvent extends ReportsEvent {
  const LoadIncidentReportsEvent();
}

class SubmitIncidentReportEvent extends ReportsEvent {
  final IncidentReport report;
  const SubmitIncidentReportEvent(this.report);

  @override
  List<Object?> get props => [report];
}

class DeleteIncidentReportEvent extends ReportsEvent {
  final int id;
  const DeleteIncidentReportEvent(this.id);

  @override
  List<Object?> get props => [id];
}
