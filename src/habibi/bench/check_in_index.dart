/// Shared interface for the three check-in index implementations
/// being benchmarked for the DSAP requirement.
///
/// The "feature flow" under analysis is the date-key lookup:
///   given a habit's check-in history, answer "is day D recorded?".
///
/// Each implementation backs this contract with a different data
/// structure (HashSet, sorted array, bitmap), allowing direct
/// performance and memory comparison on identical workloads.
abstract class CheckInIndex {
  bool contains(int epochDay);
  void add(int epochDay);
  void remove(int epochDay);
  int get size;

  /// Approximate memory footprint in bytes. Used by the bench runner.
  int approxBytes();

  /// A short label used in the benchmark output table.
  String get label;
}
