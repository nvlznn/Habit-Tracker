# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

**HabitFlow** is a Flutter habit-tracker built as a school project ("專題") for a Data Structures & Advanced Programming course. The README.md is the project proposal in Traditional Chinese; `docs/assignment.md` is the assignment spec.

Submissions are by **GitHub Release tag**, not commit:
- `proposal` — already published
- `prototype` — due **2026-05-04**
- `final-report` — due **2026-05-17**

Late = 10%/day off, 3 days = 0. Don't merge things that break the build close to a deadline.

The development machine is Windows-only — iOS builds require a separate Mac and aren't tested locally. Use `-d chrome` or `-d windows` for verification.

## Commands

All Flutter commands run from **`src/habit_app/`**, not the repo root:

```
cd src/habit_app
flutter pub get               # install / refresh deps
flutter analyze               # static analysis (target: 0 issues)
flutter test                  # run all tests
flutter test test/widget_test.dart -p chrome   # single test file on chrome
flutter run -d chrome         # fastest manual UI verification (no emulator setup)
flutter run -d windows        # native windows build
```

When `flutter run` is interactive, use `r` for hot reload, `R` for hot restart, `q` to quit. Don't launch `flutter run` through Claude's background bash — keypresses won't reach the process; ask the user to run it in a real terminal.

## Architecture

### Storage model — single Hive box, check-ins inline

There is **one** Hive box (`'habits'`) holding `Habit` objects. Each `Habit` carries its own check-in history as `Set<String>` of `'yyyy-MM-dd'` date keys (see `lib/utils/date_key.dart`). There is no separate "check-in" table or join — toggling a check-in mutates the `Habit` and re-puts it in the box.

This keeps things O(1) for "did the user check off habit X on day Y?" and is fine at this app's data scale (tens of habits × ~1 year of dates). If you find yourself wanting a second box keyed by date, reconsider — the inline set is the load-bearing simplification.

### Hand-written Hive TypeAdapter (no code-gen)

`HabitAdapter` in `lib/models/habit.dart` is **written by hand** — there is intentionally no `build_runner` or `hive_generator` dependency. If you change the `Habit` shape (add/remove a field, change a type), update `read()` and `write()` in lockstep and bump the typeId only if the on-disk format becomes incompatible. Don't introduce code-generation; the user is new to dev and the manual adapter is part of the project's deliberate simplicity.

### State flow

`HabitProvider` (in `lib/providers/`) is a `ChangeNotifier` and the **only** mutation path for habits. UI reads via `Consumer<HabitProvider>` or `context.read/watch<HabitProvider>()`. After any box mutation, call `notifyListeners()`. The provider is created once in `main.dart` and injected via `ChangeNotifierProvider.value` — do not create new instances elsewhere.

### Streak quirk

`currentStreak` in `lib/utils/streak.dart` counts from **yesterday** when today isn't done yet, so users don't see "0" all morning. If you change streak rules, this is a deliberate UX choice — keep it unless the user explicitly asks otherwise. `longestStreak` is a single sorted scan; `last7DaysCounts` returns 7 ints aligned so the rightmost is today.

### Visual identity

The app's signature look is the **dot-grid card** in `lib/widgets/habit_card.dart` — 4 weeks × 7 weekday columns, today's column highlighted in the habit's color. The home screen has a big day-of-week header with a daily quote. The detail screen uses a tappable monthly calendar (lets users back-fill missed days). Default theme is dark; light theme exists but is not the default. Per-habit color tinting is the main differentiator between cards — preserve it when restyling.

### File layout

```
src/habit_app/lib/
  main.dart                      # Hive init, theme, ChangeNotifierProvider, root nav
  models/habit.dart              # Habit + hand-written HabitAdapter
  providers/habit_provider.dart  # the only mutation path
  screens/                       # root_screen, home_screen, habit_detail_screen,
                                 #   edit_habit_screen, stats_screen
  widgets/                       # habit_card (dot grid), color_picker_row
  utils/                         # date_key, streak (pure functions)
```

## Out of scope for the prototype (5/04)

Per the user's locked decisions: daily-only frequency, no reminders, no per-habit time, no settings screen, no weekday selector. These are deferred to the final (5/17). If asked to add them mid-prototype, confirm the user wants to expand scope before building.

## Tests

`test/widget_test.dart` initializes Hive against a temp directory (no `path_provider` plugin available in tests) and runs a smoke test that the app boots to the empty state. If you add features that change first-launch copy, update this test rather than removing it.
