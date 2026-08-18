import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';

class IncidentMarkerHelper {
  static const Color policeColor = Color(0xFF1A73E8);
  static const Color accidentColor = Color(0xFFE53935);
  static const Color trafficColor = Color(0xFFF57C00);

  static final Map<IncidentType, BitmapDescriptor> _customIconCache = {};

  static Color getColor(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return policeColor;
      case IncidentType.accident:
        return accidentColor;
      case IncidentType.traffic:
        return trafficColor;
    }
  }

  static IconData getIcon(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return Icons.local_police_rounded;
      case IncidentType.accident:
        return Icons.car_crash_rounded;
      case IncidentType.traffic:
        return Icons.traffic_rounded;
    }
  }

  static double getHue(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return BitmapDescriptor.hueAzure;
      case IncidentType.accident:
        return BitmapDescriptor.hueRed;
      case IncidentType.traffic:
        return BitmapDescriptor.hueOrange;
    }
  }

  /// Preloads custom canvas pins for all incident types.
  static Future<void> preloadPins() async {
    for (final type in IncidentType.values) {
      await getCustomPin(type);
    }
  }

  /// Returns a cached or newly created custom canvas pin for the given [IncidentType].
  static Future<BitmapDescriptor> getCustomPin(IncidentType type) async {
    if (_customIconCache.containsKey(type)) {
      return _customIconCache[type]!;
    }

    try {
      final descriptor = await _generateCanvasPin(type);
      _customIconCache[type] = descriptor;
      return descriptor;
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(getHue(type));
    }
  }

  /// Synchronous fallback marker descriptor.
  static BitmapDescriptor getDefaultPin(IncidentType type) {
    return _customIconCache[type] ??
        BitmapDescriptor.defaultMarkerWithHue(getHue(type));
  }

  /// Draws a modern compact teardrop pin with a badge icon and shadow on a Canvas.
  static Future<BitmapDescriptor> _generateCanvasPin(IncidentType type) async {
    const double width = 64;
    const double height = 80;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    final color = getColor(type);
    final iconData = getIcon(type);

    // 1. Draw Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(width / 2, height - 8),
        width: 24,
        height: 9,
      ));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Draw Pin Outer Body (Teardrop Shape)
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pinPath = Path();
    const double circleRadius = 24;
    const double circleCenterY = 26;
    const double circleCenterX = width / 2;

    pinPath.addArc(
      Rect.fromCircle(
        center: const Offset(circleCenterX, circleCenterY),
        radius: circleRadius,
      ),
      0.65,
      4.98,
    );
    pinPath.lineTo(circleCenterX, height - 10);
    pinPath.close();

    canvas.drawPath(pinPath, pinPaint);

    // 3. Draw Outer Border Stroke
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(pinPath, borderPaint);

    // 4. Draw Inner White Circle
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(circleCenterX, circleCenterY),
      circleRadius - 5.5,
      innerCirclePaint,
    );

    // 5. Draw Icon inside inner circle
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 20,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        circleCenterX - (textPainter.width / 2),
        circleCenterY - (textPainter.height / 2),
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(getHue(type));
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  /// Builds a Google Map [Marker] for an [IncidentReport].
  static Marker buildMarker({
    required IncidentReport incident,
    BitmapDescriptor? customIcon,
    VoidCallback? onTap,
  }) {
    final pin = customIcon ?? getDefaultPin(incident.type);

    return Marker(
      markerId: MarkerId('incident_${incident.id ?? "${incident.latitude}_${incident.longitude}_${incident.timestamp.millisecondsSinceEpoch}"}'),
      position: LatLng(incident.latitude, incident.longitude),
      icon: pin,
      anchor: const Offset(0.5, 0.9),
      infoWindow: InfoWindow(
        title: '${incident.type.arabicName} • ${incident.type.displayName}',
        snippet: incident.notes != null && incident.notes!.isNotEmpty
            ? incident.notes
            : 'Tap for alert details',
        onTap: onTap,
      ),
      onTap: onTap,
    );
  }
}
