import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../bench/bitmap_index.dart';
import '../bench/check_in_index.dart';
import '../bench/hash_set_index.dart';
import '../bench/sorted_array_index.dart';

void main() {
  test('all three CheckInIndex implementations agree on the same workload',
      () {
    // A fixed seed so the test is reproducible.
    final rng = Random(123);
    const origin = 19000;
    const window = 4096;
    const ops = 5000;

    final indexes = <CheckInIndex>[
      HashSetIndex(),
      SortedArrayIndex(),
      BitmapIndex(origin: origin, capacityDays: window),
    ];

    // Drive identical operation sequences through each index and compare
    // the result of every contains() call. Any divergence fails the test.
    for (var step = 0; step < ops; step++) {
      final day = origin + rng.nextInt(window);
      final action = rng.nextInt(10);
      if (action < 6) {
        // 60% adds
        for (final idx in indexes) {
          idx.add(day);
        }
      } else if (action < 9) {
        // 30% contains
        final answers = indexes.map((i) => i.contains(day)).toList();
        expect(answers.toSet().length, 1,
            reason: 'mismatch at step $step day=$day: $answers');
      } else {
        // 10% removes
        for (final idx in indexes) {
          idx.remove(day);
        }
      }
    }

    // Final state size must agree too.
    final sizes = indexes.map((i) => i.size).toList();
    expect(sizes.toSet().length, 1, reason: 'final sizes diverge: $sizes');
  });

  test('SortedArrayIndex stays sorted after random ops', () {
    final rng = Random(7);
    final idx = SortedArrayIndex();
    for (var i = 0; i < 1000; i++) {
      idx.add(rng.nextInt(2000));
    }
    for (var i = 0; i < 200; i++) {
      idx.remove(rng.nextInt(2000));
    }

    // Re-issue contains for every value present and assert binary search
    // still finds them. We can't see internals, but if order is broken,
    // contains will start lying.
    final probes = List<int>.generate(2000, (i) => i);
    final found = probes.where(idx.contains).toList();
    // Ensure binary search returns are stable by repeating.
    final foundAgain = probes.where(idx.contains).toList();
    expect(found, foundAgain);
    expect(found.length, idx.size);
  });

  test('BitmapIndex matches HashSet for in-range writes', () {
    final rng = Random(99);
    const origin = 1000;
    const window = 512;
    final hash = HashSetIndex();
    final bm = BitmapIndex(origin: origin, capacityDays: window);

    for (var i = 0; i < 2000; i++) {
      final day = origin + rng.nextInt(window);
      if (rng.nextBool()) {
        hash.add(day);
        bm.add(day);
      } else {
        hash.remove(day);
        bm.remove(day);
      }
    }

    for (var d = origin; d < origin + window; d++) {
      expect(bm.contains(d), hash.contains(d),
          reason: 'bitmap vs hashset disagree at day $d');
    }
    expect(bm.size, hash.size);
  });
}
