import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/reports/domain/repositories/trip_repository.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class GetTripsUseCase {
  final TripRepository repository;

  GetTripsUseCase(this.repository);

  Future<List<Trip>> call() async {
    return repository.getTrips();
  }
}

class GetTripByIdUseCase {
  final TripRepository repository;

  GetTripByIdUseCase(this.repository);

  Future<Trip?> call(String id) async {
    return repository.getTripById(id);
  }
}

class SaveTripUseCase {
  final TripRepository repository;

  SaveTripUseCase(this.repository);

  Future<void> call(Trip trip) async {
    return repository.saveTrip(trip);
  }
}

class UpdateTripUseCase {
  final TripRepository repository;

  UpdateTripUseCase(this.repository);

  Future<void> call(Trip trip) async {
    return repository.updateTrip(trip);
  }
}

class DeleteTripUseCase {
  final TripRepository repository;

  DeleteTripUseCase(this.repository);

  Future<void> call(String id) async {
    return repository.deleteTrip(id);
  }
}

class SaveLocationPointUseCase {
  final TripRepository repository;

  SaveLocationPointUseCase(this.repository);

  Future<void> call(LocationPoint point) async {
    return repository.saveLocationPoint(point);
  }
}

class GetDashboardMetricsUseCase {
  final TripRepository repository;

  GetDashboardMetricsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return repository.getDashboardMetrics();
  }
}
