import 'package:equatable/equatable.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingPermissionDenied extends TrackingState {
  final String message;
  const TrackingPermissionDenied([
    this.message = 'Location permission is required to track trips.',
  ]);

  @override
  List<Object?> get props => [message];
}

class TrackingActive extends TrackingState {
  final String tripId;
  final DateTime startTime;
  final int elapsedSeconds;
  final double totalDistanceMeters;
  final double currentSpeedKmh;
  final double maxSpeedKmh;
  final LocationPoint? currentPoint;
  final List<LocationPoint> routePoints;
  final bool isPaused;

  const TrackingActive({
    required this.tripId,
    required this.startTime,
    this.elapsedSeconds = 0,
    this.totalDistanceMeters = 0.0,
    this.currentSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.currentPoint,
    this.routePoints = const [],
    this.isPaused = false,
  });

  double get averageSpeedKmh {
    if (elapsedSeconds <= 0 || totalDistanceMeters <= 0) return 0.0;
    return (totalDistanceMeters / elapsedSeconds) * 3.6;
  }

  TrackingActive copyWith({
    String? tripId,
    DateTime? startTime,
    int? elapsedSeconds,
    double? totalDistanceMeters,
    double? currentSpeedKmh,
    double? maxSpeedKmh,
    LocationPoint? currentPoint,
    List<LocationPoint>? routePoints,
    bool? isPaused,
  }) {
    return TrackingActive(
      tripId: tripId ?? this.tripId,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      currentPoint: currentPoint ?? this.currentPoint,
      routePoints: routePoints ?? this.routePoints,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [
    tripId,
    startTime,
    elapsedSeconds,
    totalDistanceMeters,
    currentSpeedKmh,
    maxSpeedKmh,
    currentPoint,
    routePoints,
    isPaused,
  ];
}

class TrackingCompleted extends TrackingState {
  final Trip trip;
  const TrackingCompleted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TrackingError extends TrackingState {
  final String message;
  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
