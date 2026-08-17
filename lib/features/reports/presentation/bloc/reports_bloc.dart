import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/features/reports/domain/use_cases/incident_use_cases.dart';
import 'package:dndn/features/reports/domain/use_cases/trip_use_cases.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_event.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetTripsUseCase getTripsUseCase;
  final GetTripByIdUseCase getTripByIdUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  final GetDashboardMetricsUseCase getDashboardMetricsUseCase;
  final SubmitIncidentReportUseCase submitIncidentReportUseCase;
  final GetIncidentReportsUseCase getIncidentReportsUseCase;
  final DeleteIncidentReportUseCase deleteIncidentReportUseCase;

  ReportsBloc({
    required this.getTripsUseCase,
    required this.getTripByIdUseCase,
    required this.deleteTripUseCase,
    required this.getDashboardMetricsUseCase,
    required this.submitIncidentReportUseCase,
    required this.getIncidentReportsUseCase,
    required this.deleteIncidentReportUseCase,
  }) : super(const ReportsInitial()) {
    on<LoadTripsEvent>(_onLoadTrips);
    on<LoadTripDetailsEvent>(_onLoadTripDetails);
    on<DeleteTripEvent>(_onDeleteTrip);
    on<LoadDashboardMetricsEvent>(_onLoadDashboardMetrics);
    on<LoadIncidentReportsEvent>(_onLoadIncidentReports);
    on<SubmitIncidentReportEvent>(_onSubmitIncidentReport);
    on<DeleteIncidentReportEvent>(_onDeleteIncidentReport);
  }

  Future<void> _onLoadTrips(
    LoadTripsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    try {
      final trips = await getTripsUseCase();
      final metrics = await getDashboardMetricsUseCase();
      final incidents = await getIncidentReportsUseCase();
      emit(ReportsLoaded(
        trips: trips,
        dashboardMetrics: metrics,
        incidentReports: incidents,
      ));
    } catch (e) {
      emit(ReportsError('Failed to load trips: $e'));
    }
  }

  Future<void> _onLoadTripDetails(
    LoadTripDetailsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      final trip = await getTripByIdUseCase(event.tripId);
      if (state is ReportsLoaded) {
        final current = state as ReportsLoaded;
        emit(current.copyWith(selectedTrip: trip));
      } else {
        final trips = await getTripsUseCase();
        final metrics = await getDashboardMetricsUseCase();
        final incidents = await getIncidentReportsUseCase();
        emit(ReportsLoaded(
          trips: trips,
          selectedTrip: trip,
          dashboardMetrics: metrics,
          incidentReports: incidents,
        ));
      }
    } catch (e) {
      emit(ReportsError('Failed to load trip details: $e'));
    }
  }

  Future<void> _onDeleteTrip(
    DeleteTripEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await deleteTripUseCase(event.tripId);
      final trips = await getTripsUseCase();
      final metrics = await getDashboardMetricsUseCase();
      final incidents = await getIncidentReportsUseCase();
      emit(ReportsLoaded(
        trips: trips,
        dashboardMetrics: metrics,
        incidentReports: incidents,
      ));
    } catch (e) {
      emit(ReportsError('Failed to delete trip: $e'));
    }
  }

  Future<void> _onLoadDashboardMetrics(
    LoadDashboardMetricsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      final metrics = await getDashboardMetricsUseCase();
      if (state is ReportsLoaded) {
        final current = state as ReportsLoaded;
        emit(current.copyWith(dashboardMetrics: metrics));
      } else {
        final trips = await getTripsUseCase();
        final incidents = await getIncidentReportsUseCase();
        emit(ReportsLoaded(
          trips: trips,
          dashboardMetrics: metrics,
          incidentReports: incidents,
        ));
      }
    } catch (e) {
      emit(ReportsError('Failed to load dashboard metrics: $e'));
    }
  }

  Future<void> _onLoadIncidentReports(
    LoadIncidentReportsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      final incidents = await getIncidentReportsUseCase();
      if (state is ReportsLoaded) {
        final current = state as ReportsLoaded;
        emit(current.copyWith(incidentReports: incidents));
      }
    } catch (e) {
      emit(ReportsError('Failed to load incident reports: $e'));
    }
  }

  Future<void> _onSubmitIncidentReport(
    SubmitIncidentReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await submitIncidentReportUseCase(event.report);
      final incidents = await getIncidentReportsUseCase();
      if (state is ReportsLoaded) {
        final current = state as ReportsLoaded;
        emit(current.copyWith(incidentReports: incidents));
      }
    } catch (e) {
      emit(ReportsError('Failed to submit incident report: $e'));
    }
  }

  Future<void> _onDeleteIncidentReport(
    DeleteIncidentReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await deleteIncidentReportUseCase(event.id);
      final incidents = await getIncidentReportsUseCase();
      if (state is ReportsLoaded) {
        final current = state as ReportsLoaded;
        emit(current.copyWith(incidentReports: incidents));
      }
    } catch (e) {
      emit(ReportsError('Failed to delete incident report: $e'));
    }
  }
}
