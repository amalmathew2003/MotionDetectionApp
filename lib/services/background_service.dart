import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupNotificationChannel() async {
  const channel = AndroidNotificationChannel(
    'motion_guard_channel',
    'Motion Guard Service',
    description: 'Monitors device motion in background',
    importance: Importance.low,
  );
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(channel);
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'motion_guard_channel',
      initialNotificationTitle: 'Motion Guard Active',
      initialNotificationContent: 'Monitoring motion...',
      foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final player = AudioPlayer();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  List<double> last = [0, 0, 0];
  bool isInitialized = false;
  double threshold = 3.5;
  String alarmSound = 'audio/alarm.mp3';
  int lastTrigger = 0;
  int detectionCount = 0;
  Timer? stopTimer;

  // Delay initial detection to avoid false positives on start
  Future.delayed(const Duration(seconds: 2), () => isInitialized = true);

  service.on('updateSensitivity').listen((event) {
    if (event != null && event['value'] != null) {
      threshold = (event['value'] as num).toDouble();
    }
  });

  service.on('updateAlarmSound').listen((event) {
    if (event != null && event['sound'] != null) {
      alarmSound = event['sound'] as String;
    }
  });

  service.on('stopAlarm').listen((event) async {
    stopTimer?.cancel();
    await player.stop();
  });

  service.on('stopService').listen((event) async {
    stopTimer?.cancel();
    await player.stop();
    service.stopSelf();
  });

  accelerometerEventStream().listen((event) async {
    if (!isInitialized) {
      last = [event.x, event.y, event.z];
      return;
    }

    final dx = event.x - last[0];
    final dy = event.y - last[1];
    final dz = event.z - last[2];
    last = [event.x, event.y, event.z];

    final mag = sqrt(dx * dx + dy * dy + dz * dz);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (mag > threshold && now - lastTrigger > 4000) {
      lastTrigger = now;
      detectionCount++;

      service.invoke('motionDetected', {
        'time': DateTime.now().toIso8601String(),
        'magnitude': mag,
        'count': detectionCount,
      });

      await player.setVolume(1.0);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(alarmSound));

      stopTimer?.cancel();
      stopTimer = Timer(const Duration(seconds: 10), () async {
        await player.stop();
      });
    }

    service.invoke('sensorData', {
      'x': event.x,
      'y': event.y,
      'z': event.z,
      'magnitude': mag,
    });
  });
}
