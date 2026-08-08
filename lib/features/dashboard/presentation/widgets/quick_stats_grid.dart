// quick_stats_grid.dart
//
// Lays out the Dashboard's four Quick Stats tiles in a fixed 2x2 grid.
//
// VISUAL REFRESH: tile spacing and proportions loosened up (more gap
// between tiles, a slightly taller aspect ratio) to give each figure more
// breathing room, in keeping with this task's overall spacing goals.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/dashboard_summary.dart';
import 'quick_stat_tile.dart';

/// A 2x2 grid of [QuickStatTile]s.
class QuickStatsGrid extends StatelessWidget {
  /// Creates the Quick Stats grid.
  ///
  /// Expects exactly four [stats] — the Dashboard always shows the same
  /// four figures (hours this week, next shift, next leave, this month), so
  /// this is a fixed 2x2 layout rather than a dynamically-sized one.
  const QuickStatsGrid({super.key, required this.stats});

  /// The four Quick Stats figures, in display order (fills left-to-right,
  /// top-to-bottom).
  final List<QuickStat> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      // The grid sits inside the screen's own scrolling column, so it must
      // size itself to its content rather than trying to scroll
      // independently.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [for (final stat in stats) QuickStatTile(stat: stat)],
    );
  }
}
