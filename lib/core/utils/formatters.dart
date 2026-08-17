abstract class AppFormatters {
  /// Formats distance in meters to a readable string (e.g., "450 m" or "2.35 km").
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final double km = meters / 1000.0;
    return '${km.toStringAsFixed(2)} km';
  }

  /// Formats speed in km/h to a readable string (e.g., "12.4 km/h").
  static String formatSpeed(double speedKmh) {
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  /// Formats seconds into HH:mm:ss or mm:ss string.
  static String formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  /// Formats DateTime to readable date & time (e.g., "2026-08-17 10:15").
  static String formatDateTime(DateTime dateTime) {
    final String y = dateTime.year.toString();
    final String m = dateTime.month.toString().padLeft(2, '0');
    final String d = dateTime.day.toString().padLeft(2, '0');
    final String h = dateTime.hour.toString().padLeft(2, '0');
    final String min = dateTime.minute.toString().padLeft(2, '0');

    return '$y-$m-$d $h:$min';
  }
}
