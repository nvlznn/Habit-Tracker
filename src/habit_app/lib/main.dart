import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'screens/root_screen.dart';

// Near-black background for the dark theme — slightly warmer than pure black
// so cards lifted with surface tint stay readable.
const Color _darkBg = Color(0xFF0B0C10);
const Color _darkSurface = Color(0xFF14161C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  final box = await Hive.openBox<Habit>(habitsBoxName);

  runApp(HabitFlowApp(provider: HabitProvider(box)));
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key, required this.provider});

  final HabitProvider provider;

  @override
  Widget build(BuildContext context) {
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F8CFF),
      brightness: Brightness.dark,
    ).copyWith(
      surface: _darkBg,
      surfaceContainerHighest: _darkSurface,
    );

    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: 'HabitFlow',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4F8CFF),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: darkScheme,
          scaffoldBackgroundColor: _darkBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: _darkBg,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: _darkBg,
            indicatorColor: Color(0xFF1F2230),
            elevation: 0,
          ),
        ),
        home: const RootScreen(),
      ),
    );
  }
}
