# 0003: Shift Templates — minutes-since-midnight storage, and where break lives

**Status:** Accepted (2026-08-09)

## Context

Phase 3.4 adds reusable Shift Templates (Morning/Afternoon/Night, extensible) that pre-fill
the create/edit shift form. Two questions needed settling before writing any code:

1. **How should a template's times be stored?** `ShiftDetails.startTime`/`endTime` (the
   existing shift model) store formatted strings like `"7:00 AM"`. Templates are the first
   place in this codebase that needs to reason about a time range as a *quantity* — future
   phases (hours calculation, overnight-shift detection, payroll, sorting, recurrence) all
   need arithmetic on times, not string comparisons.
2. **Where does a template's default break live once applied?** `ShiftDetails`/`Shifts` had
   no break concept at all before this phase — only start/end/hours/notes. A template's
   `breakMinutes` needed somewhere to land in the per-shift form, and the existing schema
   didn't have a slot for it.

## Decision

**Times as integers.** `ShiftTemplate.startMinutes`/`endMinutes`/`breakMinutes` are stored as
minutes since midnight (e.g. `420` = 7:00 AM), not formatted strings — see
`features/calendar/domain/entities/shift_template.dart` and the new `ShiftTemplates` Drift
table. Converting a minute value to a "7:00 AM"-style string is a presentation-layer concern,
handled by `AppDateFormat.timeOfDayFromMinutes` (`core/utils/app_date_format.dart`) only where
a template's time actually reaches the UI (applying a template to the shift form).

**Break becomes a real, persisted field on `Shift`.** Rather than leaving a template's break
value template-only, `ShiftDetails` and the `Shifts` table both gained a nullable
`breakMinutes` column (schema bumped to version 3), and the create/edit form gained a
matching "Break (minutes)" field — independent of `Hours`, which stays a manually-entered raw
clock span exactly as before this phase. This was a deliberate, explicitly-confirmed choice
over the smaller alternative (keeping break template-only, with no per-shift field at all) —
see the "Alternatives considered" section below for what that would have cost.

## Alternatives considered

- **Store template times as formatted strings, matching `ShiftDetails`.** Rejected: this is
  exactly what this phase's brief calls out as the thing to avoid — "future phases should
  never need to parse '07:00' repeatedly." An integer offset makes duration, overnight-wrap,
  and sort-order arithmetic trivial in a way re-parsing a string on every read never would be.
- **Keep break template-only, with no field on `Shift`/`Shifts` at all.** The smaller,
  zero-migration option: applying a template would only fill Start/Finish/Notes, and a
  template's break value would exist solely to be *shown* on the template itself, never
  copied anywhere durable. Rejected in favor of persisting it: a break entered while applying
  a template would otherwise silently vanish the moment the shift was saved and reopened,
  which undermines exactly the "the user may edit every field afterward" expectation this
  phase's brief sets for every other templated field, and would leave no real per-shift break
  data for the payroll/hours-calculation phases this design is explicitly meant to unblock.
- **Auto-compute `Hours` from `Finish − Start − Break` when a template is applied.** Rejected:
  `Hours` has always been the raw clock span (see `ShiftDetails.placeholderFor`, which stores
  8 hours for a Morning shift's exact 7:00 AM–3:00 PM span, no break subtracted). Tying it to
  break here would silently change what "Hours" means for every shift, not just templated
  ones. `Hours` stays independently, manually entered, same as before this phase.
- **A separate `ShiftTemplateRepository` interface.** Rejected in favor of adding the four
  template methods directly to the existing `ShiftRepository` — this phase's own brief asks
  to "extend the repository abstraction," and `CalendarScreen` already depends on exactly one
  repository type for every Calendar-feature storage need; splitting it would be a bigger
  change than templates require.

## Consequences

- `AppDatabase.schemaVersion` is now 3. The upgrade path from schema 2 adds `Shifts.
  breakMinutes` (a plain nullable column — `addColumn`, no `TableMigration` recreate needed,
  unlike the v1→v2 change) and creates `ShiftTemplates`, then seeds the three default
  templates. Both the fresh-`onCreate` and `onUpgrade`-from-`<3` paths call the same
  `AppDatabase._insertDefaultTemplates`, so seeding is a persistence-layer concern living
  entirely inside `AppDatabase` — the repository layer never needs to know it happened, and
  it runs at most once per database's lifetime by construction (a database is only ever
  created once; only ever upgraded past version 3 once).
- `ShiftTemplates`' generated Drift row class is renamed via `@DataClassName
  ('ShiftTemplateRow')` — Drift's default singularization would otherwise generate a class
  named `ShiftTemplate`, colliding with the domain entity of the same name.
- Both `DriftShiftRepository` and `MemoryShiftRepository` implement all four new
  `ShiftRepository` methods (`getTemplates`/`saveTemplate`/`updateTemplate`/`deleteTemplate`),
  keeping the two implementations in parity, per this codebase's existing convention.
- Existing shifts are unaffected: `breakMinutes` is nullable and defaults to absent on every
  already-saved row; `Hours`' meaning and every other existing field are untouched.
