import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:dndn/core/constants/app_constants.dart';

@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

class TrackingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Background tracking initialized
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Periodic repeat event
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Cleanup background service resources
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final String text =
          data['notificationText'] as String? ?? 'Tracking active...';
      FlutterForegroundTask.updateService(
        notificationTitle: AppConstants.notificationChannelName,
        notificationText: text,
      );
    }
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {}
}

class ForegroundServiceManager {
  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.notificationChannelId,
        channelName: AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          AppConstants.locationIntervalMillis,
        ),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<bool> startService({required String tripId}) async {
    // Request POST_NOTIFICATIONS permission on Android 13+
    try {
      final NotificationPermission status =
          await FlutterForegroundTask.checkNotificationPermission();
      if (status != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DNDN_SERVICE] Error checking notification permission: $e');
    }

    if (await FlutterForegroundTask.isRunningService) {
      // ignore: avoid_print
      print('[DNDN_SERVICE] Foreground service is already running.');
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: AppConstants.notificationId,
      notificationTitle: 'دندن - Live Tracking',
      notificationText: 'Live GPS route tracking is active...',
      callback: startForegroundCallback,
    );

    final success = result is ServiceRequestSuccess;
    // ignore: avoid_print
    print('[DNDN_SERVICE] FlutterForegroundTask.startService result: $result (success: $success)');
    return success;
  }

  static Future<bool> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      final result = await FlutterForegroundTask.stopService();
      return result is ServiceRequestSuccess;
    }
    return true;
  }

  static void updateNotification({
    required String title,
    required String text,
  }) {
    FlutterForegroundTask.sendDataToTask({
      'notificationTitle': title,
      'notificationText': text,
    });
  }
}
