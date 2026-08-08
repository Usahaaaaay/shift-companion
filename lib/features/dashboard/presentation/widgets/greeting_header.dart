// greeting_header.dart
//
// The Dashboard's top-of-screen header: a time-of-day greeting plus today's
// date. Deliberately rendered inline at the top of the scrollable body
// rather than as a Scaffold `AppBar` — the Dashboard is the app's landing
// screen (no back button, nothing to navigate "up" from), so a plain header
// gives the greeting more visual weight and avoids the fixed height and
// bottom chrome a Material AppBar would add, in keeping with
// docs/UI_UX_Principles.md Section 3 ("calm over busy").
//
// VISUAL REFRESH: the greeting now leads with large, confident type (an
// Apple-Health-style "headline of the screen") with the weekday and date
// demoted to a small, quiet line underneath, and the emoji swapped for a
// subtle Material icon so the header reads as one considered piece of type
// rather than a decorated title. See DashboardScreen for the fade-in this
// header participates in.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_date_format.dart';

/// Greets the user by name, with a message and icon that vary by time of
/// day, followed by today's weekday and date.
class GreetingHeader extends StatelessWidget {
  /// Creates the Dashboard's greeting header.
  const GreetingHeader({super.key, required this.name});

  /// The name to greet the user with, e.g. "Sheng".
  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '${_greeting(now.hour)}, $name',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // A subtle sun/moon icon rather than an emoji, so the header
            // reads as Material type rather than borrowed decoration — see
            // docs/UI_UX_Principles.md Section 7 ("one consistent icon
            // language").
            Icon(
              _icon(now.hour),
              size: 26,
              color: _iconColor(now.hour, colorScheme),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppDateFormat.weekday(now),
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          AppDateFormat.dayMonth(now),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Picks the greeting word for the given hour (24h clock). This is
  /// display-only formatting, not a business rule, so it lives here in the
  /// widget rather than in a domain use case — see ARCHITECTURE.md's
  /// presentation-vs-domain split.
  static String _greeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Picks the icon to match [_greeting]'s time bands: a fuller sun in the
  /// morning, a softer daylight icon in the afternoon, a moon in the
  /// evening.
  static IconData _icon(int hour) {
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.dark_mode_rounded;
  }

  /// Picks the icon's color. Tonal and low-opacity by design — "a subtle
  /// sun/moon icon", not a bright decorative one — and drawn from the
  /// theme's tonal palette so it stays correct in both light and dark mode
  /// without a hardcoded color.
  static Color _iconColor(int hour, ColorScheme colorScheme) {
    final base = hour < 17 ? colorScheme.primary : colorScheme.tertiary;
    return base.withValues(alpha: 0.55);
  }
}
