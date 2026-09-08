import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: child,
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;

  const GlassButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const SensorBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = (value.abs() / 20).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 60 * clamped,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(1),
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class TestSoundButton extends StatelessWidget {
  final String soundPath;
  const TestSoundButton({super.key, required this.soundPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final player = AudioPlayer();
        await player.play(AssetSource(soundPath));
        Future.delayed(const Duration(seconds: 3), () => player.stop());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white60, size: 14),
            SizedBox(width: 4),
            Text('Test', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
