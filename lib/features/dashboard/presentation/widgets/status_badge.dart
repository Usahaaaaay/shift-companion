// status_badge.dart
//
// A small, pill-shaped label pairing an icon with short text, used to
// communicate a status at a glance — currently only the Today's Shift
// card's "Working Now" / "Upcoming" / "Finished" / "Day Off" indicator.
//
// Lives inside the Dashboard feature (not core/widgets/) for now, per
// core/widgets/README.md's explicit rule: shared components move to
// core/widgets/ only once a *second* feature genuinely needs them, not
// speculatively. If a future feature (leave status, pattern status, sync
// status) needs the same look, promote this widget then.
//
// Per docs/UI_UX_Principles.md Section 5 ("Consistent status colors
// app-wide") and Section 15 (Accessibility Principles): color is never the
// only signal, so every badge pairs its color with both an icon and a text
// label.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// A compact, color-coded status label such as "Working Now" or "Upcoming".
///
/// Deliberately generic: callers choose the [icon], [label], and [color] —
/// this widget only knows how to lay them out consistently. Feature code
/// (see `today_shift_card.dart`) maps its own domain status enum to these
/// three values, keeping this widget free of any domain-layer dependency.
class StatusBadge extends StatelessWidget {
  /// Creates a status badge.
  const StatusBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  /// The icon shown before the label.
  final IconData icon;

  /// The status text, e.g. "Working Now".
  final String label;

  /// The color representing this status. Applied at reduced opacity to the
  /// background and icon backdrop, and at full strength to the icon/text,
  /// so the badge stays legible in both light and dark mode without
  /// needing a separate color per theme.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Announced as a single unit for screen readers, per
      // docs/UI_UX_Principles.md Section 15 ("every interactive element is
      // properly labeled") — this one isn't interactive, but a clear,
      // complete label still matters for anyone using a screen reader.
      label: label,
      child: TweenAnimationBuilder<double>(
        // A small one-shot pop-in (scale + fade) rather than a continuous
        // pulse — a looping animation would keep repainting for as long as
        // the badge is on screen, which this task's Performance/battery
        // guidance (and NFR-6) argues against for something this minor.
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(scale: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
