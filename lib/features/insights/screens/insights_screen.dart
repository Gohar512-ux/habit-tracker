import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/habit_options.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../providers/habit_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;

    if (habits.isEmpty) {
      return const SafeArea(
        child: Center(
          child: EmptyState(
            icon: Icons.insights_rounded,
            title: 'No insights yet',
            message: 'Add a habit and check in for a few days to see your trends.',
          ),
        ),
      );
    }

    final today = DateHelpers.today();
    final days = List.generate(7, (i) => DateHelpers.addDays(today, i - 6));
    final daily = days.map(provider.progressFor).toList();
    final weekDone = daily.fold<int>(0, (s, p) => s + p.done);
    final weekTotal = daily.fold<int>(0, (s, p) => s + p.total);
    final weekRate = weekTotal == 0 ? 0 : (weekDone / weekTotal * 100).round();
    final bestCurrent = habits.map((h) => h.currentStreak).fold<int>(0, math.max);
    final totalCheckIns = habits.fold<int>(0, (s, h) => s + h.totalCheckIns);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Insights',
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How your routines are trending',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MetricCard(
                icon: Icons.task_alt_rounded,
                label: '7-day rate',
                value: '$weekRate%',
              ),
              const SizedBox(width: 12),
              _MetricCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Top streak',
                value: '$bestCurrent d',
                iconColor: const Color(0xFFEA580C),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricCard(
                icon: Icons.checklist_rounded,
                label: 'Active habits',
                value: '${habits.length}',
              ),
              const SizedBox(width: 12),
              _MetricCard(
                icon: Icons.done_all_rounded,
                label: 'Check-ins',
                value: '$totalCheckIns',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('This week',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
            child: SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final p = daily[i];
                  final ratio = p.total == 0 ? 0.0 : p.done / p.total;
                  final isToday = DateHelpers.isSameDay(days[i], today);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: ratio),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => FractionallySizedBox(
                                heightFactor: math.max(v, 0.04),
                                child: Container(
                                  width: 22,
                                  decoration: BoxDecoration(
                                    color: v == 0
                                        ? scheme.surfaceContainerHighest
                                        : scheme.primary.withValues(
                                            alpha: isToday ? 1 : 0.55),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('E').format(days[i]).substring(0, 1),
                          style: text.labelSmall?.copyWith(
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Consistency · last 30 days',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...habits.map((h) {
            final rate = h.completionRate();
            final color = HabitOptions.colorAt(h.colorIndex);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(HabitOptions.iconAt(h.iconIndex), color: color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            h.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${(rate * 100).round()}%',
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 6,
                        color: color,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor ?? scheme.primary),
            const SizedBox(height: 14),
            Text(
              value,
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
