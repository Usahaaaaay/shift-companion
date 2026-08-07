// dashboard_screen.dart
//
// Placeholder for the Dashboard screen — the app's landing view, described in
// docs/Software_Requirements.md Section 5.1 and docs/Feature_List.md
// ("Dashboard", Core Features).
//
// This is intentionally a static placeholder with no business logic, no
// state, and no data wired in: its only job right now is to exist as a
// destination for the router so the app has something to launch into. The
// real Dashboard — showing the next shift, countdown, leave balances, and
// earnings summary (FR-DASH-1 through FR-DASH-7) — will replace this in a
// future task, along with the `domain/` and `data/` layers this feature will
// need once it has real behavior.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';

/// The Dashboard screen — currently a placeholder.
///
/// A plain [StatelessWidget] for now since there is no state to hold. Once
/// real functionality is added, this will read from Riverpod providers in
/// `features/dashboard/presentation/providers/` instead of gaining logic of
/// its own, per docs/ARCHITECTURE.md's rule that widgets render state rather
/// than compute it.
class DashboardScreen extends StatelessWidget {
  /// Creates the Dashboard placeholder screen.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to ${AppConstants.appName}',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The Dashboard will appear here once the feature is built.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
