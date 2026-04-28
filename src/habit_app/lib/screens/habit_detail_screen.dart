import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/date_key.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _viewedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final habit = provider.getHabit(widget.habitId);
        if (habit == null) {
          // Habit was deleted from elsewhere — back out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final color = Color(habit.colorValue);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEdit(habit),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(provider, habit),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Every day',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),
                _StatRow(
                  total: provider.totalCheckIns(habit.id),
                  current: provider.currentStreak(habit.id),
                  best: provider.longestStreak(habit.id),
                  color: color,
                ),
                const SizedBox(height: 24),
                _MonthHeader(
                  month: _viewedMonth,
                  onPrev: () => setState(() {
                    _viewedMonth =
                        DateTime(_viewedMonth.year, _viewedMonth.month - 1);
                  }),
                  onNext: () => setState(() {
                    _viewedMonth =
                        DateTime(_viewedMonth.year, _viewedMonth.month + 1);
                  }),
                ),
                const SizedBox(height: 12),
                _MonthCalendar(
                  month: _viewedMonth,
                  checkIns: habit.checkIns,
                  color: color,
                  onTapDate: (date) => _toggleDate(habit, date),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEdit(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditHabitScreen(habit: habit)),
    );
  }

  Future<void> _confirmDelete(HabitProvider provider, Habit habit) async {
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
    if (confirmed != true) return;
    if (!mounted) return;
    await provider.deleteHabit(habit.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleDate(Habit habit, DateTime date) async {
    final today = startOfDay(DateTime.now());
    if (date.isAfter(today)) return; // can't check off the future

    final provider = context.read<HabitProvider>();
    final key = dateKey(date);
    if (habit.checkIns.contains(key)) {
      habit.checkIns.remove(key);
    } else {
      habit.checkIns.add(key);
    }
    await provider.updateHabit(habit);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.total,
    required this.current,
    required this.best,
    required this.color,
  });

  final int total;
  final int current;
  final int best;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCell(value: '$total', label: 'TOTAL', color: color)),
        Expanded(child: _StatCell(value: '$current', label: 'STREAK', color: color)),
        Expanded(child: _StatCell(value: '$best', label: 'BEST', color: color)),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.checkIns,
    required this.color,
    required this.onTapDate,
  });

  final DateTime month;
  final Set<String> checkIns;
  final Color color;
  final ValueChanged<DateTime> onTapDate;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Dart weekday: Mon=1..Sun=7. Grid starts on Monday.
    final leadDays = firstOfMonth.weekday - 1;
    final gridStart = firstOfMonth.subtract(Duration(days: leadDays));
    final today = startOfDay(DateTime.now());

    const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Column(
      children: [
        Row(
          children: [
            for (final l in dayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      date: gridStart.add(Duration(days: row * 7 + col)),
                      currentMonth: month.month,
                      today: today,
                      checkIns: checkIns,
                      color: color,
                      onTap: onTapDate,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.currentMonth,
    required this.today,
    required this.checkIns,
    required this.color,
    required this.onTap,
  });

  final DateTime date;
  final int currentMonth;
  final DateTime today;
  final Set<String> checkIns;
  final Color color;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final inMonth = date.month == currentMonth;
    final done = checkIns.contains(dateKey(date));
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isFuture = date.isAfter(today);

    Color textColor;
    if (!inMonth) {
      textColor = Colors.white.withValues(alpha: 0.18);
    } else if (done) {
      textColor = Colors.white;
    } else if (isFuture) {
      textColor = Colors.white.withValues(alpha: 0.25);
    } else {
      textColor = Colors.white.withValues(alpha: 0.7);
    }

    final cell = AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : Colors.transparent,
            border: isToday && !done
                ? Border.all(color: color, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: done ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: isFuture || !inMonth ? null : () => onTap(date),
      child: cell,
    );
  }
}
