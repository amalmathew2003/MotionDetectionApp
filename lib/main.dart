import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupNotificationChannel();
  await initializeService();
  runApp(const MaterialApp(home: GuardApp()));
}

/// ✅ Create a notification channel (Android 12+ requirement)
Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
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

/// ✅ Configure background service
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

/// ✅ Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final player = AudioPlayer();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  List<double> last = [0, 0, 0];
  const double threshold = 3.5;
  int lastTrigger = 0;
  Timer? stopTimer;

  accelerometerEvents.listen((event) async {
    final dx = event.x - last[0];
    final dy = event.y - last[1];
    final dz = event.z - last[2];
    last = [event.x, event.y, event.z];
    final mag = sqrt(dx * dx + dy * dy + dz * dz);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (mag > threshold && now - lastTrigger > 4000) {
      lastTrigger = now;

      // ✅ Start alarm sound
      await player.setVolume(1.0);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('audio/alarm.mp3'));

      // 🔔 Auto-stop alarm after 10 seconds
      stopTimer?.cancel();
      stopTimer = Timer(const Duration(seconds: 10), () async {
        await player.stop();
      });
    }
  });

  // ✅ Stop alarm when main app resumes (e.g., phone unlock)
  service.on('stopAlarm').listen((event) async {
    await player.stop();
  });

  // ✅ Stop service manually
  service.on('stopService').listen((event) async {
    stopTimer?.cancel();
    await player.stop();
    service.stopSelf();
  });
}

/// ✅ Main app UI
class GuardApp extends StatefulWidget {
  const GuardApp({super.key});

  @override
  State<GuardApp> createState() => _GuardAppState();
}

class _GuardAppState extends State<GuardApp> with WidgetsBindingObserver {
  bool running = false;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ When phone unlocks → tell background service to stop alarm
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      service.invoke('stopAlarm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motion Guard'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              running ? "Monitoring in background..." : "Stopped",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!running) {
                  await service.startService();
                } else {
                  service.invoke("stopService");
                }
                setState(() => running = !running);
              },
              child: Text(running ? "Stop Monitoring" : "Start Monitoring"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final testPlayer = AudioPlayer();
                await testPlayer.setVolume(1.0);
                await testPlayer.play(AssetSource('audio/alarm.mp3'));
              },
              child: const Text("Test Alarm Sound"),
            ),
          ],
        ),
      ),
    );
  }
}
