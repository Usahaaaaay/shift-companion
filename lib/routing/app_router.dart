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
//
// PHASE 2.6: this is also where CalendarScreen's `ShiftRepository` is
// constructed — once, here — and handed to the screen via its
// constructor, per that phase's explicit instruction not to wire it
// through a dedicated Riverpod provider yet. Note this is a deliberate,
// temporary departure from decisions/0001's stated intent ("repositories
// are provided via Riverpod providers") — worth revisiting once a
// persistent (e.g. Drift) implementation needs Riverpod's async
// provider support for its own setup.
//
// PHASE 3.2B: `shiftRepository` is now a `DriftShiftRepository`, backed by
// one `AppDatabase` instance constructed right above it — SQLite-backed,
// persistent across restarts. The wiring shape is otherwise unchanged from
// Phase 2.6: still plain constructor injection inside this provider's
// build callback, still no dedicated Riverpod provider, no globals, no
// service locator. CalendarScreen still only ever sees `ShiftRepository`;
// this is the only file in the app that knows a database exists at all.
//
// PHASE 3.6: added `AppRoutes.templates` and its `GoRoute`, a sibling to
// the `StatefulShellRoute` rather than a branch inside it — Template
// Management isn't a top-level tab (there's no third bottom-nav
// destination for it), it's a detail screen reached by pushing on top of
// the shell, the same way `quick_actions_section.dart`'s own long-standing
// "FUTURE NAVIGATION" comment already described as this app's intended
// pattern for exactly this kind of destination. `TemplateManagementScreen`
// receives the same shared `shiftRepository` instance every other route
// here does — no second repository, no new database.
//
// `AppRoutes` itself moved out to app_routes.dart in the same phase: once
// CalendarScreen needed to reference `AppRoutes.templates` to navigate
// there, keeping the constants defined in *this* file (which imports every
// screen, including CalendarScreen) would have made CalendarScreen import
// this file right back — a real circular dependency. app_routes.dart has
// no feature imports at all, so both this file and any screen can safely
// depend on it.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../database/app_database.dart';
import '../features/calendar/data/repositories/drift_shift_repository.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/calendar/presentation/screens/template_management_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Provides the app's [GoRouter] instance.
///
/// Read via `ref.watch(goRouterProvider)` in [lib/app.dart] to configure
/// `MaterialApp.router`. Kept as a provider (rather than a top-level global)
/// so it can later depend on other providers — for example, redirecting
/// based on authentication state — without changing how it's consumed.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  // Constructed once, here — not through a dedicated Riverpod provider,
  // per Phase 2.6's explicit instruction not to introduce new state
  // management for the repository (see this file's header comment). This
  // provider's own build callback only runs once per app session (Riverpod
  // providers are built lazily and cached), so every route that closes
  // over `appDatabase`/`shiftRepository` shares the one instance — exactly
  // one AppDatabase for the app's lifetime, opened here and nowhere else.
  final appDatabase = AppDatabase();
  final shiftRepository = DriftShiftRepository(appDatabase);

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
                builder: (context, state) =>
                    CalendarScreen(repository: shiftRepository),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.templates,
        builder: (context, state) =>
            TemplateManagementScreen(repository: shiftRepository),
      ),
    ],
  );
});
