import 'dart:async';
import 'package:dndn/core/errors/exceptions.dart';
import 'package:dndn/core/services/websocket_emulator_service.dart';
import 'package:dndn/core/utils/location_calculator.dart';
import 'package:dndn/features/reports/data/models/trip_model.dart';
import 'package:dndn/features/tracking/data/datasources/foreground_service_handler.dart';
import 'package:dndn/features/tracking/data/datasources/location_service_datasource.dart';
import 'package:dndn/features/tracking/data/datasources/tracking_local_datasource.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';
import 'package:dndn/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final LocationServiceDataSource locationDataSource;
  final TrackingLocalDataSource localDataSource;

  StreamSubscription<LocationPointModel>? _locationSubscription;
  final StreamController<LocationPoint> _locationStreamController =
      StreamController<LocationPoint>.broadcast();

  String? _activeTripId;
  bool _isTracking = false;
  bool _isPaused = false;
  LocationPoint? _lastLocationPoint;

  TrackingRepositoryImpl({
    required this.locationDataSource,
    required this.localDataSource,
  });

  @override
  bool get isTracking => _isTracking;

  @override
  String? get currentTripId => _activeTripId;

  @override
  Future<bool> requestPermissions() async {
    return await locationDataSource.requestPermissions();
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await locationDataSource.isLocationServiceEnabled();
  }

  @override
  Future<bool> hasPermission() async {
    return await locationDataSource.hasPermission();
  }

  @override
  Future<void> startTracking(String tripId) async {
    _activeTripId = tripId;
    _isTracking = true;
    _isPaused = false;
    _lastLocationPoint = null;

    // Create initial trip record in SQLite
    final initialTrip = TripModel(
      id: tripId,
      startTime: DateTime.now(),
      isCompleted: false,
    );
    await localDataSource.insertTrip(initialTrip);

    // Start Foreground Notification Service
    final serviceStarted = await ForegroundServiceManager.startService(tripId: tripId);
    // ignore: avoid_print
    print('[DNDN_SERVICE] Foreground service started: $serviceStarted | tripId=$tripId');

    // Cancel any previous stream subscription
    await _locationSubscription?.cancel();

    // Listen to GPS stream
    // ignore: avoid_print
    print('[DNDN_SERVICE] 🎙️ GPS stream subscription starting...');
    _locationSubscription = locationDataSource
        .getPositionStream(tripId: tripId)
        .listen(
          (pointModel) async {
            if (!_isTracking || _isPaused) return;

            // Persist location point to SQLite database
            await localDataSource.insertLocationPoint(pointModel);

            // Compute distance delta from previous point
            if (_lastLocationPoint != null) {
              final double distanceDelta =
                  LocationCalculator.calculateDistanceMeters(
                    startLatitude: _lastLocationPoint!.latitude,
                    startLongitude: _lastLocationPoint!.longitude,
                    endLatitude: pointModel.latitude,
                    endLongitude: pointModel.longitude,
                  );

              // Update active trip aggregated distance
              final activeTrip = await localDataSource.getTripById(tripId);
              if (activeTrip != null) {
                final double updatedDistance =
                    activeTrip.totalDistanceMeters + distanceDelta;
                final double currentMaxSpeed =
                    pointModel.speed > activeTrip.maxSpeedKmh
                    ? pointModel.speed
                    : activeTrip.maxSpeedKmh;

                await localDataSource.updateTrip(
                  TripModel.fromEntity(
                    activeTrip.copyWith(
                      totalDistanceMeters: updatedDistance,
                      maxSpeedKmh: currentMaxSpeed,
                    ),
                  ),
                );
              }
            }

            _lastLocationPoint = pointModel.toEntity();
            _locationStreamController.add(pointModel.toEntity());

            // Simulate real-time WebSocket location push
            WebSocketEmulatorService.emitLocation(pointModel.toEntity());
          },
          onError: (error) {
            // ignore: avoid_print
            print('[DNDN_SERVICE] ❌ GPS stream error: $error');
            _locationStreamController.addError(
              LocationException('GPS Stream error: $error'),
            );
          },
          onDone: () {
            // ignore: avoid_print
            print('[DNDN_SERVICE] ⏹️ GPS stream done/closed');
          },
        );
  }

  @override
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _isTracking = false;
    _isPaused = false;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    if (_activeTripId != null) {
      final trip = await localDataSource.getTripById(_activeTripId!);
      if (trip != null) {
        final now = DateTime.now();
        final int durationSeconds = now.difference(trip.startTime).inSeconds > 0
            ? now.difference(trip.startTime).inSeconds
            : 1;

        final double avgSpeed = LocationCalculator.calculateAverageSpeedKmh(
          distanceMeters: trip.totalDistanceMeters,
          durationSeconds: durationSeconds,
        );

        final completedTrip = TripModel.fromEntity(
          trip.copyWith(
            endTime: now,
            durationSeconds: durationSeconds,
            averageSpeedKmh: avgSpeed,
            isCompleted: true,
          ),
        );
        await localDataSource.updateTrip(completedTrip);
      }
    }

    _activeTripId = null;
    _lastLocationPoint = null;

    // Stop foreground service
    await ForegroundServiceManager.stopService();
  }

  @override
  Future<void> pauseTracking() async {
    _isPaused = true;
  }

  @override
  Future<void> resumeTracking() async {
    _isPaused = false;
  }

  @override
  Stream<LocationPoint> getLocationStream() {
    return _locationStreamController.stream;
  }

  @override
  Future<LocationPoint> getCurrentLocation() async {
    final position = await locationDataSource.getCurrentPosition();
    return LocationPointModel.fromPosition(
      position: position,
      tripId: _activeTripId ?? 'single_fix',
    ).toEntity();
  }
}
