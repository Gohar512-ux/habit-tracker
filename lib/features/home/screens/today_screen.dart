import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/habit_provider.dart';
import '../../habits/screens/habit_detail_screen.dart';
import '../../habits/widgets/habit_tile.dart';
import '../widgets/progress_card.dart';
import '../widgets/week_strip.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _selected = DateHelpers.today();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final habits = context.watch<HabitProvider>();
    final auth = context.watch<AuthProvider>();

    final fullName = (auth.user?.displayName ?? '').trim();
    final firstName = fullName.isEmpty ? '' : fullName.split(' ').first;
    final list = habits.habitsFor(_selected);
    final progress = habits.progressFor(_selected);
    final isToday = DateHelpers.isSameDay(_selected, DateHelpers.today());

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  firstName.isEmpty
                      ? DateHelpers.greeting()
                      : '${DateHelpers.greeting()}, $firstName',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMMM').format(_selected),
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                WeekStrip(
                  selected: _selected,
                  onSelect: (d) => setState(() => _selected = d),
                ),
                const SizedBox(height: 16),
                ProgressCard(
                  done: progress.done,
                  total: progress.total,
                  isToday: isToday,
                ),
                const SizedBox(height: 24),
                Text(
                  'Habits',
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          if (habits.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (habits.error != null)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Something went wrong',
                message: habits.error!,
              ),
            )
          else if (habits.habits.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.add_task_rounded,
                  title: 'Start your first habit',
                  message:
                  'Tap "New habit" below. Pick something small and specific.',
                ),
              )
          else if (list.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.event_available_rounded,
                title: 'Rest day',
                message: 'No habits are scheduled for this day.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final habit = list[i];
                  return HabitTile(
                    habit: habit,
                    date: _selected,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HabitDetailScreen(habitId: habit.id),
                      ),
                    ),
                    onToggle: () async {
                      try {
                        await context.read<HabitProvider>().toggle(habit, _selected);
                      } catch (_) {
                        if (context.mounted) {
                          showAppSnack(
                            context,
                            'Could not update habit. Try again.',
                            error: true,
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
