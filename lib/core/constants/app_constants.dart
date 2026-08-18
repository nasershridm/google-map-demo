abstract class AppConstants {
  // App
  static const String appName = 'Location Tracker';

  // Tracking Configuration
  static const double minDistanceFilterMeters = 5.0;
  static const int minDistanceFilterMetersInt = 5;
  static const double maxAcceptedGpsAccuracyMeters = 25.0;
  static const int locationIntervalMillis = 3000;

  // Database
  static const String databaseName = 'location_tracking.db';
  static const int databaseVersion = 2;

  // Foreground Service / Notification
  static const String notificationChannelId = 'location_tracking_channel';
  static const String notificationChannelName = 'Location Tracking Service';
  static const String notificationChannelDescription =
      'Notification channel for background location tracking';
  static const int notificationId = 888;
}
