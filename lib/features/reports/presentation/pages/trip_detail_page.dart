import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dndn/core/utils/formatters.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  GoogleMapController? _mapController;

  Set<Polyline> _buildPolylines() {
    if (widget.trip.points.length < 2) return {};

    return {
      Polyline(
        polylineId: PolylineId('detail_route_${widget.trip.id}'),
        points: widget.trip.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        color: const Color(0xFF1E88E5),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (widget.trip.points.isNotEmpty) {
      final start = widget.trip.points.first;
      markers.add(
        Marker(
          markerId: const MarkerId('detail_start_point'),
          position: LatLng(start.latitude, start.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Start Location',
            snippet: AppFormatters.formatDateTime(start.timestamp),
          ),
        ),
      );

      if (widget.trip.points.length > 1) {
        final end = widget.trip.points.last;
        markers.add(
          Marker(
            markerId: const MarkerId('detail_end_point'),
            position: LatLng(end.latitude, end.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'End Location',
              snippet: AppFormatters.formatDateTime(end.timestamp),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _fitBounds() {
    if (widget.trip.points.isEmpty || _mapController == null) return;

    if (widget.trip.points.length == 1) {
      final p = widget.trip.points.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 15.0),
      );
      return;
    }

    double minLat = widget.trip.points.first.latitude;
    double maxLat = widget.trip.points.first.latitude;
    double minLng = widget.trip.points.first.longitude;
    double maxLng = widget.trip.points.first.longitude;

    for (final point in widget.trip.points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final LatLng initialTarget = widget.trip.points.isNotEmpty
        ? LatLng(
            widget.trip.points.first.latitude,
            widget.trip.points.first.longitude,
          )
        : const LatLng(30.0444, 31.2357);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Route Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_free),
            tooltip: 'Fit Route',
            onPressed: _fitBounds,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Google Map View
          Expanded(
            flex: 6,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 14.0,
              ),
              polylines: _buildPolylines(),
              markers: _buildMarkers(),
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => _fitBounds(),
                );
              },
            ),
          ),
          // 2. Metrics Details Card
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatDateTime(widget.trip.startTime),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailTile(
                          context,
                          'DISTANCE',
                          AppFormatters.formatDistance(
                            widget.trip.totalDistanceMeters,
                          ),
                          Icons.straighten,
                          Colors.green,
                        ),
                        _buildDetailTile(
                          context,
                          'DURATION',
                          AppFormatters.formatDuration(
                            widget.trip.durationSeconds,
                          ),
                          Icons.timer_outlined,
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailTile(
                          context,
                          'AVG SPEED',
                          AppFormatters.formatSpeed(
                            widget.trip.averageSpeedKmh,
                          ),
                          Icons.speed,
                          Colors.orange,
                        ),
                        _buildDetailTile(
                          context,
                          'MAX SPEED',
                          AppFormatters.formatSpeed(widget.trip.maxSpeedKmh),
                          Icons.bolt,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Total Recorded GPS Points: ${widget.trip.points.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
