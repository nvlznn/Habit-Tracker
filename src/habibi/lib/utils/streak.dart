import 'date_key.dart';

int currentStreak(Set<String> dateKeys) {
  if (dateKeys.isEmpty) return 0;
  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!dateKeys.contains(dateKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (dateKeys.contains(dateKey(cursor))) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int longestStreak(Set<String> dateKeys) {
  if (dateKeys.isEmpty) return 0;
  final days = dateKeys.map(parseDateKey).toList()..sort();
  var best = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    final diff = days[i].difference(days[i - 1]).inDays;
    if (diff == 1) {
      run += 1;
      if (run > best) best = run;
    } else if (diff > 1) {
      run = 1;
    }
  }
  return best;
}
