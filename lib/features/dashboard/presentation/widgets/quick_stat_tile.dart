// quick_stat_tile.dart
//
// A single figure in the Dashboard's Quick Stats grid (see
// quick_stats_grid.dart), e.g. "34.5 / hrs this week". Split out as its own
// widget — rather than inlined in the grid — so it stays reusable if the
// grid's layout ever needs to change independently of how a single stat
// renders, per CLAUDE.md's "use reusable components instead of
// copy-pasting UI".
//
// VISUAL REFRESH: the number now leads — large and bold — with a small,
// lowercase, muted caption underneath, instead of a label-above-value
// layout. The icon shrinks to a quiet corner mark rather than competing
// with the figure it describes, and the tile sits on a lighter tonal
// surface than the app's default card so this grid reads as secondary to
// TodayShiftCard.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/dashboard_summary.dart';

/// One compact card showing a single Quick Stats figure.
class QuickStatTile extends StatelessWidget {
  /// Creates a Quick Stats tile.
  const QuickStatTile({super.key, required this.stat});

  /// The figure this tile displays.
  final QuickStat stat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final meta = _metaFor(stat.type);

    return Card(
      margin: EdgeInsets.zero,
      // A lighter tonal surface than the default card color — "cards
      // should feel lighter" — so these four tiles read as calm background
      // detail beneath TodayShiftCard's hero treatment.
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              meta.icon,
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.sm),
            // The number is the focus of the tile — large and bold — with
            // its caption demoted underneath, per this task's Quick Stats
            // requirements ("make the number the focus").
            Text(
              _heroValue(stat.value),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              meta.caption,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (stat.subtitle != null)
              Text(
                stat.subtitle!,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  /// Strips a trailing " hrs" unit off [value] so the hero number reads as
  /// a bare figure (e.g. "34.5") — the unit is folded into the tile's
  /// caption instead (see [_StatMeta.caption]) so it isn't said twice.
  /// Values with no unit to strip (e.g. "Tomorrow", "None") pass through
  /// unchanged.
  static String _heroValue(String value) {
    const unitSuffix = ' hrs';
    return value.endsWith(unitSuffix)
        ? value.substring(0, value.length - unitSuffix.length)
        : value;
  }

  /// Maps a [QuickStatType] to its icon and caption — a presentation
  /// concern kept out of the domain entity (see ARCHITECTURE.md).
  static _StatMeta _metaFor(QuickStatType type) {
    switch (type) {
      case QuickStatType.hoursThisWeek:
        return const _StatMeta(Icons.access_time, 'hrs this week');
      case QuickStatType.nextShift:
        return const _StatMeta(Icons.event_outlined, 'next shift');
      case QuickStatType.nextLeave:
        return const _StatMeta(Icons.beach_access_outlined, 'next leave');
      case QuickStatType.thisMonth:
        return const _StatMeta(Icons.calendar_month_outlined, 'hrs this month');
    }
  }
}

/// The icon/caption a [QuickStatTile] needs for a given [QuickStatType].
class _StatMeta {
  const _StatMeta(this.icon, this.caption);

  final IconData icon;
  final String caption;
}
