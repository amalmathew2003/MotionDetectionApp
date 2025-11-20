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
        AndroidFlutterLocalNotificationsPlugin
      >();

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
  bool isInitialized = false; // NEW 🔥
  const double threshold = 3.5;
  int lastTrigger = 0;
  Timer? stopTimer;

  // 🔥 Wait 2 seconds before enabling detection
  Future.delayed(const Duration(seconds: 2), () {
    isInitialized = true;
  });

  accelerometerEvents.listen((event) async {
    // 🔥 Ignore first few events
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

    // 🔥 Prevent false alarm right after starting
    if (mag > threshold && now - lastTrigger > 4000) {
      lastTrigger = now;

      // Start alarm
      await player.setVolume(1.0);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('audio/alarm.mp3'));

      // Stop automatically after 10 seconds
      stopTimer?.cancel();
      stopTimer = Timer(const Duration(seconds: 10), () async {
        await player.stop();
      });
    }
  });

  // Stop alarm when app resumes
  service.on('stopAlarm').listen((event) async {
    await player.stop();
  });

  // Stop whole service
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

class _GuardAppState extends State<GuardApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool running = false;
  double sensitivity = 3.5; // default threshold
  final service = FlutterBackgroundService();

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    glowController.dispose();
    super.dispose();
  }

  /// Stop alarm when app opens again
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      service.invoke('stopAlarm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final glow = Tween(begin: 0.2, end: 0.9).animate(glowController);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Motion Guard"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status Circle
          AnimatedBuilder(
            animation: glowController,
            builder: (context, _) {
              return Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: running
                      ? Colors.green.withOpacity(glow.value)
                      : Colors.red.withOpacity(0.6),
                  boxShadow: running
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.7),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    running ? "ACTIVE" : "STOPPED",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Start/Stop Button
          GestureDetector(
            onTap: () async {
              if (!running) {
                await service.startService();
              } else {
                service.invoke('stopService');
              }
              setState(() => running = !running);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: running
                      ? [Colors.redAccent, Colors.red]
                      : [Colors.greenAccent, Colors.green],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                running ? "STOP MONITORING" : "START MONITORING",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Sensitivity Slider
          Column(
            children: [
              const Text(
                "Sensitivity",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: sensitivity,
                min: 2.0,
                max: 7.0,
                divisions: 5,
                label: sensitivity.toStringAsFixed(1),
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  setState(() {
                    sensitivity = value;
                  });

                  // send value to background service (optional)
                  service.invoke("updateSensitivity", {"value": value});
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Test Sound
          TextButton(
            onPressed: () async {
              final testPlayer = AudioPlayer();
              await testPlayer.play(AssetSource("audio/alarm.mp3"));
            },
            child: const Text(
              "Test Alarm",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
