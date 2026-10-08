import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/habit_options.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../models/habit.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.date,
    required this.onToggle,
    required this.onTap,
  });

  final Habit habit;
  final DateTime date;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = HabitOptions.colorAt(habit.colorIndex);
    final done = habit.isDoneOn(date);
    final streak = habit.currentStreak;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(HabitOptions.iconAt(habit.iconIndex), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? scheme.onSurfaceVariant : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: streak > 0 ? const Color(0xFFEA580C) : scheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streak == 0
                          ? 'No streak yet'
                          : '$streak ${streak == 1 ? 'day' : 'days'} streak',
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: done ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done ? color : scheme.outline,
                    width: 1.8,
                  ),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: done ? 1 : 0,
                  child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
