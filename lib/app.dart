// app.dart
//
// The app's root widget. Wires together the theme (lib/core/theme) and the
// router (lib/routing) into a single MaterialApp.router. Per
// docs/ARCHITECTURE.md, this file's only job is that wiring — it holds no
// business logic and no feature-specific code.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// The root widget of Shift Companion.
///
/// A [ConsumerWidget] so it can read [goRouterProvider] from Riverpod — this
/// is the one place the router and the app's theming come together. Every
/// screen beneath this widget reaches the same theme and router
/// configuration through Flutter's [MaterialApp.router] itself, not by
/// re-reading these providers directly.
class ShiftCompanionApp extends ConsumerWidget {
  /// Creates the app's root widget.
  const ShiftCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Shift Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Follows the device's system setting by default, in line with
      // docs/UI_UX_Principles.md Section 16 treating dark mode as a
      // first-class, fully supported experience rather than an opt-in.
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
