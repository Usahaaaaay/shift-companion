// app_router.dart
//
// Configures the app's navigation using go_router, exposed through a
// Riverpod provider so the router is dependency-injected like everything
// else in the app rather than being a global singleton (see
// decisions/0001-state-management-and-navigation.md).
//
// Per docs/ARCHITECTURE.md, routes are declared centrally here — screens
// don't call Navigator.push directly, and don't need to know how they were
// reached.
//
// Dashboard and Calendar are wired as branches of a `StatefulShellRoute`
// rather than two flat `GoRoute`s — go_router's recommended pattern for a
// bottom-navigation app. Each branch keeps its own navigation state when
// the user switches tabs and back, and `AppShell` (routing/app_shell.dart)
// is the single Scaffold + NavigationBar every branch renders inside. This
// is a routing implementation detail, not a new architectural decision —
// it's the expected shape of the go_router choice already recorded in
// decisions/0001, not a fork of it.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'app_shell.dart';

/// Centralized route path constants, so a route is always referenced by name
/// (`AppRoutes.dashboard`) rather than a raw string repeated across the
/// codebase.
abstract final class AppRoutes {
  /// The Dashboard — the app's landing screen (see
  /// docs/Software_Requirements.md Section 5.1).
  static const String dashboard = '/';

  /// The Calendar — the app's monthly schedule view (see
  /// docs/Software_Requirements.md Section 5.2).
  static const String calendar = '/calendar';
}

/// Provides the app's [GoRouter] instance.
///
/// Read via `ref.watch(goRouterProvider)` in [lib/app.dart] to configure
/// `MaterialApp.router`. Kept as a provider (rather than a top-level global)
/// so it can later depend on other providers — for example, redirecting
/// based on authentication state — without changing how it's consumed.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
