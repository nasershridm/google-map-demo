import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dndn/core/utils/incident_marker_helper.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

class TrackingMapView extends StatefulWidget {
  final List<LocationPoint> routePoints;
  final LocationPoint? currentPoint;
  final bool isTracking;
  final List<IncidentReport> incidents;
  final void Function(IncidentReport)? onIncidentTap;

  const TrackingMapView({
    super.key,
    required this.routePoints,
    this.currentPoint,
    this.isTracking = false,
    this.incidents = const [],
    this.onIncidentTap,
  });

  @override
  State<TrackingMapView> createState() => _TrackingMapViewState();
}

class _TrackingMapViewState extends State<TrackingMapView> {
  GoogleMapController? _mapController;
  final Map<IncidentType, BitmapDescriptor> _customPins = {};

  static const CameraPosition _defaultInitialPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357), // Default Cairo coordinates
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomPins();
  }

  Future<void> _loadCustomPins() async {
    for (final type in IncidentType.values) {
      final pin = await IncidentMarkerHelper.getCustomPin(type);
      if (mounted) {
        setState(() {
          _customPins[type] = pin;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant TrackingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPoint != null &&
        widget.currentPoint != oldWidget.currentPoint) {
      _animateToPoint(widget.currentPoint!);
    }
  }

  void _animateToPoint(LocationPoint point) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(point.latitude, point.longitude)),
    );
  }

  void _centerOnCurrentPosition() {
    if (widget.currentPoint != null) {
      _animateToPoint(widget.currentPoint!);
    }
  }

  Set<Polyline> _buildPolylines() {
    if (widget.routePoints.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('tracking_route'),
        points: widget.routePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        color: const Color(0xFF1E88E5),
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // 1. Start point marker
    if (widget.routePoints.isNotEmpty) {
      final start = widget.routePoints.first;
      markers.add(
        Marker(
          markerId: const MarkerId('start_point'),
          position: LatLng(start.latitude, start.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Start Point'),
        ),
      );
    }

    // 2. Current tracking position marker
    if (widget.currentPoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_point'),
          position: LatLng(
            widget.currentPoint!.latitude,
            widget.currentPoint!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'Current Position',
            snippet:
                'Speed: ${widget.currentPoint!.speed.toStringAsFixed(1)} km/h',
          ),
        ),
      );
    }

    // 3. Incident alert markers with specific pins based on type
    for (final incident in widget.incidents) {
      final customPin = _customPins[incident.type];
      markers.add(
        IncidentMarkerHelper.buildMarker(
          incident: incident,
          customIcon: customPin,
          onTap: () {
            if (widget.onIncidentTap != null) {
              widget.onIncidentTap!(incident);
            }
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialTarget = widget.currentPoint != null
        ? LatLng(widget.currentPoint!.latitude, widget.currentPoint!.longitude)
        : _defaultInitialPosition.target;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: 16.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          polylines: _buildPolylines(),
          markers: _buildMarkers(),
          onMapCreated: (controller) {
            _mapController = controller;
            if (widget.currentPoint != null) {
              _animateToPoint(widget.currentPoint!);
            }
          },
        ),
        // Center on location FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'center_location_fab',
            onPressed: _centerOnCurrentPosition,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
