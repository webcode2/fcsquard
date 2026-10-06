import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'roster_provider.dart';

/// Provider for computing roster-wide summary statistics.
///
/// **Optimization (OPT-4)**: By moving these O(n) calculations into a specialized
/// provider, we ensure that:
/// 1. The calculation only re-runs when the roster actually changes.
/// 2. UI rebuilds triggered by other state (like search text changes) don't
///    waste cycles on roster scans.
final rosterSummaryProvider = Provider<RosterSummary>((ref) {
  final playersAsync = ref.watch(rosterProvider);

  return playersAsync.maybeWhen(
    data: (players) {
      if (players.isEmpty) {
        return const RosterSummary(total: 0, readinessPct: 0);
      }

      final total = players.length;

      return RosterSummary(
        total: total,
        readinessPct: 100, // Default to 100% until a new metric is needed
      );
    },
    orElse: () => const RosterSummary(total: 0, readinessPct: 0),
  );
});

class RosterSummary {
  final int total;
  final int readinessPct;

  const RosterSummary({required this.total, required this.readinessPct});
}
