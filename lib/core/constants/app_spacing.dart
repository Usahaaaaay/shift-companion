// app_spacing.dart
//
// Defines the app's spacing and corner-radius scale.
//
// Per docs/UI_UX_Principles.md (Section 8, "Card & Layout Guidelines"), every
// screen should follow "one spacing and sizing scale for the whole app" —
// no screen should invent its own padding/margin values. This file is that
// single scale. Corner radius is included here too, since it's part of the
// same "consistent spacing rhythm" the layout guidelines describe, rather
// than a separate concern.

/// Central place for every spacing and corner-radius value used across the
/// app. Widgets should reference these constants (e.g. `AppSpacing.md`)
/// instead of hard-coding raw numbers for padding, gaps, or margins.
abstract final class AppSpacing {
  /// Extra-small spacing — tight gaps between closely related elements
  /// (e.g. an icon and its label).
  static const double xs = 4;

  /// Small spacing — the default gap between related items within a group.
  static const double sm = 8;

  /// Medium spacing — the default padding inside cards and between distinct
  /// groups of content. This is the app's most commonly used spacing value.
  static const double md = 16;

  /// Large spacing — separation between major sections of a screen.
  static const double lg = 24;

  /// Extra-large spacing — top-level page margins and generous breathing
  /// room around a screen's most important content.
  static const double xl = 32;

  /// Extra-extra-large spacing — reserved for rare, deliberate emphasis
  /// (e.g. the space around a hero element on the Dashboard).
  static const double xxl = 48;

  // --- Corner radius -------------------------------------------------
  // Per UI_UX_Principles.md Section 8: "consistent corner and edge language" —
  // rounding is applied the same way everywhere to reinforce one cohesive
  // visual identity.

  /// Standard corner radius for cards, sheets, and most containers.
  static const double radiusMd = 16;

  /// Smaller corner radius for compact elements (e.g. chips, small buttons).
  static const double radiusSm = 8;

  /// Larger corner radius for prominent, full-width surfaces (e.g. modal
  /// sheets).
  static const double radiusLg = 24;
}
