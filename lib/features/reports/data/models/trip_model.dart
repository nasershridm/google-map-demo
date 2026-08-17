import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.startTime,
    super.endTime,
    super.totalDistanceMeters,
    super.durationSeconds,
    super.averageSpeedKmh,
    super.maxSpeedKmh,
    super.pointCount,
    super.points,
    super.isCompleted,
  });

  factory TripModel.fromEntity(Trip entity) {
    return TripModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalDistanceMeters: entity.totalDistanceMeters,
      durationSeconds: entity.durationSeconds,
      averageSpeedKmh: entity.averageSpeedKmh,
      maxSpeedKmh: entity.maxSpeedKmh,
      pointCount: entity.pointCount,
      points: entity.points,
      isCompleted: entity.isCompleted,
    );
  }

  factory TripModel.fromMap(
    Map<String, dynamic> map, {
    List<LocationPoint> points = const [],
  }) {
    return TripModel(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
      totalDistanceMeters: (map['total_distance'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      averageSpeedKmh: (map['average_speed'] as num?)?.toDouble() ?? 0.0,
      maxSpeedKmh: (map['max_speed'] as num?)?.toDouble() ?? 0.0,
      pointCount: map['point_count'] as int? ?? 0,
      points: points,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'total_distance': totalDistanceMeters,
      'duration_seconds': durationSeconds,
      'average_speed': averageSpeedKmh,
      'max_speed': maxSpeedKmh,
      'point_count': pointCount,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  Trip toEntity() {
    return Trip(
      id: id,
      startTime: startTime,
      endTime: endTime,
      totalDistanceMeters: totalDistanceMeters,
      durationSeconds: durationSeconds,
      averageSpeedKmh: averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      pointCount: pointCount,
      points: points.map((p) {
        if (p is LocationPointModel) return p.toEntity();
        return p;
      }).toList(),
      isCompleted: isCompleted,
    );
  }
}
