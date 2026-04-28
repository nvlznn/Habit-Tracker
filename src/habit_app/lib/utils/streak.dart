import 'date_key.dart';

int currentStreak(Set<String> checkIns, {DateTime? now}) {
  if (checkIns.isEmpty) return 0;
  final today = startOfDay(now ?? DateTime.now());

  // If today isn't done yet, start counting from yesterday so users
  // don't see "0" all morning.
  var cursor = checkIns.contains(dateKey(today))
      ? today
      : today.subtract(const Duration(days: 1));

  var streak = 0;
  while (checkIns.contains(dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int longestStreak(Set<String> checkIns) {
  if (checkIns.isEmpty) return 0;
  final dates = checkIns.map(_parseKey).toList()..sort();

  var longest = 1;
  var run = 1;
  for (var i = 1; i < dates.length; i++) {
    final diff = dates[i].difference(dates[i - 1]).inDays;
    if (diff == 1) {
      run++;
      if (run > longest) longest = run;
    } else if (diff > 1) {
      run = 1;
    }
  }
  return longest;
}

List<int> last7DaysCounts(Set<String> checkIns, {DateTime? now}) {
  final today = startOfDay(now ?? DateTime.now());
  return List<int>.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    return checkIns.contains(dateKey(day)) ? 1 : 0;
  });
}

DateTime _parseKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}
