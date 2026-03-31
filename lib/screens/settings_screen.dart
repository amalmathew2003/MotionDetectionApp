import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatelessWidget {
  final double sensitivity;
  final String alarmSound;
  final List<String> soundOptions, soundLabels;
  final ValueChanged<double> onSensitivityChanged;
  final ValueChanged<String> onSoundChanged;

  const SettingsScreen({
    super.key,
    required this.sensitivity,
    required this.alarmSound,
    required this.soundOptions,
    required this.soundLabels,
    required this.onSensitivityChanged,
    required this.onSoundChanged,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 10),
                  const Text('Settings',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 28),

              const SectionLabel('Detection'),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF6C63FF), size: 16),
                        const SizedBox(width: 8),
                        const Text('Motion Sensitivity',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(sensitivity.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Color(0xFF6C63FF), fontWeight: FontWeight.w700)),
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
                        Text('More sensitive (2.0)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                        Text('Less sensitive (7.0)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const SectionLabel('Alarm Sound'),
              GlassCard(
                child: Column(
                  children: List.generate(soundOptions.length, (i) {
                    final isSelected = alarmSound == soundOptions[i];
                    return GestureDetector(
                      onTap: () => onSoundChanged(soundOptions[i]),
                      child: Container(
                        margin: EdgeInsets.only(bottom: i < soundOptions.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF).withOpacity(0.15)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF).withOpacity(0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              soundLabels[i],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade400,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF6C63FF), size: 18)
                            else
                              TestSoundButton(soundPath: soundOptions[i]),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),
              const SectionLabel('About'),
              const GlassCard(
                child: Column(
                  children: [
                    InfoRow(label: 'App Version', value: '2.0.0'),
                    SizedBox(height: 12),
                    InfoRow(label: 'Detection Mode', value: 'Accelerometer'),
                    SizedBox(height: 12),
                    InfoRow(label: 'Background Service', value: 'Enabled'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
