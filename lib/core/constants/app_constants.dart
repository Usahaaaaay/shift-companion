// app_constants.dart
//
// General, reusable, non-visual constants used across the app — app
// metadata and interaction/motion timings that don't belong in the color,
// typography, or spacing scales.

/// Central place for miscellaneous app-wide constants that every feature can
/// share, so these values are defined once instead of being copy-pasted (or
/// silently drifting out of sync) across screens.
abstract final class AppConstants {
  /// The app's display name, used anywhere the app refers to itself in UI
  /// copy (as opposed to the OS-level app name, which is set separately per
  /// platform).
  static const String appName = 'Shift Companion';

  // --- Motion ---------------------------------------------------------
  // Per docs/UI_UX_Principles.md (Section 11, "Animation Principles"):
  // motion should be "quick and quiet" and share "a consistent motion
  // language" across every screen. These durations are that shared language —
  // future widgets should animate using these values rather than picking
  // their own.

  /// Duration for small, local transitions (e.g. a button's pressed state).
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Duration for standard transitions (e.g. a card appearing, a value
  /// updating). The default choice when in doubt.
  static const Duration animationStandard = Duration(milliseconds: 250);

  /// Duration for larger, full-screen transitions (e.g. page navigation).
  static const Duration animationSlow = Duration(milliseconds: 350);

  // --- Interaction ------------------------------------------------------
  // Per docs/UI_UX_Principles.md (Section 15, "Accessibility Principles" —
  // "touch targets meet a comfortable minimum size") and Section 9 ("Button
  // Guidelines" — "touch targets are generous everywhere").

  /// The minimum comfortable size, in logical pixels, for any tappable
  /// element in the app.
  static const double minTouchTarget = 48;
}
