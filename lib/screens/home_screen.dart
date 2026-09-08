import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  final bool running, alarmRinging;
  final double sensitivity, liveX, liveY, liveZ, liveMag;
  final AnimationController pulseController;
  final VoidCallback onToggle, onStopAlarm;
  final ValueChanged<double> onSensitivityChanged;

  const HomeScreen({
    super.key,
    required this.running,
    required this.alarmRinging,
    required this.sensitivity,
    required this.liveX,
    required this.liveY,
    required this.liveZ,
    required this.liveMag,
    required this.pulseController,
    required this.onToggle,
    required this.onStopAlarm,
    required this.onSensitivityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D1A), Color(0xFF0A0A0F)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.security, color: Color(0xFF6C63FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Motion Guard',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3)),
                      Text(
                        running ? 'System Active' : 'System Standby',
                        style: TextStyle(
                          fontSize: 12,
                          color: running
                              ? const Color(0xFF00D4AA)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Animated status orb
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  final pulse = Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut));
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (running)
                        ...List.generate(3, (i) {
                          final delay = i * 0.33;
                          final v = ((pulse.value + delay) % 1.0);
                          return Container(
                            width: 160 + v * 80,
                            height: 160 + v * 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: alarmRinging
                                    ? Colors.redAccent.withOpacity(0.6 - v * 0.6)
                                    : const Color(0xFF6C63FF).withOpacity(0.5 - v * 0.5),
                                width: 1.5,
                              ),
                            ),
                          );
                        }),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: alarmRinging
                                ? [Colors.red.shade700, Colors.red.shade900.withOpacity(0.4)]
                                : running
                                    ? [const Color(0xFF6C63FF), const Color(0xFF3D37BF).withOpacity(0.4)]
                                    : [const Color(0xFF2A2A3A), const Color(0xFF1A1A28).withOpacity(0.4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (alarmRinging
                                  ? Colors.red
                                  : running
                                      ? const Color(0xFF6C63FF)
                                      : Colors.grey.shade800).withOpacity(running ? 0.4 + pulse.value * 0.3 : 0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              alarmRinging
                                  ? Icons.notification_important_rounded
                                  : running
                                      ? Icons.sensors
                                      : Icons.sensors_off,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alarmRinging
                                  ? 'ALARM!'
                                  : running
                                      ? 'ACTIVE'
                                      : 'STANDBY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),

              // Stop Alarm Button (only when ringing)
              if (alarmRinging) ...[
                GlassButton(
                  onTap: onStopAlarm,
                  label: 'STOP ALARM',
                  icon: Icons.volume_off_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF4646), Color(0xFFBB0000)]),
                  glowColor: Colors.red,
                ),
                const SizedBox(height: 16),
              ],

              // Start/Stop button
              GlassButton(
                onTap: onToggle,
                label: running ? 'STOP MONITORING' : 'START MONITORING',
                icon: running ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                gradient: LinearGradient(
                  colors: running
                      ? [Colors.grey.shade700, Colors.grey.shade900]
                      : [const Color(0xFF6C63FF), const Color(0xFF3D37BF)],
                ),
                glowColor: running ? Colors.grey : const Color(0xFF6C63FF),
              ),

              const SizedBox(height: 32),

              // Sensitivity card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF6C63FF), size: 18),
                        const SizedBox(width: 8),
                        const Text('Sensitivity',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _sensitivityLabel(sensitivity),
                            style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF6C63FF),
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: const Color(0xFF6C63FF),
                        overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: sensitivity,
                        min: 2.0,
                        max: 7.0,
                        divisions: 10,
                        onChanged: onSensitivityChanged,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('High', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        Text('Low', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live sensor card (only when running)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: running
                    ? GlassCard(
                        key: const ValueKey('live'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.show_chart, color: Color(0xFF00D4AA), size: 18),
                                const SizedBox(width: 8),
                                const Text('Live Sensors',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                const Spacer(),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00D4AA),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                SensorBar(label: 'X', value: liveX, color: Colors.redAccent),
                                const SizedBox(width: 10),
                                SensorBar(label: 'Y', value: liveY, color: Colors.greenAccent),
                                const SizedBox(width: 10),
                                SensorBar(label: 'Z', value: liveZ, color: const Color(0xFF6C63FF)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Motion Magnitude',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                Text(
                                  liveMag.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: liveMag > sensitivity
                                        ? Colors.redAccent
                                        : const Color(0xFF00D4AA),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (liveMag / (sensitivity * 2)).clamp(0, 1),
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation(
                                  liveMag > sensitivity ? Colors.redAccent : const Color(0xFF00D4AA),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _sensitivityLabel(double v) {
    if (v <= 3.0) return 'Very High';
    if (v <= 4.0) return 'High';
    if (v <= 5.0) return 'Medium';
    if (v <= 6.0) return 'Low';
    return 'Very Low';
  }
}
