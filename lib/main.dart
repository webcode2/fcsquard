import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'storage/hive_storage.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

/// App entry point.
///
/// Startup order matters:
/// 1. [WidgetsFlutterBinding.ensureInitialized] — required before any
///    platform channel calls (including Hive file I/O).
/// 2. [Hive.initFlutter] — resolves the platform-specific documents directory.
/// 3. Adapter registration — must happen before any box is opened.
///    Register in dependency order: enums before the class that uses them.
/// 4. [HiveStorage.init] — opens the box; lightweight since data is already
///    on disk from a previous run.
/// 5. [runApp] — wrapped in [ProviderScope] so Riverpod providers are
///    available to the full widget tree.
void main() {
  // Required before any platform channel calls, even if non-blocking.
  WidgetsFlutterBinding.ensureInitialized();

  // Launch immediately. Storage initialization is handled by
  // the [storageInitializerProvider] within the widget tree.
  runApp(const ProviderScope(child: MyApp()));
}

/// Root widget — thin configuration layer only.
///
/// All theme and navigation configuration lives here. Business logic and
/// state belong in providers, not here.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Team Shuffle',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}
