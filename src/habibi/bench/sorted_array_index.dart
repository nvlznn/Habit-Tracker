import 'check_in_index.dart';

/// Sorted-array backed implementation.
///   contains: O(log n) via binary search
///   add:      O(n) worst case (shift to keep sorted)
///   remove:   O(n) worst case (shift)
/// Memory: ~8 bytes per entry (Dart int in a List).
class SortedArrayIndex implements CheckInIndex {
  final List<int> _days = <int>[];

  /// Standard lower-bound binary search.
  /// Returns the first index i such that _days[i] >= target,
  /// or _days.length if no such index exists.
  int _lowerBound(int target) {
    var lo = 0;
    var hi = _days.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_days[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  @override
  bool contains(int epochDay) {
    final i = _lowerBound(epochDay);
    return i < _days.length && _days[i] == epochDay;
  }

  @override
  void add(int epochDay) {
    final i = _lowerBound(epochDay);
    if (i < _days.length && _days[i] == epochDay) return;
    _days.insert(i, epochDay);
  }

  @override
  void remove(int epochDay) {
    final i = _lowerBound(epochDay);
    if (i < _days.length && _days[i] == epochDay) {
      _days.removeAt(i);
    }
  }

  @override
  int get size => _days.length;

  @override
  int approxBytes() => _days.length * 8;

  @override
  String get label => 'SortedArray';
}
