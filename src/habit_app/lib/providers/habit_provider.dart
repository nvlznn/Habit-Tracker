import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../utils/date_key.dart';
import '../utils/streak.dart' as streak_utils;

const String habitsBoxName = 'habits';

class HabitProvider extends ChangeNotifier {
  HabitProvider(this._box);

  final Box<Habit> _box;
  final _uuid = const Uuid();

  List<Habit> get habits {
    final list = _box.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  bool get isEmpty => _box.isEmpty;

  Future<void> addHabit({required String name, required int colorValue}) async {
    final habit = Habit(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    await _box.put(habit.id, habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _box.put(habit.id, habit);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Habit? getHabit(String id) => _box.get(id);

  bool isDoneOn(String id, DateTime date) {
    final habit = _box.get(id);
    if (habit == null) return false;
    return habit.checkIns.contains(dateKey(date));
  }

  Future<void> toggleToday(String id) async {
    final habit = _box.get(id);
    if (habit == null) return;
    final key = todayKey();
    if (habit.checkIns.contains(key)) {
      habit.checkIns.remove(key);
    } else {
      habit.checkIns.add(key);
    }
    await _box.put(id, habit);
    notifyListeners();
  }

  int currentStreak(String id) {
    final habit = _box.get(id);
    if (habit == null) return 0;
    return streak_utils.currentStreak(habit.checkIns);
  }

  int longestStreak(String id) {
    final habit = _box.get(id);
    if (habit == null) return 0;
    return streak_utils.longestStreak(habit.checkIns);
  }

  int totalCheckIns(String id) {
    final habit = _box.get(id);
    return habit?.checkIns.length ?? 0;
  }

  List<int> last7DaysCounts(String id) {
    final habit = _box.get(id);
    if (habit == null) return List<int>.filled(7, 0);
    return streak_utils.last7DaysCounts(habit.checkIns);
  }
}
