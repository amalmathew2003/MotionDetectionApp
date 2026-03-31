import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/detection_event.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool running = false;
  double sensitivity = 3.5;
  String alarmSound = 'audio/alarm.mp3';
  bool alarmRinging = false;
  final service = FlutterBackgroundService();
  final List<DetectionEvent> history = [];
  double liveX = 0, liveY = 0, liveZ = 0, liveMag = 0;
  StreamSubscription? _motionSub;
  StreamSubscription? _sensorSub;
  late AnimationController _pulseController;

  final List<String> _soundOptions = [
    'audio/alarm.mp3',
    'audio/mixkit-facility-alarm-sound-999.wav',
    'audio/comedy_dialouge.mp3',
  ];
  final List<String> _soundLabels = ['Classic Alarm', 'Facility Siren', 'Comedy'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _requestPermissions();
    _listenToService();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  void _listenToService() {
    _motionSub = service.on('motionDetected').listen((event) {
      if (event == null) return;
      setState(() {
        alarmRinging = true;
        history.insert(
          0,
          DetectionEvent(
            time: DateTime.parse(event['time'] as String),
            magnitude: (event['magnitude'] as num).toDouble(),
          ),
        );
        if (history.length > 50) history.removeLast();
      });
      Future.delayed(const Duration(seconds: 11), () {
        if (mounted) setState(() => alarmRinging = false);
      });
    });

    _sensorSub = service.on('sensorData').listen((event) {
      if (event == null || !mounted) return;
      setState(() {
        liveX = (event['x'] as num).toDouble();
        liveY = (event['y'] as num).toDouble();
        liveZ = (event['z'] as num).toDouble();
        liveMag = (event['magnitude'] as num).toDouble();
      });
    });
  }

  @override
  void dispose() {
    _motionSub?.cancel();
    _sensorSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleService() async {
    if (!running) {
      await service.startService();
      service.invoke('updateSensitivity', {'value': sensitivity});
      service.invoke('updateAlarmSound', {'sound': alarmSound});
    } else {
      service.invoke('stopService');
      setState(() => alarmRinging = false);
    }
    setState(() => running = !running);
  }

  void _stopAlarm() {
    service.invoke('stopAlarm');
    setState(() => alarmRinging = false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        running: running,
        alarmRinging: alarmRinging,
        sensitivity: sensitivity,
        liveX: liveX,
        liveY: liveY,
        liveZ: liveZ,
        liveMag: liveMag,
        pulseController: _pulseController,
        onToggle: _toggleService,
        onStopAlarm: _stopAlarm,
        onSensitivityChanged: (v) {
          setState(() => sensitivity = v);
          service.invoke('updateSensitivity', {'value': v});
        },
      ),
      HistoryScreen(history: history),
      SettingsScreen(
        sensitivity: sensitivity,
        alarmSound: alarmSound,
        soundOptions: _soundOptions,
        soundLabels: _soundLabels,
        onSensitivityChanged: (v) {
          setState(() => sensitivity = v);
          if (running) service.invoke('updateSensitivity', {'value': v});
        },
        onSoundChanged: (s) {
          setState(() => alarmSound = s);
          if (running) service.invoke('updateAlarmSound', {'sound': s});
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield, label: 'Guard', index: 0, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'History', index: 1, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.tune_outlined, activeIcon: Icons.tune, label: 'Settings', index: 2, currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C63FF).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF6C63FF) : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF6C63FF) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
