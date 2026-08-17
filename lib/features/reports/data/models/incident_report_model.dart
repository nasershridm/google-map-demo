import 'package:dndn/features/reports/domain/entities/incident_report.dart';

class IncidentReportModel extends IncidentReport {
  const IncidentReportModel({
    super.id,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.notes,
  });

  factory IncidentReportModel.fromEntity(IncidentReport entity) {
    return IncidentReportModel(
      id: entity.id,
      type: entity.type,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      notes: entity.notes,
    );
  }

  factory IncidentReportModel.fromMap(Map<String, dynamic> map) {
    return IncidentReportModel(
      id: map['id'] as int?,
      type: IncidentTypeExtension.fromCode(map['type'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type.code,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  IncidentReport toEntity() {
    return IncidentReport(
      id: id,
      type: type,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      notes: notes,
    );
  }
}
