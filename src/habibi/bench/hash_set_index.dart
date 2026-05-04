import 'check_in_index.dart';

/// Hash-set backed implementation.
///   contains: O(1) average
///   add:      O(1) average
///   remove:   O(1) average
/// Memory: roughly 24 bytes per entry on the Dart VM (pointer + bucket overhead).
class HashSetIndex implements CheckInIndex {
  final Set<int> _days = <int>{};

  @override
  bool contains(int epochDay) => _days.contains(epochDay);

  @override
  void add(int epochDay) => _days.add(epochDay);

  @override
  void remove(int epochDay) => _days.remove(epochDay);

  @override
  int get size => _days.length;

  @override
  int approxBytes() => _days.length * 24;

  @override
  String get label => 'HashSet';
}
