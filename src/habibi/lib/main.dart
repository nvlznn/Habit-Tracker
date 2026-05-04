import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';

const String _habitsBoxName = 'habits';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  final box = await Hive.openBox<Habit>(_habitsBoxName);
  runApp(HabibiApp(box: box));
}

class HabibiApp extends StatelessWidget {
  const HabibiApp({super.key, required this.box});

  final Box<Habit> box;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider(box),
      child: MaterialApp(
        title: 'habibi',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

ThemeData _buildDarkTheme() {
  const bg = Color(0xFF0E0E0E);
  const surface = Color(0xFF1A1A1A);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: Color(0xFFB388FF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
  );
}
