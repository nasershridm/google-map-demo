import 'dart:convert';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

/// Simulates real-time WebSocket data transmission via console output.
/// Uses [print] (not [debugPrint]) so logs are always visible in adb logcat
/// regardless of whether a Dart VM is attached.
class WebSocketEmulatorService {
  static const _locTag  = 'DNDN_WS_LOC';
  static const _incTag  = 'DNDN_WS_INC';

  static void emitLocation(LocationPoint point) {
    final payload = {
      'event': 'LOCATION_STREAM_UPDATE',
      'trip_id': point.tripId,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'speed_kmh': point.speed,
      'accuracy_meters': point.accuracy,
      'altitude_meters': point.altitude,
      'timestamp': point.timestamp.toIso8601String(),
    };
    // ignore: avoid_print
    print('[$_locTag] 🌐 ${jsonEncode(payload)}');
  }

  static void emitIncident(IncidentReport incident) {
    final payload = {
      'event': 'INCIDENT_REPORT_SUBMITTED',
      'type': incident.type.name,
      'type_ar': incident.type.arabicName,
      'latitude': incident.latitude,
      'longitude': incident.longitude,
      'timestamp': incident.timestamp.toIso8601String(),
      'notes': incident.notes,
    };
    // ignore: avoid_print
    print('[$_incTag] 🚨 ${jsonEncode(payload)}');
  }
}
