import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/theme/theme_switch_button.dart';
import 'package:dndn/core/utils/formatters.dart';
import 'package:dndn/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_event.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_state.dart';
import 'package:dndn/features/reports/presentation/pages/incident_detail_page.dart';
import 'package:dndn/features/reports/presentation/widgets/trip_list_item.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onNavigateToTracking;
  final VoidCallback onNavigateToReports;

  const DashboardPage({
    super.key,
    required this.onNavigateToTracking,
    required this.onNavigateToReports,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const LoadDashboardMetricsEvent());
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          ThemeSwitchButton(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          int totalTrips = 0;
          double totalDistanceMeters = 0.0;
          int totalDurationSeconds = 0;

          if (state is ReportsLoaded) {
            final metrics = state.dashboardMetrics;
            totalTrips = metrics['totalTrips'] as int? ?? state.trips.length;
            totalDistanceMeters =
                (metrics['totalDistanceMeters'] as num?)?.toDouble() ?? 0.0;
            totalDurationSeconds = metrics['totalDurationSeconds'] as int? ?? 0;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReportsBloc>().add(const LoadDashboardMetricsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Banner ────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ready to Track?',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Real-time GPS route recording with background tracking support.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: widget.onNavigateToTracking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text(
                                  'START TRACKING',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.navigation_outlined,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'All-Time Statistics',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ── Metrics Row / Grid ─────────────────────────────────────
                  MetricCard(
                    title: 'TOTAL DISTANCE',
                    value: AppFormatters.formatDistance(totalDistanceMeters),
                    icon: Icons.straighten_rounded,
                    accentColor: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'TOTAL TRIPS',
                          value: '$totalTrips',
                          icon: Icons.alt_route_rounded,
                          accentColor: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          title: 'ACTIVE TIME',
                          value:
                              AppFormatters.formatDuration(totalDurationSeconds),
                          icon: Icons.timer_outlined,
                          accentColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Recent Trips ───────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Trips',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToReports,
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  if (state is ReportsLoaded && state.trips.isNotEmpty)
                    ...state.trips.take(3).map(
                          (t) => TripListItem(
                            trip: t,
                            onTap: widget.onNavigateToReports,
                            onDelete: () {
                              context
                                  .read<ReportsBloc>()
                                  .add(DeleteTripEvent(t.id));
                            },
                          ),
                        )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No trips completed yet.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Recent Incidents ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Incidents',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToReports,
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (state is ReportsLoaded &&
                      state.incidentReports.isNotEmpty)
                    ...state.incidentReports.take(3).map((incident) {
                      final color = _incidentColor(incident.type);
                      final icon = _incidentIcon(incident.type);
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  IncidentDetailPage(incident: incident),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.25),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      incident.type.displayName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year}'
                                      '  ${incident.timestamp.hour.toString().padLeft(2, '0')}:${incident.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No incidents reported yet.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
