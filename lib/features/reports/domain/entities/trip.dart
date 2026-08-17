import 'package:equatable/equatable.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class Trip extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistanceMeters;
  final int durationSeconds;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final int pointCount;
  final List<LocationPoint> points;
  final bool isCompleted;

  const Trip({
    required this.id,
    required this.startTime,
    this.endTime,
    this.totalDistanceMeters = 0.0,
    this.durationSeconds = 0,
    this.averageSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.pointCount = 0,
    this.points = const [],
    this.isCompleted = false,
  });

  Trip copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistanceMeters,
    int? durationSeconds,
    double? averageSpeedKmh,
    double? maxSpeedKmh,
    int? pointCount,
    List<LocationPoint>? points,
    bool? isCompleted,
  }) {
    return Trip(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      pointCount: pointCount ?? this.pointCount,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    totalDistanceMeters,
    durationSeconds,
    averageSpeedKmh,
    maxSpeedKmh,
    pointCount,
    points,
    isCompleted,
  ];
}
