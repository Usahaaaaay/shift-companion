// quick_actions_section.dart
//
// The Dashboard's Quick Actions — large, rounded buttons for the app's
// other primary sections. Per this task's scope, these buttons only
// navigate (or, until their destination screens exist, do nothing at all)
// — no scheduling, editing, or calendar logic lives here or is triggered by
// them.
//
// VISUAL REFRESH: switched from a horizontal icon+label pill to a vertical
// tile — icon in a soft tonal circle, label centered underneath — matching
// the icon-over-title pattern in this task's spec and reading more like a
// set of app shortcuts (Pixel launcher, Apple Health "Browse" tiles) than a
// row of form buttons. Each tile is a full-bleed tap target, larger than
// the previous pill, for a more confident one-handed tap.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// The Dashboard's grid of large, rounded Quick Action tiles.
class QuickActionsSection extends StatelessWidget {
  /// Creates the Quick Actions section.
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // FUTURE NAVIGATION: each action below currently does nothing — none of
    // these destination screens or routes exist yet. Once they do, wire
    // each `onTap` to `context.push(AppRoutes.<destination>)` (see
    // lib/routing/app_router.dart) instead of adding logic here — this
    // widget should stay a pure navigation trigger and never gain business
    // logic of its own.
    const actions = [
      _QuickAction('Add Shift', Icons.add_rounded),
      _QuickAction('Earnings', Icons.payments_outlined),
      _QuickAction('Leave', Icons.beach_access_outlined),
      _QuickAction('History', Icons.history_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          // Squarer than the old 2.2 pill ratio — a shortcut-style tile
          // needs room to stack an icon above its label instead of running
          // them side by side.
          childAspectRatio: 1.3,
          children: [
            for (final action in actions) _QuickActionTile(action: action),
          ],
        ),
      ],
    );
  }
}

/// A single Quick Action's static definition — label and icon. Tap handling
/// is intentionally not part of this (see [_QuickActionTile]): until real
/// routes exist, every action is a no-op, so there's nothing feature-
/// specific to store per action yet.
class _QuickAction {
  const _QuickAction(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// A single large, rounded Quick Action tile: an icon in a soft tonal
/// circle above a label, the whole tile tappable.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        // No-op for now — see the FUTURE NAVIGATION note in
        // QuickActionsSection.build above. The whole tile is the tap
        // target, comfortably above AppConstants.minTouchTarget.
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(action.icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
