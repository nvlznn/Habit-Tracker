import 'package:flutter/material.dart';

import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
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
    final subtitle = streak > 0
        ? '🔥 $streak day${streak == 1 ? '' : 's'} streak'
        : 'Tap the box to start a streak';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 14),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Checkbox(value: doneToday, onChanged: (_) => onToggle()),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
