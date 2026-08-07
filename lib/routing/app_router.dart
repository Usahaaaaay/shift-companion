// app_router.dart
//
// Configures the app's navigation using go_router, exposed through a
// Riverpod provider so the router is dependency-injected like everything
// else in the app rather than being a global singleton (see
// decisions/0001-state-management-and-navigation.md).
//
// Per docs/ARCHITECTURE.md, routes are declared centrally here — screens
// don't call Navigator.push directly, and don't need to know how they were
// reached. Right now there is exactly one route: the Dashboard, which the
// app launches straight into.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

/// Centralized route path constants, so a route is always referenced by name
/// (`AppRoutes.dashboard`) rather than a raw string repeated across the
/// codebase.
abstract final class AppRoutes {
  /// The Dashboard — the app's landing screen (see
  /// docs/Software_Requirements.md Section 5.1).
  static const String dashboard = '/';
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
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
