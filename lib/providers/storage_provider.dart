import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/match_history.dart';
import '../storage/hive_storage.dart';

/// Provider that handles the async initialization of Hive storage.
///
/// Moving this from `main()` to a provider allows the app to launch
/// immediately while showing a loading state, improving perceived startup time.
final storageInitializerProvider = FutureProvider<void>((ref) async {
  // 1. Hive setup — resolving platform directories
  await Hive.initFlutter();

  // 2. Register adapters
  // These must be registered before opening any box that contains these types.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PlayerPositionAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PlayerAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(MatchHistoryAdapter());
  }

  // 3. Open the actual player box via the storage wrapper
  try {
    await HiveStorage.init();
  } catch (e) {
    // Box may be corrupted (e.g. after a model schema change or build_runner
    // regeneration). Delete and recreate both boxes so the app can self-heal.
    // On first launch after a model breaking-change the seed data is re-applied.
    await Hive.deleteBoxFromDisk('players');
    await Hive.deleteBoxFromDisk('history');
    await HiveStorage.init();
  }
});
