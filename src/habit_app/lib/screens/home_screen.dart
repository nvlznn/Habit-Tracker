import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';

// A small set of original short affirmations. One is shown per day, picked by
// day-of-year so it rotates predictably without needing storage.
const List<String> _dailyLines = [
  'Small steps, every day.',
  'Show up, that’s the whole secret.',
  'Tiny wins compound into big change.',
  'You don’t need motivation, just the next step.',
  'One day at a time, one habit at a time.',
  'Your future self is built one check at a time.',
  'Consistency beats intensity.',
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final monthDay = DateFormat('MMMM d').format(now);
    final year = DateFormat('y').format(now);
    final dayOfYear =
        int.parse(DateFormat('D').format(now));
    final quote = _dailyLines[dayOfYear % _dailyLines.length];

    return Scaffold(
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, provider, _) {
            final habits = provider.habits;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeaderBlock(
                    dayName: dayName,
                    monthDay: monthDay,
                    year: year,
                    quote: quote,
                  ),
                ),
                if (habits.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverList.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, i) {
                      final habit = habits[i];
                      return HabitCard(
                        habit: habit,
                        streak: provider.currentStreak(habit.id),
                        doneToday:
                            provider.isDoneOn(habit.id, DateTime.now()),
                        onToggle: () => provider.toggleToday(habit.id),
                        onTap: () => _openDetail(context, habit),
                        onLongPress: () =>
                            _confirmDelete(context, provider, habit),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEdit(BuildContext context, Habit? habit) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditHabitScreen(habit: habit)),
    );
  }

  void _openDetail(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: habit.id)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitProvider provider,
    Habit habit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${habit.name}"?'),
        content: const Text(
          'This will erase its check-in history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteHabit(habit.id);
    }
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.dayName,
    required this.monthDay,
    required this.year,
    required this.quote,
  });

  final String dayName;
  final String monthDay;
  final String year;
  final String quote;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Colors.white.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    monthDay,
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                  Text(
                    year,
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.format_quote, size: 16, color: mutedColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  quote,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first habit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
