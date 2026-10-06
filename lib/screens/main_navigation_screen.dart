import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'my_squad_screen.dart';
import 'generate_screen.dart';
import 'vault_history_screen.dart';
import '../providers/storage_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/onboarding_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shell widget that hosts the three main tabs via a [BottomNavigationBar].
///
/// Uses an [IndexedStack] so all screens remain alive in memory — this keeps
/// scroll positions and state intact when switching tabs.
///
/// **Tab index map**:
/// | Index | Tab      | Screen                |
/// |-------|----------|-----------------------|
/// | 0     | MY SQUAD | [MySquadScreen]       |
/// | 1     | GENERATE | [GenerateScreen]      |
/// | 2     | VAULT    | [VaultHistoryScreen]  |
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  // Navigation is now managed via navigationProvider for cross-screen control.

  // Track the last time the back button was pressed to support "double back to exit".
  DateTime? _lastBackPressTime;

  // Ensures the first-launch onboarding walkthrough is only triggered once per
  // widget lifetime (the service itself also self-gates via Hive storage).
  bool _onboardingChecked = false;

  // All screens are instantiated once and kept alive in the IndexedStack.
  final List<Widget> _screens = [
    const MySquadScreen(),
    const GenerateScreen(),
    const VaultHistoryScreen(),
  ];

  /// Returns the appropriate icon for the running platform.
  ///
  /// - **iOS / macOS** → [CupertinoIcons] for platform-native look.
  /// - **Android / other** → Material [Icons] for consistency with MD3.
  ///
  /// Called at build time, so the correct icon is always shown regardless of
  /// how the app was compiled.
  Widget _icon(IconData material, IconData cupertino) {
    final isApple =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return Icon(isApple ? cupertino : material);
  }

  @override
  Widget build(BuildContext context) {
    final storageStatus = ref.watch(storageInitializerProvider);

    // ── Loading state ─────────────────────────────────────────────────────
    if (storageStatus.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 12),
              SizedBox(height: 16),
              Text(
                'PREPARING SQUAD...',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Error state — show a recovery screen instead of freezing ──────────
    if (storageStatus.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'STORAGE ERROR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${storageStatus.error}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(storageInitializerProvider),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default to the GENERATE tab (Index 1) for the core match-day flow.
    final currentIndex = ref.watch(navigationProvider);

    // Storage is ready here (loading/error handled above), so it's safe to read
    // the onboarding flag. Trigger the first-launch walkthrough exactly once.
    if (!_onboardingChecked) {
      _onboardingChecked = true;
      OnboardingService.maybeShowOnboarding(context);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBackProgress,
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(navigationProvider.notifier).setTab(index),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                key: OnboardingService.squadNavKey,
                child: _icon(Icons.people_alt_outlined, CupertinoIcons.person_2),
              ),
              activeIcon: _icon(Icons.people, CupertinoIcons.person_2_fill),
              label: 'MY SQUAD',
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: OnboardingService.generateNavKey,
                child: _icon(Icons.bolt_outlined, CupertinoIcons.bolt),
              ),
              activeIcon: _icon(Icons.bolt, Icons.bolt),
              label: 'GENERATE',
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: OnboardingService.statsNavKey,
                child: _icon(Icons.archive_outlined, CupertinoIcons.archivebox),
              ),
              activeIcon: _icon(Icons.archive, CupertinoIcons.archivebox_fill),
              label: 'STATS',
            ),
          ],
        ),
      ),
    );
  }

  /// Senior-level back button handling.
  ///
  /// Prevents accidental app closure with a 2-second press window.
  /// Uses [ScaffoldMessenger.clearSnackBars] to ensure messages don't stack
  /// if the user spams the back button.
  void _handleBackProgress(bool didPop, dynamic result) {
    if (didPop) return;

    final now = DateTime.now();
    final backButtonHasNotBeenPressedRecently =
        _lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (backButtonHasNotBeenPressedRecently) {
      _lastBackPressTime = now;

      // Clear existing SnackBars to prevent stacking/delay in feedback.
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'PRESS BACK AGAIN TO EXIT',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          backgroundColor: Color(0xFF1E88E5), // Premium Blue
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Second press within the 2s window — finalize exit.
      SystemNavigator.pop();
    }
  }
}
