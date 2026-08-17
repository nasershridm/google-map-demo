import 'package:equatable/equatable.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final List<Trip> trips;
  final Trip? selectedTrip;
  final Map<String, dynamic> dashboardMetrics;
  final List<IncidentReport> incidentReports;

  const ReportsLoaded({
    required this.trips,
    this.selectedTrip,
    this.dashboardMetrics = const {},
    this.incidentReports = const [],
  });

  ReportsLoaded copyWith({
    List<Trip>? trips,
    Trip? selectedTrip,
    Map<String, dynamic>? dashboardMetrics,
    List<IncidentReport>? incidentReports,
  }) {
    return ReportsLoaded(
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      dashboardMetrics: dashboardMetrics ?? this.dashboardMetrics,
      incidentReports: incidentReports ?? this.incidentReports,
    );
  }

  @override
  List<Object?> get props => [trips, selectedTrip, dashboardMetrics, incidentReports];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
