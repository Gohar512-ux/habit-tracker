import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/habit_options.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import 'add_edit_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text(
          '"${habit.name}" and its entire history will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<HabitProvider>().delete(habit.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        showAppSnack(context, 'Could not delete habit.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitProvider>().byId(habitId);
    if (habit == null) return const Scaffold(body: SizedBox.shrink());

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = HabitOptions.colorAt(habit.colorIndex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditHabitScreen(habit: habit),
                fullscreenDialog: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            onPressed: () => _confirmDelete(context, habit),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(HabitOptions.iconAt(habit.iconIndex),
                      color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _scheduleLabel(habit.weekdays),
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (habit.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                habit.description,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                _Stat(label: 'Current', value: '${habit.currentStreak}', unit: 'days'),
                const SizedBox(width: 10),
                _Stat(label: 'Best', value: '${habit.bestStreak}', unit: 'days'),
                const SizedBox(width: 10),
                _Stat(
                  label: '30 days',
                  value: '${(habit.completionRate() * 100).round()}',
                  unit: '%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Last 5 weeks',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SurfaceCard(child: _HistoryGrid(habit: habit, color: color)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${habit.totalCheckIns} total check-ins · since ${DateFormat('d MMM yyyy').format(habit.createdAt)}',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scheduleLabel(List<int> days) {
    if (days.length == 7) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = [...days]..sort();
    if (sorted.length == 5 && sorted.every((d) => d <= 5)) return 'Weekdays';
    if (sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7) return 'Weekends';
    return sorted.map((d) => names[d - 1]).join(', ');
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Text(unit,
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.habit, required this.color});
  final Habit habit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final today = DateHelpers.today();
    final gridStart = DateHelpers.addDays(DateHelpers.startOfWeek(today), -28);

    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Center(
                child: Text(
                  AppConstants.weekdayLetters[i],
                  style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var week = 0; week < 5; week++)
          Padding(
            padding: EdgeInsets.only(bottom: week == 4 ? 0 : 6),
            child: Row(
              children: List.generate(7, (d) {
                final day = DateHelpers.addDays(gridStart, week * 7 + d);
                final future = day.isAfter(today);
                final scheduled = habit.isScheduledOn(day);
                final done = habit.isDoneOn(day);

                Color fill;
                if (done) {
                  fill = color;
                } else if (future || !scheduled) {
                  fill = Colors.transparent;
                } else {
                  fill = scheme.surfaceContainerHighest;
                }

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: d == 6 ? 0 : 6),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(8),
                          border: (future || !scheduled) && !done
                              ? Border.all(
                                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: DateHelpers.isSameDay(day, today)
                            ? Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done ? Colors.white : scheme.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
