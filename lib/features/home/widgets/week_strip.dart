import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_helpers.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final today = DateHelpers.today();
    final start = DateHelpers.startOfWeek(today);

    return Row(
      children: List.generate(7, (i) {
        final day = DateHelpers.addDays(start, i);
        final isSelected = DateHelpers.isSameDay(day, selected);
        final isFuture = day.isAfter(today);
        final isToday = DateHelpers.isSameDay(day, today);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 8),
            child: GestureDetector(
              onTap: isFuture ? null : () => onSelect(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? scheme.primary
                        : isToday
                            ? scheme.primary.withValues(alpha: 0.5)
                            : scheme.outlineVariant,
                  ),
                ),
                child: Opacity(
                  opacity: isFuture ? 0.4 : 1,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day).substring(0, 3),
                        style: text.labelSmall?.copyWith(
                          color: isSelected
                              ? scheme.onPrimary.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.day}',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? scheme.onPrimary : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
