import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/utils/location_calculator.dart';
import 'package:dndn/features/reports/domain/use_cases/trip_use_cases.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';
import 'package:dndn/features/tracking/domain/use_cases/tracking_use_cases.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_event.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final StartTrackingUseCase startTrackingUseCase;
  final StopTrackingUseCase stopTrackingUseCase;
  final PauseTrackingUseCase pauseTrackingUseCase;
  final ResumeTrackingUseCase resumeTrackingUseCase;
  final GetLocationStreamUseCase getLocationStreamUseCase;
  final CheckLocationPermissionsUseCase checkPermissionsUseCase;
  final GetTripByIdUseCase getTripByIdUseCase;

  StreamSubscription<LocationPoint>? _locationSubscription;
  Timer? _tickerTimer;

  TrackingBloc({
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
    required this.pauseTrackingUseCase,
    required this.resumeTrackingUseCase,
    required this.getLocationStreamUseCase,
    required this.checkPermissionsUseCase,
    required this.getTripByIdUseCase,
  }) : super(const TrackingInitial()) {
    on<CheckPermissionsEvent>(_onCheckPermissions);
    on<StartTrackingRequestedEvent>(_onStartTracking);
    on<StopTrackingRequestedEvent>(_onStopTracking);
    on<PauseTrackingRequestedEvent>(_onPauseTracking);
    on<ResumeTrackingRequestedEvent>(_onResumeTracking);
    on<LocationPointReceivedEvent>(_onLocationPointReceived);
    on<TrackingTimerTickedEvent>(_onTimerTicked);
  }

  Future<void> _onCheckPermissions(
    CheckPermissionsEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // ignore: avoid_print
    print('[DNDN_BLOC] Checking location permissions...');
    final granted = await checkPermissionsUseCase();
    // ignore: avoid_print
    print('[DNDN_BLOC] Location permissions granted: $granted');
    if (!granted) {
      emit(const TrackingPermissionDenied());
    }
  }

  Future<void> _onStartTracking(
    StartTrackingRequestedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    try {
      // ignore: avoid_print
      print('[DNDN_BLOC] ▶️ StartTrackingRequestedEvent received.');
      final permissionGranted = await checkPermissionsUseCase();
      // ignore: avoid_print
      print('[DNDN_BLOC] Permission check before start: $permissionGranted');
      if (!permissionGranted) {
        emit(const TrackingPermissionDenied());
        return;
      }

      final String tripId =
          event.customTripId ?? 'trip_${DateTime.now().millisecondsSinceEpoch}';
      final DateTime startTime = DateTime.now();

      // ignore: avoid_print
      print('[DNDN_BLOC] Calling startTrackingUseCase with tripId: $tripId');
      await startTrackingUseCase(tripId);
      // ignore: avoid_print
      print('[DNDN_BLOC] startTrackingUseCase completed successfully.');

      emit(
        TrackingActive(
          tripId: tripId,
          startTime: startTime,
          elapsedSeconds: 0,
          totalDistanceMeters: 0.0,
          currentSpeedKmh: 0.0,
          maxSpeedKmh: 0.0,
          routePoints: const [],
          isPaused: false,
        ),
      );

      // Start live coordinate stream listener
      await _locationSubscription?.cancel();
      _locationSubscription = getLocationStreamUseCase().listen((point) {
        add(LocationPointReceivedEvent(point));
      });

      // Start elapsed seconds timer
      _tickerTimer?.cancel();
      _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state is TrackingActive && !(state as TrackingActive).isPaused) {
          final activeState = state as TrackingActive;
          add(TrackingTimerTickedEvent(activeState.elapsedSeconds + 1));
        }
      });
    } catch (e, stack) {
      // ignore: avoid_print
      print('[DNDN_BLOC] ❌ Error in _onStartTracking: $e\n$stack');
      emit(TrackingError('Failed to start tracking: $e'));
    }
  }

  void _onLocationPointReceived(
    LocationPointReceivedEvent event,
    Emitter<TrackingState> emit,
  ) {
    if (state is! TrackingActive) return;
    final currentState = state as TrackingActive;
    if (currentState.isPaused) return;

    final updatedPoints = List<LocationPoint>.from(currentState.routePoints)
      ..add(event.point);

    double updatedDistance = currentState.totalDistanceMeters;
    if (currentState.currentPoint != null) {
      updatedDistance += LocationCalculator.calculateDistanceMeters(
        startLatitude: currentState.currentPoint!.latitude,
        startLongitude: currentState.currentPoint!.longitude,
        endLatitude: event.point.latitude,
        endLongitude: event.point.longitude,
      );
    }

    final double maxSpeed = event.point.speed > currentState.maxSpeedKmh
        ? event.point.speed
        : currentState.maxSpeedKmh;

    emit(
      currentState.copyWith(
        currentPoint: event.point,
        routePoints: updatedPoints,
        totalDistanceMeters: updatedDistance,
        currentSpeedKmh: event.point.speed,
        maxSpeedKmh: maxSpeed,
      ),
    );
  }

  void _onTimerTicked(
    TrackingTimerTickedEvent event,
    Emitter<TrackingState> emit,
  ) {
    if (state is! TrackingActive) return;
    final currentState = state as TrackingActive;
    emit(currentState.copyWith(elapsedSeconds: event.elapsedSeconds));
  }

  Future<void> _onPauseTracking(
    PauseTrackingRequestedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingActive) return;
    final currentState = state as TrackingActive;
    await pauseTrackingUseCase();
    emit(currentState.copyWith(isPaused: true));
  }

  Future<void> _onResumeTracking(
    ResumeTrackingRequestedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingActive) return;
    final currentState = state as TrackingActive;
    await resumeTrackingUseCase();
    emit(currentState.copyWith(isPaused: false));
  }

  Future<void> _onStopTracking(
    StopTrackingRequestedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingActive) return;
    final currentState = state as TrackingActive;

    _tickerTimer?.cancel();
    _tickerTimer = null;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    try {
      await stopTrackingUseCase();

      final completedTrip = await getTripByIdUseCase(currentState.tripId);
      if (completedTrip != null) {
        emit(TrackingCompleted(completedTrip));
      } else {
        emit(const TrackingInitial());
      }
    } catch (e) {
      emit(TrackingError('Failed to stop tracking: $e'));
    }
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    _locationSubscription?.cancel();
    return super.close();
  }
}
