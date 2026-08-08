// motivation_card.dart
//
// The Dashboard's closing note: one short, contextual message. Kept
// visually the quietest element on the screen — it's a small human touch,
// not something competing for the user's attention (see
// docs/UI_UX_Principles.md Section 3, "restraint is premium"). See
// ../dashboard_mock_data.dart for how the message itself is now chosen
// (time of day + whether today is a shift or a day off) rather than being
// fully random.
//
// VISUAL REFRESH: centered, regular-weight text instead of a left-aligned
// italic line — italics read as a decorative flourish that
// docs/UI_UX_Principles.md Section 6 explicitly discourages ("minimal
// decorative typography"), and a centered line reads more like a calm
// signoff at the bottom of the page.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// A small card displaying a single contextual message.
class MotivationCard extends StatelessWidget {
  /// Creates the Motivation card.
  const MotivationCard({super.key, required this.message});

  /// The message to display, e.g. "Have a great shift!".
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      // A soft secondary tint, distinct from both TodayShiftCard's primary
      // tint and the default card surface, so this reads as a light, quiet
      // aside rather than another data card.
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 18,
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
