import 'package:flutter/material.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TrackingControls({
    super.key,
    required this.isTracking,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTracking) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: const Text(
            'START TRACKING',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Pause / Resume Button
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: isPaused ? onResume : onPause,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isPaused ? Colors.green : Colors.orange,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? Colors.green : Colors.orange,
                size: 24,
              ),
              label: Text(
                isPaused ? 'RESUME' : 'PAUSE',
                style: TextStyle(
                  color: isPaused ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Stop Button
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _confirmStop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.stop_rounded, size: 24),
              label: const Text(
                'FINISH TRIP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish Tracking?'),
        content: const Text(
          'Are you sure you want to stop and save this trip session?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('FINISH'),
          ),
        ],
      ),
    );
  }
}
