import 'package:flutter/material.dart';
import 'package:dndn/core/utils/formatters.dart';

class TrackingHudCard extends StatelessWidget {
  final int elapsedSeconds;
  final double distanceMeters;
  final double currentSpeedKmh;
  final double maxSpeedKmh;
  final bool isPaused;

  const TrackingHudCard({
    super.key,
    required this.elapsedSeconds,
    required this.distanceMeters,
    required this.currentSpeedKmh,
    required this.maxSpeedKmh,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPaused)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PAUSED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context: context,
                  label: 'DURATION',
                  value: AppFormatters.formatDuration(elapsedSeconds),
                  icon: Icons.timer_outlined,
                  color: Colors.blueAccent,
                ),
                _buildDivider(),
                _buildStatItem(
                  context: context,
                  label: 'DISTANCE',
                  value: AppFormatters.formatDistance(distanceMeters),
                  icon: Icons.straighten_outlined,
                  color: Colors.green,
                ),
                _buildDivider(),
                _buildStatItem(
                  context: context,
                  label: 'SPEED',
                  value: AppFormatters.formatSpeed(currentSpeedKmh),
                  icon: Icons.speed_outlined,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}
