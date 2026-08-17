import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/constants/app_constants.dart';
import 'package:dndn/core/di/injection.dart';
import 'package:dndn/core/theme/theme_switch_button.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_event.dart';
import 'package:dndn/features/reports/presentation/widgets/incident_report_bottom_sheet.dart';
import 'package:dndn/features/tracking/domain/use_cases/tracking_use_cases.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_event.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_state.dart';
import 'package:dndn/features/tracking/presentation/widgets/tracking_controls.dart';
import 'package:dndn/features/tracking/presentation/widgets/tracking_hud_card.dart';
import 'package:dndn/features/tracking/presentation/widgets/tracking_map_view.dart';
import 'package:dndn/features/tracking/presentation/widgets/trip_summary_dialog.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  Future<void> _showIncidentSheet(BuildContext context, TrackingState state) async {
    // Use last known GPS point if available, otherwise fetch current location
    double lat = 0, lng = 0;
    if (state is TrackingActive && state.currentPoint != null) {
      lat = state.currentPoint!.latitude;
      lng = state.currentPoint!.longitude;
    } else {
      try {
        final point = await getIt<GetCurrentLocationUseCase>()();
        lat = point.latitude;
        lng = point.longitude;
      } catch (_) {}
    }

    if (!context.mounted) return;

    final report = await IncidentReportBottomSheet.show(
      context,
      latitude: lat,
      longitude: lng,
    );

    if (report != null && context.mounted) {
      context.read<ReportsBloc>().add(SubmitIncidentReportEvent(report));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_incidentIcon(report.type), color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('${report.type.displayName} reported successfully'),
            ],
          ),
          backgroundColor: _incidentColor(report.type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  IconData _incidentIcon(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return Icons.local_police_rounded;
      case IncidentType.accident:
        return Icons.car_crash_rounded;
      case IncidentType.traffic:
        return Icons.traffic_rounded;
    }
  }

  Color _incidentColor(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return const Color(0xFF1A73E8);
      case IncidentType.accident:
        return const Color(0xFFE53935);
      case IncidentType.traffic:
        return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackingBloc, TrackingState>(
      listener: (context, state) {
        if (state is TrackingPermissionDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () {
                  context.read<TrackingBloc>().add(
                    const CheckPermissionsEvent(),
                  );
                },
              ),
            ),
          );
        } else if (state is TrackingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is TrackingCompleted) {
          // Refresh trips in ReportsBloc
          context.read<ReportsBloc>().add(const LoadTripsEvent());

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) => TripSummaryDialog(
              trip: state.trip,
              onDismiss: () {
                Navigator.of(dialogCtx).pop();
                context.read<TrackingBloc>().add(
                  const StopTrackingRequestedEvent(),
                );
              },
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isTracking = state is TrackingActive;
        final bool isPaused = isTracking && (state).isPaused;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              const ThemeSwitchButton(),
              if (isTracking)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaused ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPaused ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaused ? 'PAUSED' : 'RECORDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPaused ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // 1. Google Map
              Positioned.fill(
                child: TrackingMapView(
                  routePoints: isTracking ? state.routePoints : const [],
                  currentPoint: isTracking ? state.currentPoint : null,
                  isTracking: isTracking,
                ),
              ),

              // 2. HUD Card overlay (when tracking is active)
              if (isTracking)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: TrackingHudCard(
                    elapsedSeconds: state.elapsedSeconds,
                    distanceMeters: state.totalDistanceMeters,
                    currentSpeedKmh: state.currentSpeedKmh,
                    maxSpeedKmh: state.maxSpeedKmh,
                    isPaused: isPaused,
                  ),
                ),

              // 3. Incident Report FAB (top-right, visible when tracking)
              if (isTracking)
                Positioned(
                  top: isTracking ? 110 : 16,
                  right: 16,
                  child: _IncidentFab(
                    onTap: () => _showIncidentSheet(context, state),
                  ),
                ),

              // 4. Bottom Controls overlay
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: TrackingControls(
                    isTracking: isTracking,
                    isPaused: isPaused,
                    onStart: () {
                      context.read<TrackingBloc>().add(
                        const StartTrackingRequestedEvent(),
                      );
                    },
                    onPause: () {
                      context.read<TrackingBloc>().add(
                        const PauseTrackingRequestedEvent(),
                      );
                    },
                    onResume: () {
                      context.read<TrackingBloc>().add(
                        const ResumeTrackingRequestedEvent(),
                      );
                    },
                    onStop: () {
                      context.read<TrackingBloc>().add(
                        const StopTrackingRequestedEvent(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Incident FAB ────────────────────────────────────────────────────────────
class _IncidentFab extends StatelessWidget {
  final VoidCallback onTap;
  const _IncidentFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Report Incident',
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_alert_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
