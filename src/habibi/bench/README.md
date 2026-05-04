# bench/ — date-key lookup benchmark

This module exists to satisfy the DSAP rubric requirement:

> 至少提出系統內一個功能流程是使用不同資料結構或演算法來進行實際效能分析跟比較

The "feature flow" under analysis is the **date-key lookup**: given a habit's
check-in history, answer "is day D recorded?". This is the single hottest read
inside `lib/`: every dot in the home grid, every cell in the month calendar,
and every streak calculation issues this query.

We compare **three different data structures** that can back this operation:

| Implementation       | contains  | add       | remove    | memory          |
|----------------------|-----------|-----------|-----------|-----------------|
| `HashSetIndex`       | O(1) avg  | O(1) avg  | O(1) avg  | ~24 B / entry   |
| `SortedArrayIndex`   | O(log n)  | O(n)      | O(n)      | ~8 B / entry    |
| `BitmapIndex`        | O(1)      | O(1)      | O(1)      | ceil(window/8) B (fixed) |

All three implement the same `CheckInIndex` interface, so the runner feeds
them identical workloads and timing is directly comparable.

## How to run

From `src/habibi/`:

```
dart run bench/bench_main.dart
```

The runner generates seeded synthetic check-in data for
`N ∈ {100, 1000, 10000, 100000}`, builds each index, then times 10 000
`contains` and 10 000 `add` operations per (impl, N) pair. It writes
`bench/results.md` and `bench/results.csv` and also prints a Markdown
table to stdout.

The seed is fixed (42) so reruns produce comparable numbers.

## Equivalence test

`test/algorithms_test.dart` (in the project's `test/` folder) drives all
three implementations through the same sequence of `add` / `remove` /
`contains` operations and asserts they produce identical results. This
catches silent divergence (e.g. an off-by-one in the sorted-array binary
search would otherwise show up only as a wrong dot in the UI).

Run it with:

```
flutter test test/algorithms_test.dart
```
