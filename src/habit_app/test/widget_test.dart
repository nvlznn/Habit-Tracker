import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_app/main.dart';
import 'package:habit_app/models/habit.dart';
import 'package:habit_app/providers/habit_provider.dart';

void main() {
  late Directory tempDir;
  late Box<Habit> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_app_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    box = await Hive.openBox<Habit>(habitsBoxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(habitsBoxName);
    await tempDir.delete(recursive: true);
  });

  testWidgets('shows Today header on first launch', (tester) async {
    await tester.pumpWidget(HabitFlowApp(provider: HabitProvider(box)));
    await tester.pumpAndSettle();

    // 'Today' appears in both the AppBar title and the bottom nav label.
    expect(find.text('Today'), findsAtLeastNWidgets(1));
    expect(find.text('No habits yet'), findsOneWidget);
  });
}
