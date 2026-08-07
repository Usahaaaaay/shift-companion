// app_typography.dart
//
// Defines the app's type scale.
//
// Per docs/UI_UX_Principles.md (Section 6, "Typography Guidelines"), the app
// uses a small, deliberate set of text styles applied consistently, rather
// than ad hoc sizing per screen. This file builds a Material 3 `TextTheme` so
// it plugs directly into ThemeData (see lib/core/theme/app_theme.dart), plus a
// couple of extra styles for content that Material's default roles don't
// quite cover.

import 'package:flutter/material.dart';

/// Central place for every text style used across the app.
abstract final class AppTypography {
  /// Builds the app's [TextTheme], tinted with the given `onSurface` color so
  /// text remains legible in both light and dark mode. Material 3's default
  /// type scale (displayLarge down to labelSmall) is already a well-considered,
  /// restrained hierarchy, so we lean on it directly rather than inventing a
  /// parallel one — this keeps every widget that reads `Theme.of(context)
  /// .textTheme` consistent for free, without extra wiring.
  static TextTheme textTheme(Color onSurface) {
    return Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(bodyColor: onSurface, displayColor: onSurface);
  }

  /// A style reserved for glanceable numeric content — countdown timers,
  /// earnings figures, hours worked. These are the single most
  /// time-pressured pieces of information in the app (see
  /// docs/UI_UX_Principles.md Section 6: "numerals get special care"), so
  /// they get a distinct, prominent, tabular-figured style that isn't part of
  /// Material's standard text roles. Not wired into any screen yet — this is
  /// reusable infrastructure for the Countdown Timer, Break Timer, and
  /// Earnings features to use when they're built.
  static const TextStyle glanceableNumeral = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.5,
  );
}
