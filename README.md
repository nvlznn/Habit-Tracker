# Habibi - Habit Tracker

A minimal habit tracker for iOS, built with Flutter.
School project for the **DSAP** (Data Structures & Advanced Programming)
course at NTU.

> Repository: https://github.com/nvlznn/habit-tracker
> Prototype Release tag: `prototype`

---

## Proposal Report

### Motivation & Goals

Most habit-tracking apps fall into one of two camps: heavy "gamified"
products that pile on streaks, badges, and social features, or polished
but locked-down apps that cap how many habits you can track unless you
pay. I wanted a habit tracker that sits in the middle: a single,
quiet screen that just shows what I've done and lets me tap to record
today — and that I fully own and can extend.

The DSAP angle: every interaction in this app boils down to the same
read — *"is habit H recorded on day D?"*. That single query backs every
filled dot in the home grid, every cell in the month calendar, and
every streak calculation. It's a perfect target for the rubric's
**"compare different data structures / algorithms on a real feature
flow"** requirement, because the same `contains(day)` operation can be
implemented at least three different ways with very different tradeoffs.
The benchmark module (`src/habibi/bench/`) implements all three behind
a shared interface and measures them on identical workloads.

### Competitive Analysis

| App                | Platform        | Price                | Strengths                              | How habibi differs                          |
|--------------------|-----------------|----------------------|----------------------------------------|---------------------------------------------|
| Habitica           | Web/iOS/Android | Free + subscription  | Gamification, social community         | Quiet & focused, open source                |
| Streaks            | iOS             | NT$160 one-time      | Polished design                        | No 12-habit cap, free                       |
| HabitKit           | iOS/Android     | Free + PRO tier      | Dot-grid visualisation, minimal UI     | Open source, transparent algorithm choices  |
| Loop Habit Tracker | Android         | Free (open source)   | Statistics & analytics, open source    | iOS-first                                   |

habibi takes design inspiration from HabitKit (minimal dark UI, dot-grid
history) but is fully open source and exposes its data-structure choices
as a teachable benchmark rather than hiding them.

### Planned Features

- Add / edit / delete habits (name, description, color, icon)
- Daily check-in by tapping the colored square in the top-right of each card
- Dot grid showing recent history (one column = one week)
- Habit detail screen with longer history, streak stats, and a monthly
  calendar where past dates can be tapped to back-fill or remove a record
- Local persistence with Hive (no cloud, no account)
- A standalone benchmark program comparing three data-structure
  implementations of the date-key lookup operation

### Technology Stack

- **Language:** Dart 3.11
- **Framework:** Flutter 3.41 (target platform: iOS; prototype verified
  on Chrome / Windows because no Mac is currently on hand)
- **Local storage:** Hive 2.2 with a hand-written `TypeAdapter`
  (no code generation)
- **State management:** Provider (`ChangeNotifier`)
- **Other:** `intl` for date formatting, `uuid` for habit IDs
- **Version control:** Git / GitHub

### Prototype Verifiable Content

1. The app launches on Chrome / Windows and supports the core flow:
   - Add a habit (icon, name, description, color)
   - Tap the colored square on a card to check in for today
   - View the dot-grid history on the home screen
   - Tap a card to open the detail screen, then tap any past date in
     the monthly calendar to toggle that day's record
   - Edit or delete an existing habit
2. Data persists across restarts (Hive local storage in `box('habits')`).
3. Running `dart run bench/bench_main.dart` produces a comparison table
   for the three index implementations across N ∈ {100, 1K, 10K, 100K}
   with 10 000 reps per (impl, N) and a fixed seed (42). Initial run
   on this machine:

   | N      | Impl        | Build (μs) | contains (ns/op) | add (ns/op) | mem (B)  |
   |-------:|-------------|-----------:|-----------------:|------------:|---------:|
   | 1000   | HashSet     | 322        | 23.4             | 36.3        | 24 000   |
   | 1000   | SortedArray | 1 159      | 82.5             | 432.1       | 8 000    |
   | 1000   | Bitmap      | 66         | 44.0             | 35.4        | 375      |
   | 10000  | HashSet     | 624        | 15.5             | 1 007.5     | 240 000  |
   | 10000  | SortedArray | 67 182     | 78.3             | 14 620.5    | 80 000   |
   | 10000  | Bitmap      | 26         | 4.6              | 6.9         | 3 750    |
   | 100000 | HashSet     | 4 388      | 17.1             | 11.6        | 2 400 000 |
   | 100000 | SortedArray | 8 240 113  | 528.2            | 150 255.1   | 800 000  |
   | 100000 | Bitmap      | 426        | 4.3              | 4.2         | 37 500   |

   Reading the table:
   - **HashSet**: contains stays roughly flat as N grows (O(1)), but
     memory grows linearly — 2.4 MB at N = 100K.
   - **SortedArray**: contains scales as O(log n), still cheap; but
     `add` does an O(n) shift, so build time at N = 100K balloons to
     **~8 seconds** and per-insert cost rises from ~100 ns at N = 100
     to ~150 μs at N = 100K — three orders of magnitude.
   - **Bitmap**: O(1) for everything, fixed memory of ⌈window / 8⌉
     bytes. At N = 100K it uses 37.5 KB — about 64× less than the
     HashSet — and is the fastest per op at every scale beyond JIT
     warmup.

   Conclusion for habibi's actual data scale (≤ a few hundred check-ins
   per habit): all three are fast enough, but the comparison shows
   *why* the choice would matter at scale, and the bitmap would be the
   right pick if a habit ever held tens of thousands of records.

4. All three implementations pass a shared correctness test
   (`test/algorithms_test.dart`) — given the same sequence of `add` /
   `remove` / `contains` operations against a seeded RNG, they return
   identical `contains` results at every step.

---

## Prototype Report

### Current Progress

- Project scaffolded under `src/habibi/` with Hive, Provider, intl, uuid.
- Data layer: `Habit` model with a hand-written `HabitAdapter`
  (typeId 0); `HabitProvider` exposes `create / update / delete /
  toggleDay` as the only mutation paths and emits `notifyListeners`
  after every `box.put`.
- UI: dark Material 3 theme, four screens (home, detail, edit,
  settings) and five reusable widgets (`HabitCard`, `DotGrid`,
  `MonthCalendar`, `IconPicker`, `ColorPicker`).
- DSAP module under `src/habibi/bench/`: three implementations of
  `CheckInIndex` (HashSet, SortedArray, Bitmap), a seeded synthetic
  workload generator, and a CLI runner that prints a Markdown table
  and writes `results.md` + `results.csv`.
- Tests: smoke test boots the app and renders the empty state;
  `algorithms_test.dart` asserts the three indexes agree on identical
  operation sequences.
- `flutter analyze` reports no issues. `flutter test` is green.

### Challenges Encountered

- **No Mac available.** The course's final demo is on iOS, but I only
  have a Windows machine on hand. Verified the prototype on Chrome and
  Windows; will need to arrange Mac access (school lab or a friend's
  machine) before the 5/17 final to produce a real iOS build.
- **Hand-written Hive adapter.** I deliberately avoided code generation
  to keep the build pipeline simple, which means every change to the
  `Habit` schema has to update both `read()` and `write()` in lockstep.
  Manageable while the model is small, but worth flagging.
- **Designing the bench so SortedArray's cost is visible.** My first
  pass appended new days at the end of the array, which is O(1) for a
  sorted list and made the SortedArray look unfairly competitive on
  the `add` column. Reworked the synthetic workload to insert at random
  positions inside the existing window, after which the O(n) shift
  cost shows up cleanly (~100 ns at N = 100 → ~150 μs at N = 100K).
- **Scope discipline.** Dropped reminders, categories, and
  custom-value goals from the prototype to fit the timeline; they're
  noted as candidates for the final.

### Next Steps

- Borrow / arrange Mac access; build an iOS release; deploy to TestFlight
  for the 5/17 demo.
- Record a short demo video walking through the core flow.
- Write the Final Report sections (project description, usage
  instructions, architecture diagram).
- Optional polish: light theme toggle in settings, habit reordering,
  CSV export of check-in history.
- Re-run the benchmark on the actual demo device (iPhone) to see how
  the three implementations compare on ARM vs. Dart-on-VM.

---

## How to run

From `src/habibi/`:

```sh
flutter pub get
flutter run -d chrome           # prototype demo
flutter test                    # widget + algorithm tests
flutter analyze                 # static analysis
dart run bench/bench_main.dart  # DSAP benchmark
```

## Repository layout

```
habit-tracker/
├── README.md                              # this file
└── src/habibi/
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── models/habit.dart              # hand-written HabitAdapter
    │   ├── providers/habit_provider.dart
    │   ├── utils/{date_key,palette,streak}.dart
    │   ├── widgets/
    │   │   ├── habit_card.dart
    │   │   ├── dot_grid.dart
    │   │   ├── month_calendar.dart
    │   │   ├── icon_picker.dart
    │   │   └── color_picker.dart
    │   └── screens/
    │       ├── home_screen.dart
    │       ├── habit_detail_screen.dart
    │       ├── edit_habit_screen.dart
    │       └── settings_screen.dart
    ├── bench/                             # DSAP module — outside lib/
    │   ├── check_in_index.dart            # shared interface
    │   ├── hash_set_index.dart
    │   ├── sorted_array_index.dart
    │   ├── bitmap_index.dart
    │   ├── synthetic_data.dart            # seeded workload generator
    │   ├── bench_main.dart                # CLI runner
    │   ├── results.md                     # generated
    │   └── results.csv                    # generated
    └── test/
        ├── widget_test.dart
        └── algorithms_test.dart           # three indexes must agree
```
