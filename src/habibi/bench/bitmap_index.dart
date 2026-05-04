import 'dart:typed_data';
import 'check_in_index.dart';

/// Bitmap (bit-array) backed implementation.
///   contains / add / remove: O(1)
/// Memory: 1 bit per representable day, regardless of fill rate.
/// E.g. covering 10 years (~3650 days) costs ~458 bytes total.
///
/// The bitmap covers a fixed window [origin, origin + capacityDays).
/// Days outside this window are treated as not present (and writes are
/// silently dropped). For the benchmark we size the window to the data.
class BitmapIndex implements CheckInIndex {
  BitmapIndex({required this.origin, required int capacityDays})
      : _bytes = Uint8List((capacityDays + 7) >> 3),
        _capacity = capacityDays;

  final int origin;
  final int _capacity;
  final Uint8List _bytes;
  int _size = 0;

  bool _inRange(int epochDay) {
    final i = epochDay - origin;
    return i >= 0 && i < _capacity;
  }

  @override
  bool contains(int epochDay) {
    if (!_inRange(epochDay)) return false;
    final i = epochDay - origin;
    return (_bytes[i >> 3] & (1 << (i & 7))) != 0;
  }

  @override
  void add(int epochDay) {
    if (!_inRange(epochDay)) return;
    final i = epochDay - origin;
    final byte = i >> 3;
    final bit = 1 << (i & 7);
    if ((_bytes[byte] & bit) == 0) {
      _bytes[byte] |= bit;
      _size++;
    }
  }

  @override
  void remove(int epochDay) {
    if (!_inRange(epochDay)) return;
    final i = epochDay - origin;
    final byte = i >> 3;
    final bit = 1 << (i & 7);
    if ((_bytes[byte] & bit) != 0) {
      _bytes[byte] &= ~bit;
      _size--;
    }
  }

  @override
  int get size => _size;

  @override
  int approxBytes() => _bytes.lengthInBytes;

  @override
  String get label => 'Bitmap';
}
