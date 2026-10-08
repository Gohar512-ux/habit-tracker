import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.done,
    required this.total,
    required this.isToday,
  });

  final int done;
  final int total;
  final bool isToday;

  String get _headline {
    if (total == 0) return 'Nothing scheduled';
    if (done == total) return isToday ? "You're all done for today" : 'Perfect day';
    final left = total - done;
    return '$left ${left == 1 ? 'habit' : 'habits'} to go';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ratio = total == 0 ? 0.0 : done / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isToday ? "Today's progress" : 'Progress',
                  style: text.labelLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(ratio * 100).round()}%',
                style: text.titleLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _headline,
            style: text.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: scheme.onPrimary.withValues(alpha: 0.22),
                valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$done of $total completed',
            style: text.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
