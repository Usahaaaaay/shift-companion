// today_shift_card.dart
//
// The Dashboard's hero: today's shift, front and center. Per
// docs/UI_UX_Principles.md Section 8 ("one clear purpose per card") this
// card shows exactly one thing — today — so nothing else on the screen
// competes with it for attention.
//
// VISUAL REFRESH: shift times are now the card's dominant element — large,
// stacked, and set in AppTypography.glanceableNumeral (the app's dedicated
// style for exactly this kind of glance-critical figure) — with a small
// "TODAY" eyebrow and the status badge above them, and department/hours as
// a quiet icon+text line below. Generous padding and a larger radius keep
// it reading as the single most prominent surface on the screen.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/dashboard_summary.dart';
import 'status_badge.dart';

/// Large, highlighted card summarizing today's shift — the Dashboard's
/// hero element.
class TodayShiftCard extends StatelessWidget {
  /// Creates the Today's Shift card.
  const TodayShiftCard({super.key, required this.shift});

  /// The shift to display.
  final TodayShift shift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusStyle = _statusStyle(shift.status, colorScheme);
    final onCard = colorScheme.onPrimaryContainer;

    return Card(
      margin: EdgeInsets.zero,
      // A tonal container tint (rather than the app's default card surface)
      // is what makes this read as *the* highlighted card on the screen,
      // without resorting to a heavy border or drop shadow — in keeping
      // with Section 3's "purposeful elevation" and "hierarchy through
      // structure, not decoration". A larger radius (radiusLg) marks it as
      // the screen's one prominent surface, per app_spacing.dart's own
      // guidance for that radius.
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      // Generous, above-default padding — "the largest card on the page"
      // earns the most breathing room too.
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TODAY',
                  style: textTheme.labelLarge?.copyWith(
                    color: onCard.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                StatusBadge(
                  icon: statusStyle.icon,
                  label: statusStyle.label,
                  color: statusStyle.color,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Shift times — the single most glance-critical figures on the
            // screen, so they use the app's dedicated glanceable-numeral
            // style (see docs/UI_UX_Principles.md Section 6, "numerals get
            // special care"), stacked with a small connecting arrow rather
            // than run together on one line.
            Text(
              shift.startTime,
              style: AppTypography.glanceableNumeral.copyWith(color: onCard),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 20,
                color: onCard.withValues(alpha: 0.5),
              ),
            ),
            Text(
              shift.endTime,
              style: AppTypography.glanceableNumeral.copyWith(color: onCard),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              icon: Icons.place_outlined,
              text: shift.department,
              color: onCard,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.schedule_outlined,
              text: '${shift.totalHours} hrs total',
              color: onCard,
            ),
          ],
        ),
      ),
    );
  }

  /// Maps a [ShiftStatus] to the icon, label, and color its badge should
  /// use. Kept here (not in the domain entity) because icons and colors are
  /// presentation concerns — see ARCHITECTURE.md's domain/presentation
  /// split.
  static _StatusStyle _statusStyle(
    ShiftStatus status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case ShiftStatus.upcoming:
        return _StatusStyle(Icons.schedule, 'Upcoming', colorScheme.primary);
      case ShiftStatus.workingNow:
        return const _StatusStyle(Icons.bolt, 'Working Now', AppColors.success);
      case ShiftStatus.finished:
        return _StatusStyle(
          Icons.check_circle_outline,
          'Finished',
          colorScheme.outline,
        );
      case ShiftStatus.dayOff:
        return _StatusStyle(
          Icons.weekend_outlined,
          'Day Off',
          colorScheme.tertiary,
        );
    }
  }
}

/// A quiet icon+text line (e.g. department, total hours) — used twice
/// within [TodayShiftCard] so both figures share one consistent, minimal
/// look rather than a heavier pill or chip competing with the hero times
/// above.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// The icon/label/color a [StatusBadge] needs for a given [ShiftStatus].
class _StatusStyle {
  const _StatusStyle(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}
