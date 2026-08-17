import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final int? id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double speed; // in m/s or km/h
  final double accuracy; // in meters
  final double altitude; // in meters
  final DateTime timestamp;

  const LocationPoint({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.speed = 0.0,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    latitude,
    longitude,
    speed,
    accuracy,
    altitude,
    timestamp,
  ];
}
