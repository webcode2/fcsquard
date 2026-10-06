import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to manage the active tab index across the application.
///
/// Indices:
/// 0 - MY SQUAD
/// 1 - GENERATE
/// 2 - VAULT
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 1; // Default to GENERATE tab

  void setTab(int index) {
    state = index;
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  NavigationNotifier.new,
);
