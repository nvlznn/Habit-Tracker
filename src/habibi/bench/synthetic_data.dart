import 'dart:math';

/// Generates a reproducible workload for the benchmark.
///
/// We pick [n] unique epoch-day values uniformly at random from a window
/// [origin, origin + windowDays). Window size is chosen to be ~3x n so
/// the set is sparse enough that a Bitmap is genuinely cheaper than a
/// HashSet but dense enough that lookups are not always misses.
class Workload {
  Workload({
    required this.origin,
    required this.windowDays,
    required this.checkIns,
    required this.queries,
    required this.addProbes,
  });

  /// Lowest epoch-day represented (inclusive).
  final int origin;

  /// Total number of representable days starting at [origin].
  final int windowDays;

  /// Distinct check-in days that should be inserted into each index.
  final List<int> checkIns;

  /// Random query days. About half are guaranteed hits (a day from
  /// [checkIns]); the rest are random days from the window, most of
  /// which will be misses.
  final List<int> queries;

  /// Distinct days NOT in [checkIns], drawn from random positions within
  /// the window. Used to time inserts that actually have to shift.
  final List<int> addProbes;
}

Workload buildWorkload({
  required int n,
  required int reps,
  required int seed,
}) {
  final rng = Random(seed);
  // window is ~3x n so the set is moderately sparse.
  final windowDays = (n * 3).clamp(64, 1 << 20);
  const origin = 19000; // ~2022-01-08, an arbitrary epoch-day origin

  // sample n unique days from [origin, origin + windowDays)
  final picked = <int>{};
  while (picked.length < n) {
    picked.add(origin + rng.nextInt(windowDays));
  }
  final checkIns = picked.toList(growable: false);

  // half of the queries are guaranteed hits, half are random (mostly misses).
  final queries = List<int>.filled(reps, 0);
  for (var i = 0; i < reps; i++) {
    if (i.isEven && checkIns.isNotEmpty) {
      queries[i] = checkIns[rng.nextInt(checkIns.length)];
    } else {
      queries[i] = origin + rng.nextInt(windowDays);
    }
  }

  // distinct add probes: days from inside the window that aren't already
  // check-ins. We expand the window so probes have somewhere to land
  // when n approaches windowDays.
  final addProbes = <int>[];
  final pickedSet = picked;
  while (addProbes.length < reps) {
    final d = origin + rng.nextInt(windowDays);
    if (!pickedSet.contains(d)) {
      addProbes.add(d);
    }
  }

  return Workload(
    origin: origin,
    windowDays: windowDays,
    checkIns: checkIns,
    queries: queries,
    addProbes: addProbes,
  );
}
