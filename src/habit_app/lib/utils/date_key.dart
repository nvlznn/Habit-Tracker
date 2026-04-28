String dateKey(DateTime d) {
  final local = DateTime(d.year, d.month, d.day);
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String todayKey() => dateKey(DateTime.now());

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
