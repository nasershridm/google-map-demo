import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/di/injection.dart';
import 'package:dndn/core/theme/theme_switch_button.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';
import 'package:dndn/features/reports/domain/entities/trip.dart';
import 'package:dndn/features/reports/domain/use_cases/trip_use_cases.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_event.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_state.dart';
import 'package:dndn/features/reports/presentation/pages/incident_detail_page.dart';
import 'package:dndn/features/reports/presentation/pages/trip_detail_page.dart';
import 'package:dndn/features/reports/presentation/widgets/trip_list_item.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReportsBloc>().add(const LoadTripsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openTripDetail(BuildContext context, Trip trip) async {
    final navigator = Navigator.of(context);
    final fullTrip = trip.points.isNotEmpty
        ? trip
        : await getIt<GetTripByIdUseCase>()(trip.id) ?? trip;

    if (!context.mounted) return;
    navigator.push(
      MaterialPageRoute(builder: (_) => TripDetailPage(trip: fullTrip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trip History & Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          ThemeSwitchButton(),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.route_rounded), text: 'Trips'),
            Tab(icon: Icon(Icons.report_rounded), text: 'Incidents'),
          ],
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ReportsBloc>().add(const LoadTripsEvent()),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            );
          }

          if (state is ReportsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _TripsTab(
                  trips: state.trips,
                  onTripTap: (t) => _openTripDetail(context, t),
                  onDelete: (id) =>
                      context.read<ReportsBloc>().add(DeleteTripEvent(id)),
                  onRefresh: () =>
                      context.read<ReportsBloc>().add(const LoadTripsEvent()),
                ),
                _IncidentsTab(
                  incidents: state.incidentReports,
                  onDelete: (id) => context.read<ReportsBloc>().add(
                    DeleteIncidentReportEvent(id),
                  ),
                  onRefresh: () =>
                      context.read<ReportsBloc>().add(const LoadTripsEvent()),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Trips Tab ─────────────────────────────────────────────────────────────────
class _TripsTab extends StatelessWidget {
  final List<Trip> trips;
  final void Function(Trip) onTripTap;
  final void Function(String) onDelete;
  final VoidCallback onRefresh;

  const _TripsTab({
    required this.trips,
    required this.onTripTap,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.map_outlined, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'No Trips Recorded Yet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first GPS tracking session from the Tracking tab!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return TripListItem(
            trip: trip,
            onTap: () => onTripTap(trip),
            onDelete: () => onDelete(trip.id),
          );
        },
      ),
    );
  }
}

// ── Incidents Tab ──────────────────────────────────────────────────────────────
class _IncidentsTab extends StatelessWidget {
  final List<IncidentReport> incidents;
  final void Function(int) onDelete;
  final VoidCallback onRefresh;

  const _IncidentsTab({
    required this.incidents,
    required this.onDelete,
    required this.onRefresh,
  });

  Color _typeColor(IncidentType type) {
    switch (type) {
      case IncidentType.police:
        return const Color(0xFF1A73E8);
      case IncidentType.accident:
        return const Color(0xFFE53935);
      case IncidentType.traffic:
        return const Color(0xFFF57C00);
    }
  }

  IconData _typeIcon(IncidentType type) {
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

    if (incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.report_off_outlined, size: 64, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              'No Incidents Reported',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the 🚨 button during tracking to report incidents on the map.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          final incident = incidents[index];
          final color = _typeColor(incident.type);
          final icon = _typeIcon(incident.type);

          return Dismissible(
            key: ValueKey(incident.id ?? index),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            onDismissed: (_) {
              if (incident.id != null) onDelete(incident.id!);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IncidentDetailPage(incident: incident),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                title: Text(
                  incident.type.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      '${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year}  ${incident.timestamp.hour.toString().padLeft(2, '0')}:${incident.timestamp.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'GPS: ${incident.latitude.toStringAsFixed(5)}, ${incident.longitude.toStringAsFixed(5)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    if (incident.notes != null && incident.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          incident.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        incident.type.arabicName,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
