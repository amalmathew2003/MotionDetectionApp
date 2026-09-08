import 'package:flutter/material.dart';
import '../models/detection_event.dart';

class HistoryScreen extends StatelessWidget {
  final List<DetectionEvent> history;
  const HistoryScreen({super.key, required this.history});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 10),
                  const Text('Detection History',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${history.length} events',
                      style: const TextStyle(
                          color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: history.isEmpty
                  ? const _EmptyHistory()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: history.length,
                      itemBuilder: (context, i) {
                        final e = history[i];
                        return _HistoryTile(event: e, index: i);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text('No detections yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Start monitoring to see events here',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final DetectionEvent event;
  final int index;
  const _HistoryTile({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}:${event.time.second.toString().padLeft(2, '0')}';
    final dateStr =
        '${event.time.day.toString().padLeft(2, '0')}/${event.time.month.toString().padLeft(2, '0')}/${event.time.year}';
    final isStrong = event.magnitude > 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStrong
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isStrong ? Colors.redAccent : const Color(0xFF6C63FF))
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isStrong ? Icons.warning_amber_rounded : Icons.motion_photos_on,
              color: isStrong ? Colors.redAccent : const Color(0xFF6C63FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStrong ? 'Strong Motion' : 'Motion Detected',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '$dateStr  $timeStr',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.magnitude.toStringAsFixed(1),
                style: TextStyle(
                  color: isStrong ? Colors.redAccent : const Color(0xFF00D4AA),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text('mag', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
