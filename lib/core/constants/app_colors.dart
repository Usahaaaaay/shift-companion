// app_colors.dart
//
// Defines the color foundation for Shift Companion.
//
// Per docs/UI_UX_Principles.md (Section 5, "Color Philosophy"), the app uses a
// calm neutral base with a single confident accent color, built on Material 3's
// tonal color system so that light mode, dark mode, and contrast all stay
// coherent automatically. Rather than hand-picking dozens of individual colors,
// we provide Flutter's `ColorScheme.fromSeed` with one seed color, and it
// derives a full, accessible tonal palette (surfaces, containers, on-colors,
// etc.) from it. See lib/core/theme/app_theme.dart for where this is consumed.
//
// NOTE: The exact seed color below is a placeholder. No specific brand color
// has been decided yet (see docs/UI_UX_Principles.md Section 5, which
// deliberately stops short of picking real values). It should be revisited and
// possibly formalized as a decision record once branding is finalized.

import 'package:flutter/material.dart';

/// Central place for every color value used across the app.
///
/// Screens and widgets should never hard-code a [Color] directly — they should
/// reference `Theme.of(context).colorScheme` (built from [seed] below) for
/// anything that must adapt between light and dark mode, and reach for the
/// semantic status colors here only for meanings Material's [ColorScheme]
/// doesn't already cover (e.g. "success", which has no built-in role).
abstract final class AppColors {
  /// The single seed color the entire Material 3 tonal palette is derived
  /// from. Chosen as a calm, trustworthy blue — evoking clarity and calm
  /// rather than urgency, in line with the "calm, not cluttered" design
  /// philosophy. Swap this one value to re-theme the whole app.
  static const Color seed = Color(0xFF2E5AAC);

  // --- Semantic status colors -------------------------------------------
  // Material 3's ColorScheme has a built-in "error" role, but no roles for
  // "success" or "warning" — both of which this app will need later (e.g. to
  // indicate a completed shift, or a leave balance running low). They're
  // defined once here so every future feature reaches for the same meaning
  // instead of inventing its own shade of green or amber.
  //
  // Per UI_UX_Principles.md Section 5: these are reserved for genuine status
  // meaning, never used decoratively, and are always paired with a label or
  // icon rather than relied on alone (Section 15, Accessibility Principles).

  /// Indicates a positive/successful state (e.g. a confirmed shift).
  static const Color success = Color(0xFF2E7D4F);

  /// Indicates a state that deserves the user's attention but isn't critical
  /// (e.g. a leave balance running low).
  static const Color warning = Color(0xFFB07A15);

  /// Indicates a critical state requiring action (distinct from Material's
  /// `error` role, which is reserved for validation/system errors).
  static const Color critical = Color(0xFFB3261E);

  /// Indicates a neutral, informational state.
  static const Color info = Color(0xFF3A6EA5);
}
