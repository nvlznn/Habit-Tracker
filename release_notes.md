# habibi prototype

A minimal habit tracker built with Flutter. School project for the
DSAP course.

## What's in this prototype

- Working Flutter app under `src/habibi/`: add / edit / delete habits,
  daily check-in via the colored square in the top-right of each card,
  dot-grid history, monthly calendar with tap-to-toggle past records,
  Hive local persistence.
- DSAP benchmark module under `src/habibi/bench/`: three implementations
  of the date-key lookup operation (`HashSet`, sorted array + binary
  search, fixed-window bitmap) behind a shared `CheckInIndex` interface,
  plus a CLI runner that produces a comparison table.
- Equivalence test (`test/algorithms_test.dart`) that drives all three
  implementations through identical operation sequences and asserts
  they agree.
- English README with proposal report, competitive analysis, prototype
  verifiable content (with benchmark numbers), and prototype report.

## How to run

From `src/habibi/`:

```
flutter pub get
flutter run -d chrome
flutter test
dart run bench/bench_main.dart
```

## Verified

- `flutter analyze` — 0 issues
- `flutter test` — green (smoke + algorithm equivalence tests)
- `dart run bench/bench_main.dart` — produces `bench/results.md` +
  `bench/results.csv`. Three implementations show clearly different
  scaling behavior at N ∈ {100, 1K, 10K, 100K}.

## Not in this prototype

- iOS build (no Mac on hand for the prototype window — to be arranged
  for the 5/17 final).
- Reminders, categories, custom-value goals.
