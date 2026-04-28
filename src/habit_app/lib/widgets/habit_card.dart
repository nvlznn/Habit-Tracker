import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../utils/date_key.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.doneToday,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress,
  });

  final Habit habit;
  final int streak;
  final bool doneToday;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final tinted = Color.alphaBlend(
      color.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.surfaceContainerHighest,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: tinted,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              habit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '🔥 $streak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _CheckButton(
                      color: color,
                      checked: doneToday,
                      onTap: onToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DotGrid(checkIns: habit.checkIns, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.color,
    required this.checked,
    required this.onTap,
  });

  final Color color;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? color : Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            checked ? Icons.check : Icons.check,
            size: 18,
            color: checked ? Colors.white : Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _DotGrid extends StatelessWidget {
  const _DotGrid({required this.checkIns, required this.color});

  final Set<String> checkIns;
  final Color color;

  static const int _weeks = 4;

  @override
  Widget build(BuildContext context) {
    final today = startOfDay(DateTime.now());
    // Monday of the current week (Dart: weekday 1 = Mon ... 7 = Sun)
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final topLeft = mondayThisWeek.subtract(const Duration(days: 7 * (_weeks - 1)));
    final todayCol = today.weekday - 1; // 0..6

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = constraints.maxWidth / 7;
        return Stack(
          children: [
            // Highlight capsule behind today's column.
            Positioned(
              left: colWidth * todayCol + (colWidth - 22) / 2,
              top: 0,
              bottom: 22,
              child: Container(
                width: 22,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            Column(
              children: [
                for (var row = 0; row < _weeks; row++)
                  Padding(
                    padding: EdgeInsets.only(bottom: row == _weeks - 1 ? 0 : 6),
                    child: Row(
                      children: [
                        for (var col = 0; col < 7; col++)
                          Expanded(
                            child: Center(
                              child: _Dot(
                                color: color,
                                filled: _isFilled(topLeft, row, col),
                                inFuture: _isFuture(topLeft, row, col, today),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      Expanded(
                        child: Center(
                          child: Text(
                            _weekdayLabel(col),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: col == todayCol
                                  ? color
                                  : Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _isFilled(DateTime topLeft, int row, int col) {
    final date = topLeft.add(Duration(days: row * 7 + col));
    return checkIns.contains(dateKey(date));
  }

  bool _isFuture(DateTime topLeft, int row, int col, DateTime today) {
    final date = topLeft.add(Duration(days: row * 7 + col));
    return date.isAfter(today);
  }

  static String _weekdayLabel(int col) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[col];
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.filled,
    required this.inFuture,
  });

  final Color color;
  final bool filled;
  final bool inFuture;

  @override
  Widget build(BuildContext context) {
    final size = filled ? 12.0 : 10.0;
    final dotColor = filled
        ? color
        : Colors.white.withValues(alpha: inFuture ? 0.06 : 0.14);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}
