import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_history.dart';
import '../storage/hive_storage.dart';
import 'storage_provider.dart';

/// AsyncNotifier for match history — properly awaits Hive initialization
/// before reading data, preventing the empty-state race condition that caused
/// the Vault to always appear empty.
class HistoryNotifier extends AsyncNotifier<List<MatchHistory>> {
  @override
  Future<List<MatchHistory>> build() async {
    // Await storage initialization before reading
    await ref.watch(storageInitializerProvider.future);
    return HiveStorage.loadHistory();
  }

  Future<void> addMatch(MatchHistory match) async {
    // Optimistic update in memory, then persist
    final current = state.value ?? [];
    state = AsyncData([match, ...current]);
    await HiveStorage.addMatchToHistory(match);
  }

  Future<void> removeMatch(String id) async {
    final current = state.value ?? [];
    final updated = current.where((m) => m.id != id).toList();
    state = AsyncData(updated);
    await HiveStorage.saveHistory(updated);
  }

  Future<void> updateMatch(MatchHistory match) async {
    final current = state.value ?? [];
    final updated = current.map((m) => m.id == match.id ? match : m).toList();
    state = AsyncData(updated);
    await HiveStorage.saveHistory(updated);
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<MatchHistory>>(
      HistoryNotifier.new,
    );
