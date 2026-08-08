// app_shell.dart
//
// The app's bottom-navigation shell — the Scaffold + NavigationBar every
// top-level tab (Dashboard, Calendar, ...) lives inside. Wired via
// go_router's StatefulShellRoute, which hands this widget a
// [StatefulNavigationShell] that already knows the current tab index and
// how to switch branches — this widget stays purely presentational,
// matching the rest of the app's "widgets render state, they don't compute
// it" rule (see ARCHITECTURE.md).
//
// Per docs/Design_System.md Section 8.7: active tab gets a rounded-filled
// icon, inactive tabs get an outlined icon, and labels stay visible on
// every tab (never hidden on inactive ones) — hiding them would break
// docs/UI_UX_Principles.md Section 4's "always know where you are".
//
// Lives in routing/ rather than core/widgets/ or a feature folder: it isn't
// a generic reusable component (there's only ever one shell) and it isn't
// feature-specific — it's the routing layer's own chrome, built around a
// go_router-specific type ([StatefulNavigationShell]).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Scaffold + [NavigationBar] shared by every top-level tab.
class AppShell extends StatelessWidget {
  /// Creates the app's bottom-navigation shell.
  const AppShell({super.key, required this.navigationShell});

  /// The active shell route branch (which tab is selected, and how to
  /// switch between them) — supplied by go_router's `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each branch keeps its own navigation state (e.g. scroll position)
      // when switching away and back, since `navigationShell` renders all
      // branches in an IndexedStack rather than rebuilding the tapped one
      // from scratch.
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        // Explicit rather than relying on the default, so this matches
        // docs/Design_System.md Section 8.7 by design, not by coincidence.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
