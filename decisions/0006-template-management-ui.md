# 0006: Template Management UI — placement and route structure

**Status:** Accepted (2026-08-09)

## Context

Phase 3.4 built the template *data* layer (entity, repository methods, Drift table, default
seeding) and a read-only selector inside the shift form. Nothing let a user create, edit, or
delete a template — `saveTemplate`/`updateTemplate`/`deleteTemplate` existed on
`ShiftRepository` but had no UI caller. Phase 3.6 builds that missing UI.

Two open questions needed settling before writing code:

1. **Where does Template Management live in the app's navigation?** The bottom nav has exactly
   two tabs (Dashboard, Calendar) — no Settings tab, no drawer, no existing "management screen"
   precedent anywhere in the app.
2. **How does a screen navigate to it without creating a circular import?** `app_router.dart`
   already imports every screen it wires into a route (that's its whole job). Once a *screen*
   (CalendarScreen) needed to navigate *to* a new route, it needed the route's path — and
   `AppRoutes` lived inside `app_router.dart` itself.

## Decision

**Placement:** Template Management is a plain `GoRoute` (`/templates`), a sibling to the
existing `StatefulShellRoute`, not a third bottom-nav tab. It's reached via an icon button on
`CalendarScreen`'s AppBar (Calendar already has a real AppBar; Dashboard doesn't — see that
screen's own header note). Pushing it shows the screen with a back button, hiding the bottom
nav, exactly like a typical "settings sub-page" in any bottom-nav app — this is additive to the
existing navigation structure, not a redesign of it.

**Route constants:** `AppRoutes` moved out of `app_router.dart` into a new leaf file,
`routing/app_routes.dart`, containing only string constants and no feature imports. Both
`app_router.dart` and `CalendarScreen` depend on this file; neither depends on the other.

**Form/dialog reuse:** `TemplateFormBottomSheet` mirrors `ShiftFormBottomSheet`'s exact shape
(one widget for create and edit, distinguished by whether an existing template is passed in),
and reuses `ShiftTimeField`/`ShiftBreakField`/`CalculatedHoursField` unchanged — a template's
fields look and behave identically to a shift's, because they're the same widgets.
`DeleteTemplateDialog` mirrors `DeleteShiftDialog`'s exact `AlertDialog` structure/styling with
template-specific copy, rather than generalizing both into one parameterized dialog for two call
sites.

## Alternatives considered

- **A third bottom-nav tab ("Templates" or "Settings").** Rejected: the brief explicitly asks
  to avoid inventing new navigation architecture and to keep navigation depth minimal. A rarely
  -visited management screen doesn't earn permanent bottom-nav real estate the way Dashboard and
  Calendar do.
- **Importing `app_router.dart` directly from `CalendarScreen`.** This was the first attempt,
  and it's a real circular dependency: `app_router.dart` imports `calendar_screen.dart` to wire
  it as a route, so `calendar_screen.dart` importing `app_router.dart` back closes a cycle.
  Extracting `AppRoutes` into its own dependency-free file is the standard go_router fix and
  avoids the cycle entirely.
- **Generalizing `DeleteShiftDialog` into one shared `showConfirmationDialog(title, message, ...)`
  helper used by both shifts and templates.** Considered, but not done: the two call sites' copy
  is meaningfully different (the template one exists specifically to clarify shifts aren't
  affected), and introducing a shared parameterized dialog for exactly two call sites is the
  kind of ceremony CLAUDE.md's SOLID caveat ("don't force it where it adds ceremony without
  benefit") argues against. Left as two small, independently-readable files instead.
- **A live "calculated hours" preview in the template form.** Not required by the brief, but
  included: it's a direct, free reuse of `CalculatedHoursField` + `WorkTimeCalculator` already
  built for the shift form, and it visibly reinforces this phase's core architectural rule
  (templates store inputs, hours are always derived) right in the UI where a user might
  otherwise wonder why there's no "hours" field to fill in.

## Consequences

- No repository, schema, or `WorkTimeCalculator` change — every piece of persistence and
  calculation this phase needed already existed.
- `AppRoutes` living in its own file is a small structural change beyond what this phase
  strictly asked for, but was necessary to avoid a real circular import; documented here rather
  than made silently.
- Editing a template can never accidentally insert a duplicate row:
  `TemplateFormBottomSheet` always carries the existing template's `id` in edit mode, and
  `TemplateManagementScreen`'s save handler branches on `template.id == null` to call
  `saveTemplate` (create) vs. `updateTemplate` (edit) — never both, never guessing.
- Deleting a template never touches a shift: `ShiftDetails` already stores its own independent
  copy of every value (no foreign key to the template it was filled in from), a design decision
  made back in Phase 3.4 and unchanged here — see `decisions/0003`.
