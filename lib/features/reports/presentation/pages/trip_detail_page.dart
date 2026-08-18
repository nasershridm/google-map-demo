import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dndn/core/di/injection.dart';
import 'package:dndn/core/utils/formatters.dart';
import 'package:dndn/core/utils/incident_marker_helper.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/reports/domain/use_cases/incident_use_cases.dart';
import 'package:dndn/features/reports/presentation/pages/incident_detail_page.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  GoogleMapController? _mapController;
  List<IncidentReport> _tripIncidents = [];
  bool _isLoadingIncidents = true;
  final Map<IncidentType, BitmapDescriptor> _customPins = {};

  @override
  void initState() {
    super.initState();
    _loadTripIncidents();
  }

  Future<void> _loadTripIncidents() async {
    for (final type in IncidentType.values) {
      final pin = await IncidentMarkerHelper.getCustomPin(type);
      _customPins[type] = pin;
    }

    try {
      final incidents =
          await getIt<GetIncidentsForTripUseCase>()(widget.trip.id);
      if (mounted) {
        setState(() {
          _tripIncidents = incidents;
          _isLoadingIncidents = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingIncidents = false;
        });
      }
    }
  }

  void _openIncidentDetail(IncidentReport incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailPage(incident: incident),
      ),
    );
  }

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

    // 1. Start Point Marker
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

      // 2. End Point Marker
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

    // 3. Trip Incident Markers with specific pins based on alert type
    for (final incident in _tripIncidents) {
      final customPin = _customPins[incident.type];
      markers.add(
        IncidentMarkerHelper.buildMarker(
          incident: incident,
          customIcon: customPin,
          onTap: () => _openIncidentDetail(incident),
        ),
      );
    }

    return markers;
  }

  void _fitBounds() {
    if (widget.trip.points.isEmpty || _mapController == null) return;

    if (widget.trip.points.length == 1 && _tripIncidents.isEmpty) {
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

    for (final incident in _tripIncidents) {
      if (incident.latitude < minLat) minLat = incident.latitude;
      if (incident.latitude > maxLat) maxLat = incident.latitude;
      if (incident.longitude < minLng) minLng = incident.longitude;
      if (incident.longitude > maxLng) maxLng = incident.longitude;
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
            flex: 5,
            child: Stack(
              children: [
                GoogleMap(
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
                if (_tripIncidents.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.report_problem_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_tripIncidents.length} alert${_tripIncidents.length == 1 ? '' : 's'} on route',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Metrics & Alerts Details Card
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Metrics Grid
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
                    const SizedBox(height: 10),
                    _buildDetailTile(
                      context,
                      'AVG SPEED',
                      AppFormatters.formatSpeed(
                        widget.trip.averageSpeedKmh,
                      ),
                      Icons.speed,
                      Colors.orange,
                      fullWidth: true,
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // ── Alerts on this Trip Section ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.add_alert_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Alerts Reported on this Trip',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _tripIncidents.isNotEmpty
                                ? Colors.red.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_tripIncidents.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _tripIncidents.isNotEmpty
                                  ? Colors.red.shade700
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_isLoadingIncidents)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (_tripIncidents.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'No incidents reported during this trip.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._tripIncidents.map((incident) {
                        final color =
                            IncidentMarkerHelper.getColor(incident.type);
                        final icon =
                            IncidentMarkerHelper.getIcon(incident.type);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () => _openIncidentDetail(incident),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            title: Text(
                              incident.type.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${incident.timestamp.hour.toString().padLeft(2, '0')}:${incident.timestamp.minute.toString().padLeft(2, '0')} • GPS: ${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (incident.notes != null &&
                                    incident.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      incident.notes!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    incident.type.arabicName,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

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
    Color color, {
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: fullWidth
          ? double.infinity
          : (MediaQuery.of(context).size.width - 60) / 2,
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

