import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../storage/hive_storage.dart';
import 'storage_provider.dart';

/// [AsyncNotifier] that owns the squad roster and persists every change to
/// [HiveStorage].
///
/// **Optimised (OPT-2)**: `_current` getter centralises the `state.value ?? []`
/// fallback so it is not copy-pasted across every mutation — any change to the
/// guard logic only needs to happen in one place.
class RosterNotifier extends AsyncNotifier<List<Player>> {
  /// Safe accessor for the current roster list.
  List<Player> get _current => state.value ?? [];

  // ── Riverpod lifecycle ────────────────────────────────────────────────────

  @override
  Future<List<Player>> build() async {
    // Ensure Hive storage is initialized before reading data.
    await ref.watch(storageInitializerProvider.future);

    // 1. Check for 7-day auto-expiry
    final createdAt = HiveStorage.getRosterCreatedAt();
    if (createdAt != null) {
      final difference = DateTime.now().difference(createdAt);
      if (difference.inDays >= 7) {
        // Auto-delete after 1 week
        await HiveStorage.savePlayers([]);
        await HiveStorage.setRosterCreatedAt(null);
      }
    }

    return HiveStorage.loadPlayers();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Appends multiple [players] to the roster and persists once.
  Future<void> addPlayers(List<Player> players) async {
    final currentPlayers = state.value ?? [];
    final newState = [...currentPlayers, ...players];

    // Set creation timestamp if this is the first batch in a fresh roster
    if (currentPlayers.isEmpty && players.isNotEmpty) {
      await HiveStorage.setRosterCreatedAt(DateTime.now());
    }

    await HiveStorage.savePlayers(newState);
    state = AsyncValue.data(newState);
  }

  /// Appends [player] to the roster and persists to Hive.
  Future<void> addPlayer(Player player) async {
    await addPlayers([player]);
  }

  /// Updates state in-memory only — does NOT persist to Hive.
  /// Used for ephemeral imports that shouldn't 'stick' until generation.
  void updateInMemory(List<Player> players) {
    state = AsyncValue.data(players);
  }

  /// Persists the current [players] to Hive and updates state.
  Future<void> saveRoster(List<Player> players) async {
    // Set creation timestamp if this is the first batch in a fresh roster
    final currentOnDisk = HiveStorage.loadPlayers();
    if (currentOnDisk.isEmpty && players.isNotEmpty) {
      await HiveStorage.setRosterCreatedAt(DateTime.now());
    }

    await HiveStorage.savePlayers(players);
    state = AsyncValue.data(players);
  }

  /// Clears the entire roster and resets the timestamp.
  Future<void> clearAll() async {
    await HiveStorage.savePlayers([]);
    await HiveStorage.setRosterCreatedAt(null);
    state = const AsyncValue.data([]);
  }

  /// Permanently removes the player with [id] from the roster.
  Future<void> removePlayer(String id) async {
    final updated = _current.where((p) => p.id != id).toList();
    state = AsyncData(updated);
    await HiveStorage.savePlayers(updated);
  }

  /// Updates a player's jersey number.
  Future<void> updatePlayerNumber(String id, int number) async {
    final updated = [
      for (final p in _current)
        if (p.id == id) p.copyWith(number: number) else p,
    ];
    state = AsyncData(updated);
    await HiveStorage.savePlayers(updated);
  }

  /// Updates a player's full information and persists to Hive.
  Future<void> updatePlayerInfo(Player player) async {
    final updated = [
      for (final p in _current)
        if (p.id == player.id) player else p,
    ];
    state = AsyncData(updated);
    await HiveStorage.savePlayers(updated);
  }

  /// Updates cumulative goals and assists for a player.
  Future<void> updatePlayerStats(
    String id,
    int goals,
    int assists,
    int cleanSheets,
  ) async {
    final updated = [
      for (final p in _current)
        if (p.id == id)
          p.copyWith(goals: goals, assists: assists, cleanSheets: cleanSheets)
        else
          p,
    ];
    state = AsyncData(updated);
    await HiveStorage.savePlayers(updated);

    // Also mirror to the permanent stats archive for "Ghost Persistence"
    final player = updated.firstWhere((p) => p.id == id);
    await HiveStorage.archiveStatsForPlayer(
      player.name,
      goals,
      assists,
      cleanSheets,
    );
  }
}

/// Global provider for the squad roster.
/// Use `ref.watch(rosterProvider)` → `AsyncValue<List<Player>>`.
/// Use `ref.read(rosterProvider.notifier)` to call mutations.
final rosterProvider = AsyncNotifierProvider<RosterNotifier, List<Player>>(
  RosterNotifier.new,
);
