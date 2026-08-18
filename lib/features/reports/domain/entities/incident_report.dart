import 'package:equatable/equatable.dart';

enum IncidentType {
  police, // شرطة
  accident, // حادث
  traffic, // زحام
}

extension IncidentTypeExtension on IncidentType {
  String get displayName {
    switch (this) {
      case IncidentType.police:
        return 'Police (شرطة)';
      case IncidentType.accident:
        return 'Accident (حادث)';
      case IncidentType.traffic:
        return 'Traffic / Congestion (زحام)';
    }
  }

  String get arabicName {
    switch (this) {
      case IncidentType.police:
        return 'شرطة';
      case IncidentType.accident:
        return 'حادث';
      case IncidentType.traffic:
        return 'زحام';
    }
  }

  String get code => name;

  static IncidentType fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'police':
        return IncidentType.police;
      case 'accident':
        return IncidentType.accident;
      case 'traffic':
      default:
        return IncidentType.traffic;
    }
  }
}

class IncidentReport extends Equatable {
  final int? id;
  final String? tripId;
  final IncidentType type;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? notes;

  const IncidentReport({
    this.id,
    this.tripId,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    type,
    latitude,
    longitude,
    timestamp,
    notes,
  ];
}
