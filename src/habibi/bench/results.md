# habibi — date-key lookup benchmark

Workload: 10000 queries per (impl, N), seed=42.
Half of queries are guaranteed hits, half are random window picks.
Bitmap window is sized ~3x N so the set is moderately sparse.

| N | Impl | Build (us) | contains (ns/op) | add (ns/op) | hits | mem (bytes) |
|---:|---|---:|---:|---:|---:|---:|
| 100 | HashSet | 166 | 63.4 | 131.1 | 6680 | 2400 |
| 100 | SortedArray | 327 | 119.0 | 102.3 | 6680 | 800 |
| 100 | Bitmap | 202 | 49.1 | 965.3 | 6680 | 38 |
| 1000 | HashSet | 322 | 23.4 | 36.3 | 6715 | 24000 |
| 1000 | SortedArray | 1159 | 82.5 | 432.1 | 6715 | 8000 |
| 1000 | Bitmap | 66 | 44.0 | 35.4 | 6715 | 375 |
| 10000 | HashSet | 624 | 15.5 | 1007.5 | 6657 | 240000 |
| 10000 | SortedArray | 67182 | 78.3 | 14620.5 | 6657 | 80000 |
| 10000 | Bitmap | 26 | 4.6 | 6.9 | 6657 | 3750 |
| 100000 | HashSet | 4388 | 17.1 | 11.6 | 6610 | 2400000 |
| 100000 | SortedArray | 8240113 | 528.2 | 150255.1 | 6610 | 800000 |
| 100000 | Bitmap | 426 | 4.3 | 4.2 | 6610 | 37500 |

## Notes
- HashSet: O(1) avg contains/add, ~24 B/entry overhead.
- SortedArray: O(log n) contains, O(n) add (shift). Add cost should grow visibly with N.
- Bitmap: O(1) everything, fixed memory = ceil(window/8) bytes regardless of fill rate.
- Bitmap inserts in this benchmark go to days within its window; out-of-range writes would be silently dropped (intentional — a fixed-window bitmap trades unbounded range for constant memory).
