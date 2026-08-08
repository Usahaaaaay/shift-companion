# Shift Companion — UI/UX Principles

*This document defines the design philosophy every future screen must follow. It does
not design any individual screen, and it does not describe implementation. When a screen
is designed later, it should be evaluated against these principles rather than against
personal taste in the moment.*

*Related documents: [VISION.md](VISION.md) (Sections 8–9, Product & Design Principles —
this document expands on those), [Software_Requirements.md](Software_Requirements.md)
(Section 10, Accessibility Requirements — this document's Section 15 implements those
requirements visually), [UX_Design_Plan.md](UX_Design_Plan.md) (where these principles
get applied screen-by-screen — navigation, information architecture, and the Calendar's
interaction model), [Design_System.md](Design_System.md) (where these principles become
concrete tokens and component specs — colors, spacing, typography, motion).*

---

## 1. Design Philosophy

Shift Companion should feel clean, modern, and premium — the kind of app that feels
considered rather than assembled. Its foundation is **Material 3**, used fully and
correctly, but its bar for craft is **Apple-level polish**: consistent spacing, honest
motion, and no rough edges. Premium here does not mean elaborate — it means every detail
is deliberate and nothing feels accidental.

The app is designed for the specific reality of its user: someone checking it while
tired at the end of a shift, often with one hand, often in a hurry. Every principle below
exists in service of that person, not in service of visual novelty. When a design choice
would impress a designer but slow down a tired user, the tired user wins.

## 2. User Experience Principles

- **Minimal taps to complete a task.** Common actions — checking the next shift, logging
  a break, viewing a leave balance — should take as few taps as the task honestly
  requires, never more.
- **Designed for one-handed use.** Primary actions and navigation live where a thumb can
  comfortably reach them; the user should rarely need a second hand.
- **Glanceable first, detailed second.** The most important piece of information on any
  screen should be understandable in under two seconds, before the user reads anything
  else.
- **Progressive disclosure.** Show what's needed now; let the user opt into more detail.
  Never front-load a screen with everything it's capable of showing.
- **Forgiving, not fragile.** Mistakes should be easy to undo. Confirmation prompts are
  reserved for genuinely destructive or hard-to-reverse actions — not sprinkled
  everywhere out of caution.
- **Predictability over cleverness.** A user who learns one part of the app should be
  able to predict how the rest of it behaves.
- **Respect attention as a finite resource.** No screen should ask for more focus than
  the task actually requires.

## 3. Visual Design Principles

- **Calm over busy.** Generous spacing and restraint are treated as design features, not
  empty space to be filled.
- **Hierarchy through structure, not decoration.** Importance is communicated with size,
  weight, position, and color role — never with excess ornamentation.
- **Purposeful elevation.** Shadow and surface elevation are used to indicate meaningful
  layering (e.g., a card above a background, a sheet above a screen), not applied
  decoratively.
- **Restraint is premium.** A small, well-used set of visual tools, applied consistently,
  reads as higher quality than a large one used inconsistently.
- **Every element earns its place.** If a visual element doesn't help the user understand
  or act, it doesn't belong on the screen.

## 4. Navigation Principles

- **Primary navigation stays within thumb reach**, reflecting the one-handed-use
  requirement — core sections of the app are always reachable from a consistent,
  bottom-anchored location.
- **Shallow by default.** A user should be able to reach any primary task within two to
  three taps from the Dashboard.
- **Always know where you are.** The current section of the app is visually obvious at
  all times.
- **No dead ends.** Every screen offers a clear way forward or back; the user is never
  stranded.
- **Modals are for focused, temporary tasks only** — quick actions the user should
  return from immediately, not alternate homes for primary content.
- **Back behavior is consistent** across the entire app; it always returns the user to
  where they logically came from.

## 5. Color Philosophy

- **A calm neutral base with one confident accent.** Neutrals carry most of the
  interface; a single accent color is reserved for primary actions and key emphasis, so
  it retains meaning.
- **Color communicates status, but never alone.** Shift types, leave types, and states
  (e.g., success, warning, critical) are color-coded for quick recognition, but always
  paired with a label, icon, or text so meaning survives for users who can't rely on
  color (see [Section 15](#15-accessibility-principles)).
- **Consistent status colors app-wide.** Once a color means "warning" or "on leave," it
  means that everywhere in the app, with no exceptions.
- **Built on Material 3's tonal system**, so color adapts coherently across light mode,
  dark mode, and possible dynamic theming — without ever losing brand identity or
  contrast.
- **Alarm is reserved for alarm.** High-intensity, warning-toned color is used only for
  genuinely important states, so it never loses its ability to grab attention when it
  matters.

## 6. Typography Guidelines

- **A small, deliberate type scale.** A limited set of sizes and weights is used
  consistently, rather than ad hoc sizing per screen.
- **Legibility above style.** Typeface and sizing choices prioritize fast, effortless
  reading — especially for a tired user glancing at the screen briefly.
- **Text respects system font-size settings.** Type scales with the user's chosen device
  text size without breaking layout.
- **Numerals get special care.** Times, countdowns, and money are the most
  glance-critical content in the app; they are given clear visual weight and consistent,
  aligned presentation so they can be read at a glance, not parsed.
- **Minimal decorative typography.** No unnecessary all-caps, ornamental weights, or
  styling that trades clarity for flourish.

## 7. Icon Guidelines

- **One consistent icon language.** All icons share a single visual style (weight,
  geometry, level of detail) so the interface never feels stitched together from
  different sources.
- **Icons support text; they don't replace it** for anything critical to understanding —
  navigation and status icons are paired with a label wherever the meaning matters.
- **Simple and geometric**, in keeping with Material 3's icon language, sized generously
  enough to be legible and comfortably tappable.
- **Meaningful, not decorative.** An icon appears because it aids recognition or speed,
  not to fill visual space.

## 8. Card & Layout Guidelines

- **One clear purpose per card.** A card presents a single, coherent piece of
  information (e.g., "next shift," "leave balance") rather than several unrelated facts
  competing for attention.
- **Consistent spacing rhythm.** Padding and spacing follow a shared, predictable scale
  throughout the app, so screens feel like they belong to the same product.
- **Soft, quiet separation.** Cards and sections are distinguished through spacing and
  gentle elevation rather than heavy borders or harsh contrast.
- **Consistent corner and edge language.** Rounding and edge treatment are applied the
  same way everywhere, reinforcing a single, cohesive visual identity.
- **Layouts adapt gracefully** to different screen sizes without content feeling cramped
  or, conversely, sparse and disconnected.

## 9. Button Guidelines

- **One clear primary action per screen** wherever possible — the user should never have
  to guess what the most important next step is.
- **Primary actions are large, thumb-reachable, and visually confident**; secondary and
  tertiary actions are visually quieter, so hierarchy is obvious without reading labels.
- **Destructive actions look different.** Anything that deletes or irreversibly changes
  data is visually distinct from routine actions and is never positioned where it could
  be tapped by accident.
- **Touch targets are generous** everywhere, not just on primary buttons — every
  interactive element is sized for a confident, one-handed tap.
- **Consistent sizing and placement.** A button of a given importance looks and behaves
  the same wherever it appears in the app.

## 10. Form Design Guidelines

- **Ask for less.** Only request information the app genuinely needs; optional fields
  are clearly marked as optional and kept to a minimum.
- **Smart defaults reduce typing.** Wherever a sensible default can be inferred (e.g.,
  from a shift pattern or prior entry), it's pre-filled rather than left for the user to
  enter from scratch.
- **Inline, friendly validation.** Errors are shown as the user works, in plain language,
  next to the field they concern — never as a generic message after submission.
- **Logical grouping.** Related fields are grouped and ordered in the sequence a user
  would naturally think through them.
- **Large, forgiving inputs.** Fields and controls are sized for quick, accurate
  one-handed entry, especially for time and date input.
- **Long entry tasks are resumable.** A user interrupted partway through a longer form
  (e.g., defining a shift pattern) does not lose their progress.

## 11. Animation Principles

- **Motion explains, it doesn't decorate.** Animation is used to clarify what changed —
  an item appearing, a state transitioning, a screen relating to the one before it — not
  to entertain.
- **Quick and quiet.** Motion is brief enough to never make the user wait; nothing about
  the app's animation should feel like it's slowing someone down who wants to move fast.
- **Consistent motion language.** Timing and easing feel like they come from the same
  hand across every screen and interaction.
- **Calm by default.** In keeping with the app's overall tone, animation is understated
  rather than showy — confidence expressed through restraint.
- **Reduced-motion is honored.** Users who prefer reduced motion get a calmer, simplified
  version of every transition, never a broken one.

## 12. Empty States

- **Every empty state explains itself.** A screen with nothing on it tells the user why,
  in plain language — never just blank space.
- **Every empty state offers a next step.** Wherever relevant, the empty state points
  directly at the action that would fill it (e.g., adding a first shift or setting up a
  pattern).
- **Tone is encouraging, not clinical.** Empty states read as a helpful starting point,
  not an error or an absence.
- **Visually consistent with the rest of the app** — an empty state should feel like part
  of the product, not a fallback placeholder.

## 13. Loading States

- **Every action gives immediate feedback.** The user should never wonder whether a tap
  registered.
- **Perceived speed matters as much as actual speed.** Where content takes a moment to
  appear, the app shows a structured placeholder reflecting the eventual layout, rather
  than a blank screen or a generic spinner, wherever practical.
- **Brief and long waits are distinguished.** A near-instant load doesn't need a visible
  loading state at all; a longer one clearly communicates that something is happening.
- **Offline is not the same as loading.** When the app has no connection, it says so
  clearly rather than appearing to load indefinitely (consistent with the offline
  behavior defined in the Software Requirements Specification).

## 14. Error States

- **Human language, not technical language.** Errors are explained in terms the user
  understands, never as raw technical detail.
- **Every error says what to do next.** A message that only states a problem without a
  path forward is incomplete.
- **Data is never silently lost.** If an error interrupts an action, whatever the user
  already entered is preserved wherever possible.
- **Calm, not alarming tone**, reserving stronger visual treatment for errors that are
  genuinely urgent (e.g., data conflicts) versus routine, recoverable ones (e.g., a
  failed sync that will retry automatically).
- **Consistent visual treatment.** An error looks and reads the same way everywhere in
  the app, so the user immediately recognizes it as an error.

## 15. Accessibility Principles

This section defines how the app's visual design fulfills the accessibility
requirements set out in the Software Requirements Specification.

- **Contrast is sufficient in every state**, including hover/pressed/disabled states, and
  in both light and dark mode.
- **Color is never the only signal.** Status, category, and meaning are always
  reinforced with text, icon, or shape.
- **Text scales without breaking.** Layouts accommodate larger system text sizes without
  clipping, overlapping, or hiding content.
- **Touch targets meet a comfortable minimum size**, regardless of how dense a screen's
  information is.
- **Every interactive element is properly labeled** for assistive technology, including
  icon-only controls.
- **Focus and reading order are logical**, so screen-reader and keyboard/switch
  navigation follow the same sensible path a sighted user would follow visually.
- **Motion sensitivity is respected**, per [Section 11](#11-animation-principles).

## 16. Dark Mode Principles

- **Dark mode is a first-class design, not an inversion.** It is designed deliberately,
  not generated by flipping the light-mode palette.
- **Hierarchy is preserved.** Whatever is most important in light mode remains most
  visually prominent in dark mode, using Material 3's tonal surface system to convey
  elevation instead of relying on light-mode-style shadows.
- **No harsh extremes.** Dark mode avoids pure black backgrounds and pure white text
  ("true dark" contrast), favoring a softer, considered palette that's comfortable for
  extended viewing.
- **Brand identity carries across modes.** The accent color and overall character of the
  app are recognizably the same in dark mode as in light mode, adapted for contrast
  rather than replaced.
- **Every status color is verified in both modes.** Nothing that relies on color to
  communicate meaning is allowed to lose clarity when the mode switches.

## 17. Consistency Rules

- **The same interaction always looks the same.** If two features behave identically,
  they should look identical; if they look different, the user should be able to infer
  they behave differently.
- **Shared patterns are reused, not reinvented.** A new screen should first look to how
  an existing screen solved a similar problem before introducing a new pattern.
- **One spacing and sizing scale for the whole app.** No screen invents its own spacing
  logic.
- **Shared terminology.** Labels and names used in the interface match the terms defined
  in the Software Requirements Specification's glossary — the same concept is never
  called two different things in two different places.
- **No screen should feel like a different app.** Every part of Shift Companion should
  be recognizable as the same product, built by the same hand, to the same standard.
- **Deviation requires justification.** A screen may depart from an established pattern
  only when the task genuinely requires it — and that reasoning should be explainable,
  consistent with this project's practice of explaining design decisions before making
  them.
