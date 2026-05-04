import 'dart:io';

import 'bitmap_index.dart';
import 'check_in_index.dart';
import 'hash_set_index.dart';
import 'sorted_array_index.dart';
import 'synthetic_data.dart';

/// CLI runner that benchmarks the three CheckInIndex implementations.
///
/// Defaults: N = [100, 1000, 10000, 100000], R = 10000 reps, seed = 42.
/// Writes results to bench/results.md and bench/results.csv,
/// and prints a Markdown table to stdout.
///
/// Run:
///   cd src/habibi
///   dart run bench/bench_main.dart
void main(List<String> args) {
  const sizes = [100, 1000, 10000, 100000];
  const reps = 10000;
  const seed = 42;

  final rows = <_Row>[];

  for (final n in sizes) {
    final wl = buildWorkload(n: n, reps: reps, seed: seed);

    for (final make in <CheckInIndex Function()>[
      () => HashSetIndex(),
      () => SortedArrayIndex(),
      () => BitmapIndex(origin: wl.origin, capacityDays: wl.windowDays),
    ]) {
      // BUILD: insert all n check-ins from scratch.
      final idx = make();
      final buildSw = Stopwatch()..start();
      for (final d in wl.checkIns) {
        idx.add(d);
      }
      buildSw.stop();

      // CONTAINS: time R lookups against the populated index.
      final containsSw = Stopwatch()..start();
      var hits = 0;
      for (final q in wl.queries) {
        if (idx.contains(q)) hits++;
      }
      containsSw.stop();

      // ADD: time R inserts of fresh days at RANDOM positions within the
      // existing window. This is the realistic "user back-fills a missed
      // day" workload, and is what makes the sorted-array shift cost
      // observable. Appending only at the end would mask it.
      final addIdx = make();
      for (final d in wl.checkIns) {
        addIdx.add(d);
      }
      final addDays = wl.addProbes;
      final addSw = Stopwatch()..start();
      for (final d in addDays) {
        addIdx.add(d);
      }
      addSw.stop();

      rows.add(_Row(
        n: n,
        impl: idx.label,
        buildUs: buildSw.elapsedMicroseconds,
        containsNsPerOp: _nsPerOp(containsSw, reps),
        addNsPerOp: _nsPerOp(addSw, reps),
        hits: hits,
        bytes: idx.approxBytes(),
      ));

      // sanity: addIdx should not have grown beyond bitmap capacity if bitmap.
      // (For HashSet/SortedArray this is unbounded; for Bitmap, the inserts
      // above are out-of-range and are silently dropped — which is the correct
      // behavior for a fixed-window bitmap. We note this in results.md.)
    }
  }

  final md = _renderMarkdown(rows, sizes: sizes, reps: reps, seed: seed);
  final csv = _renderCsv(rows);

  // print to stdout
  stdout.writeln(md);

  // write to bench/ next to this script
  final scriptDir = File.fromUri(Platform.script).parent.path;
  File('$scriptDir/results.md').writeAsStringSync(md);
  File('$scriptDir/results.csv').writeAsStringSync(csv);
  stdout.writeln('\nWrote $scriptDir/results.md and results.csv');
}

class _Row {
  _Row({
    required this.n,
    required this.impl,
    required this.buildUs,
    required this.containsNsPerOp,
    required this.addNsPerOp,
    required this.hits,
    required this.bytes,
  });

  final int n;
  final String impl;
  final int buildUs;
  final double containsNsPerOp;
  final double addNsPerOp;
  final int hits;
  final int bytes;
}

double _nsPerOp(Stopwatch sw, int reps) =>
    sw.elapsedMicroseconds * 1000.0 / reps;

String _renderMarkdown(
  List<_Row> rows, {
  required List<int> sizes,
  required int reps,
  required int seed,
}) {
  final b = StringBuffer();
  b.writeln('# habibi — date-key lookup benchmark');
  b.writeln();
  b.writeln('Workload: $reps queries per (impl, N), seed=$seed.');
  b.writeln('Half of queries are guaranteed hits, half are random window picks.');
  b.writeln('Bitmap window is sized ~3x N so the set is moderately sparse.');
  b.writeln();
  b.writeln('| N | Impl | Build (us) | contains (ns/op) | add (ns/op) | hits | mem (bytes) |');
  b.writeln('|---:|---|---:|---:|---:|---:|---:|');
  for (final r in rows) {
    b.writeln('| ${r.n} | ${r.impl} | ${r.buildUs} '
        '| ${r.containsNsPerOp.toStringAsFixed(1)} '
        '| ${r.addNsPerOp.toStringAsFixed(1)} '
        '| ${r.hits} | ${r.bytes} |');
  }
  b.writeln();
  b.writeln('## Notes');
  b.writeln('- HashSet: O(1) avg contains/add, ~24 B/entry overhead.');
  b.writeln('- SortedArray: O(log n) contains, O(n) add (shift). Add cost should grow visibly with N.');
  b.writeln('- Bitmap: O(1) everything, fixed memory = ceil(window/8) bytes regardless of fill rate.');
  b.writeln('- Bitmap inserts in this benchmark go to days within its window; out-of-range writes would be silently dropped (intentional — a fixed-window bitmap trades unbounded range for constant memory).');
  return b.toString();
}

String _renderCsv(List<_Row> rows) {
  final b = StringBuffer();
  b.writeln('n,impl,build_us,contains_ns_per_op,add_ns_per_op,hits,bytes');
  for (final r in rows) {
    b.writeln('${r.n},${r.impl},${r.buildUs},'
        '${r.containsNsPerOp.toStringAsFixed(2)},'
        '${r.addNsPerOp.toStringAsFixed(2)},'
        '${r.hits},${r.bytes}');
  }
  return b.toString();
}
