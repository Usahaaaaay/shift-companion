// app_theme.dart
//
// Assembles the app's light and dark ThemeData from the color and typography
// constants. This is the single place that turns AppColors + AppTypography
// into something Flutter's widgets actually consume via `Theme.of(context)`.
//
// Per docs/UI_UX_Principles.md Section 16 ("Dark Mode Principles"), dark mode
// is treated as a first-class design, not an inversion — both themes are
// built from the same seed color via Material 3's tonal palette, so
// hierarchy and brand identity carry across both consistently, rather than
// dark mode being a manually-tweaked afterthought.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Builds the app's light and dark [ThemeData].
///
/// Screens should never construct their own [ThemeData] or override colors
/// ad hoc — all visual styling should flow from here so the app stays
/// consistent (see docs/UI_UX_Principles.md Section 17, "Consistency Rules").
abstract final class AppTheme {
  /// The app's light theme.
  static ThemeData get light => _buildTheme(Brightness.light);

  /// The app's dark theme.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// Shared construction logic for both brightness variants, so light and
  /// dark mode can never accidentally drift apart in how they're assembled.
  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      // Material 3 is the app's design foundation (see
      // docs/UI_UX_Principles.md Section 1) and is Flutter's default as of
      // this SDK version, so no explicit flag is needed here.
      textTheme: AppTypography.textTheme(colorScheme.onSurface),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      // Ensures every interactive element defaults to a comfortably large
      // tap target, per docs/UI_UX_Principles.md Section 9 ("Button
      // Guidelines") and Section 15 ("Accessibility Principles").
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
