import 'package:flutter/material.dart';
import 'package:dndn/features/reports/domain/entities/incident_report.dart';

/// Bottom sheet for submitting a new incident report.
/// Shows 3 incident type cards (Police, Accident, Traffic) with Arabic labels.
class IncidentReportBottomSheet extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? tripId;

  const IncidentReportBottomSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    this.tripId,
  });

  /// Shows the sheet and returns the submitted [IncidentReport] or null.
  static Future<IncidentReport?> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String? tripId,
  }) {
    return showModalBottomSheet<IncidentReport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IncidentReportBottomSheet(
        latitude: latitude,
        longitude: longitude,
        tripId: tripId,
      ),
    );
  }

  @override
  State<IncidentReportBottomSheet> createState() =>
      _IncidentReportBottomSheetState();
}

class _IncidentReportBottomSheetState
    extends State<IncidentReportBottomSheet> {
  IncidentType? _selectedType;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedType == null) return;

    final report = IncidentReport(
      type: _selectedType!,
      tripId: widget.tripId,
      latitude: widget.latitude,
      longitude: widget.longitude,
      timestamp: DateTime.now(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.report_rounded,
                  color: cs.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Incident',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Select incident type',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Incident type cards
          Row(
            children: [
              _IncidentTypeCard(
                type: IncidentType.police,
                icon: Icons.local_police_rounded,
                color: const Color(0xFF1A73E8),
                isSelected: _selectedType == IncidentType.police,
                onTap: () => setState(() => _selectedType = IncidentType.police),
              ),
              const SizedBox(width: 10),
              _IncidentTypeCard(
                type: IncidentType.accident,
                icon: Icons.car_crash_rounded,
                color: const Color(0xFFE53935),
                isSelected: _selectedType == IncidentType.accident,
                onTap: () =>
                    setState(() => _selectedType = IncidentType.accident),
              ),
              const SizedBox(width: 10),
              _IncidentTypeCard(
                type: IncidentType.traffic,
                icon: Icons.traffic_rounded,
                color: const Color(0xFFF57C00),
                isSelected: _selectedType == IncidentType.traffic,
                onTap: () =>
                    setState(() => _selectedType = IncidentType.traffic),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Optional notes field
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Additional notes (optional)',
              prefixIcon: const Icon(Icons.note_alt_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit / Cancel
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _selectedType != null ? _submit : null,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
class _IncidentTypeCard extends StatelessWidget {
  final IncidentType type;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _IncidentTypeCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : theme.colorScheme.onSurfaceVariant, size: 28),
              const SizedBox(height: 6),
              Text(
                type.arabicName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                type.name[0].toUpperCase() + type.name.substring(1),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: (isSelected ? color : theme.colorScheme.onSurfaceVariant)
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
