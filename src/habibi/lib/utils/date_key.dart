import 'package:intl/intl.dart';

final DateFormat _fmt = DateFormat('yyyy-MM-dd');

String dateKey(DateTime d) => _fmt.format(DateTime(d.year, d.month, d.day));

String todayKey() => dateKey(DateTime.now());

DateTime parseDateKey(String key) => _fmt.parseStrict(key);

int epochDay(DateTime d) {
  final utcMidnight = DateTime.utc(d.year, d.month, d.day);
  return utcMidnight.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

DateTime fromEpochDay(int day) {
  return DateTime.fromMillisecondsSinceEpoch(
    day * Duration.millisecondsPerDay,
    isUtc: true,
  );
}

int todayEpochDay() => epochDay(DateTime.now());
