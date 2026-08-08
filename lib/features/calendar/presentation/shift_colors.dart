// shift_colors.dart
//
// Centralized color mapping for ShiftType — the single place that decides
// what color a shift type renders as, so no widget hardcodes a shift color
// inline. Mirrors the existing AppColors pattern
// (core/constants/app_colors.dart): flat, theme-independent hex values,
// declared once, looked up through one static method.
//
// Deliberately distinct from AppColors' semantic colors (success/warning/
// critical/info) even where a shift color and a semantic color both happen
// to land in the same general hue family (e.g. both "green" or "amber") —
// per docs/Design_System.md Section 3.4, shift-state color means exactly
// one thing (what kind of day this is) and status color means another (was
// an action successful); aliasing the same hex to both would let the two
// meanings bleed into each other the moment they appear near one another
// on screen.
//
// KNOWN LIMITATION (matches an existing, already-documented gap — see
// docs/Design_System.md Section 3.4): these are flat hex values with no
// separate dark-mode variant, same as AppColors' existing semantic colors
// today. Acceptable for this UI-only phase; revisit alongside AppColors
// once dark-mode contrast for both is verified.
//
// Lives inside the Calendar feature rather than core/constants/ (where
// AppColors lives) because it depends on ShiftType, which is Calendar-
// scoped domain data — core/ can never import from a features/ folder
// without inverting the dependency direction ARCHITECTURE.md establishes.
// If a second feature (e.g. Dashboard or Leave) later needs the same
// colors, that's the trigger to promote this into core/constants/ instead
// — the same "promote on a real second use" rule already applied to
// core/utils/ and core/widgets/.

import 'package:flutter/material.dart';
import '../domain/entities/shift_type.dart';

/// Looks up the color that represents a given [ShiftType].
abstract final class ShiftColors {
  /// Returns the color for [type]. The one place the rest of the app
  /// should reach for a shift's color — never hardcode one inline.
  static Color colorFor(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return _morning;
      case ShiftType.afternoon:
        return _afternoon;
      case ShiftType.night:
        return _night;
      case ShiftType.off:
        return _off;
      case ShiftType.leave:
        return _leave;
      case ShiftType.publicHoliday:
        return _publicHoliday;
    }
  }

  static const Color _morning = Color(0xFF43A047);
  static const Color _afternoon = Color(0xFF1E88E5);
  static const Color _night = Color(0xFF7E57C2);
  static const Color _off = Color(0xFF9E9E9E);
  static const Color _leave = Color(0xFFFFB300);
  static const Color _publicHoliday = Color(0xFFFB8C00);
}
