import 'package:geolocator/geolocator.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class LocationPointModel extends LocationPoint {
  const LocationPointModel({
    super.id,
    required super.tripId,
    required super.latitude,
    required super.longitude,
    super.speed,
    super.accuracy,
    super.altitude,
    required super.timestamp,
  });

  factory LocationPointModel.fromEntity(LocationPoint entity) {
    return LocationPointModel(
      id: entity.id,
      tripId: entity.tripId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      speed: entity.speed,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      timestamp: entity.timestamp,
    );
  }

  factory LocationPointModel.fromMap(Map<String, dynamic> map) {
    return LocationPointModel(
      id: map['id'] as int?,
      tripId: map['trip_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  factory LocationPointModel.fromPosition({
    required Position position,
    required String tripId,
  }) {
    return LocationPointModel(
      tripId: tripId,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed < 0 ? 0.0 : position.speed * 3.6, // m/s to km/h
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'accuracy': accuracy,
      'altitude': altitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  LocationPoint toEntity() {
    return LocationPoint(
      id: id,
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      accuracy: accuracy,
      altitude: altitude,
      timestamp: timestamp,
    );
  }
}
