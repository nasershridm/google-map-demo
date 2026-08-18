import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/repositories/trip_repository.dart';

class SubmitIncidentReportUseCase {
  final TripRepository repository;

  SubmitIncidentReportUseCase(this.repository);

  Future<void> call(IncidentReport report) async {
    return repository.submitIncidentReport(report);
  }
}

class GetIncidentReportsUseCase {
  final TripRepository repository;

  GetIncidentReportsUseCase(this.repository);

  Future<List<IncidentReport>> call() async {
    return repository.getIncidentReports();
  }
}

class DeleteIncidentReportUseCase {
  final TripRepository repository;

  DeleteIncidentReportUseCase(this.repository);

  Future<void> call(int id) async {
    return repository.deleteIncidentReport(id);
  }
}

class GetIncidentsForTripUseCase {
  final TripRepository repository;

  GetIncidentsForTripUseCase(this.repository);

  Future<List<IncidentReport>> call(String tripId) async {
    return repository.getIncidentReportsForTrip(tripId);
  }
}
