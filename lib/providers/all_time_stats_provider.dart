import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_storage.dart';
import '../models/player.dart';
import 'roster_provider.dart';

/// Data model for a player's all-time summary.
class PlayerAllTimeStats {
  final String name;
  final int goals;
  final int assists;
  final int cleanSheets;

  PlayerAllTimeStats({
    required this.name,
    required this.goals,
    required this.assists,
    required this.cleanSheets,
  });
}

/// [AsyncNotifier] that manages all-time persistent player stats.
class AllTimeStatsNotifier extends AsyncNotifier<List<PlayerAllTimeStats>> {
  @override
  Future<List<PlayerAllTimeStats>> build() async {
    final archive = HiveStorage.loadAllTimeStats();

    final list =
        archive
            .map(
              (entry) => PlayerAllTimeStats(
                name: entry.key,
                goals: (entry.value['goals'] as int? ?? 0),
                assists: (entry.value['assists'] as int? ?? 0),
                cleanSheets: (entry.value['cleanSheets'] as int? ?? 0),
              ),
            )
            .toList()
          ..sort((a, b) {
            if (b.goals != a.goals) return b.goals.compareTo(a.goals);
            return b.assists.compareTo(a.assists);
          });

    return list;
  }

  /// Removes a player's entry from the all-time archive.
  Future<void> removePlayerStats(String name) async {
    await HiveStorage.deleteStatsForPlayer(name);
    ref.invalidateSelf();
  }

  /// Updates stats for a player and refreshes the state.
  Future<void> updateStats(
    String name,
    int goals,
    int assists,
    int cleanSheets,
  ) async {
    await HiveStorage.archiveStatsForPlayer(name, goals, assists, cleanSheets);

    // Sync with roster if player exists there
    final roster = ref.read(rosterProvider);
    if (roster is AsyncData<List<Player>>) {
      final matchingPlayers = roster.value.where(
        (p) => p.name.trim().toUpperCase() == name.trim().toUpperCase(),
      );
      for (final p in matchingPlayers) {
        await ref
            .read(rosterProvider.notifier)
            .updatePlayerStats(p.id, goals, assists, cleanSheets);
      }
    }

    ref.invalidateSelf();
  }

  /// Refreshes the list manually.
  void refresh() => ref.invalidateSelf();
}

/// Global provider for all-time stats.
final allTimeStatsProvider =
    AsyncNotifierProvider<AllTimeStatsNotifier, List<PlayerAllTimeStats>>(
      AllTimeStatsNotifier.new,
    );
