// app_routes.dart
//
// Centralized route path constants (Phase 3.6 extraction) — split out of
// app_router.dart specifically so a *feature* screen (CalendarScreen,
// navigating to Template Management) can reference a route path without
// importing app_router.dart itself, which imports every feature's screens
// to wire them into routes. Importing app_router.dart back from a feature
// would be a real circular dependency (app_router -> CalendarScreen ->
// app_router); importing this file instead doesn't, since it has no
// feature imports of its own — just plain string constants.
//
// This is the standard go_router pattern for exactly this situation: a
// route-constants file every screen can safely depend on, separate from
// the router-construction file that depends on every screen.

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

  /// Template Management — where a user creates, edits, and deletes their
  /// Shift Templates. Not a bottom-nav tab; reached by pushing on top of
  /// whichever tab is active (currently, an action on the Calendar tab's
  /// AppBar).
  static const String templates = '/templates';
}
