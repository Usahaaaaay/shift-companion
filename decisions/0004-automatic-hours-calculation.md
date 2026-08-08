# 0004: Automatic hours calculation — structured time fields, no schema change

**Status:** Accepted (2026-08-09)

## Context

Phase 3.5 removes manual Hours entry: worked hours must be calculated live from Start,
Finish, and Break, using minute arithmetic that correctly handles overnight shifts.

The brief assumed the app already stores a shift's start/finish as `startMinutes`/
`endMinutes` integers, matching `ShiftTemplate`'s shape (decision 0003). It doesn't: `Shift`/
`ShiftDetails` has only ever stored `startTime`/`endTime` as **free-text strings** (e.g.
`"7:00 AM"`), typed into a plain `TextField` with a hint — a design that predates Phase 3.4's
minutes convention and was never migrated, because Phase 3.4 deliberately scoped minutes-based
storage to templates only. There is also no existing time picker anywhere in this codebase to
"reuse," as the brief otherwise assumed.

Calculating a duration from two arbitrary strings the user free-types (whitespace, partial
input mid-keystroke, no enforced format) isn't just awkward — the brief itself rules it out
explicitly ("use minute arithmetic rather than parsing strings"), and re-parsing on every
keystroke would produce visibly wrong intermediate values while typing anyway.

## Decision

The shift form's Start/Finish fields become structured: tapping either opens Flutter's
built-in `showTimePicker` (part of the Material framework already in use — no new dependency),
and the picked value is held as `int? minutes` in form state. `WorkTimeCalculator`
(`core/utils/work_time_calculator.dart`, a new pure utility) computes worked hours directly
from that state on every rebuild — no explicit "recalculate" step, no string parsing during
editing.

Persistence is untouched: `ShiftDetails.startTime`/`endTime`/`hours` keep their existing types
and the `Shifts` table keeps its existing columns. The form converts minutes to a formatted
string only at the save boundary (`AppDateFormat.timeOfDayFromMinutes`, already built in Phase
3.4), and parses a saved string back into minutes only once, when opening an *existing* shift
for editing (`AppDateFormat.minutesFromTimeOfDay`, new). That parse is the one remaining
string-to-minutes conversion in the whole feature, and it never runs during live editing.

## Alternatives considered

- **Keep Start/Finish as free text; best-effort parse on every keystroke to drive live Hours.**
  Rejected: directly contradicts the brief's explicit "minute arithmetic, not string parsing"
  instruction, and would flicker/misfire on every incomplete intermediate string while typing
  (e.g. "1", "12", "12:", "12:3" would each attempt a parse). Not a close call.
- **Add `startMinutes`/`endMinutes` columns to the `Shifts` table**, mirroring
  `ShiftTemplate`'s schema exactly. Rejected: the brief explicitly says no schema change, no
  repository API change, and no stored-hours-column unless "absolutely required" — it isn't;
  the existing `hours` column already holds exactly the value this phase needs to persist, and
  `startTime`/`endTime` as formatted strings are sufficient once the *form* (not the database)
  is the thing that needs structured minutes.
- **A stored, always-recomputed `hours` column vs. treating `hours` as truly derived (dropped
  from the schema entirely, computed at read time).** Not adopted: recomputing on every read
  would require parsing `startTime`/`endTime` back into minutes on every `getShift`/
  `getAllShifts` call — reintroducing exactly the "parse strings repeatedly" cost this phase's
  design is meant to avoid, and touching the repository layer, which the brief forbids. Storing
  the already-computed value (as `hours` already does) is both simpler and stays entirely
  within the presentation layer's existing write path.

## Consequences

- No migration, no `schemaVersion` bump, no repository method added or changed — every
  existing shift and every existing `ShiftRepository` call site is untouched.
- The shift form's `_startMinutes`/`_endMinutes` (`int?`) replace what were previously two
  `TextEditingController`s; template application became simpler as a direct result (a
  template's minutes assign straight into form state, no string round-trip).
- A shift saved before this phase with a genuinely unparseable `startTime`/`endTime` (something
  typed into the old free-text field that isn't `AppDateFormat.timeOfDayFromMinutes`'s exact
  shape) degrades gracefully on reopening: the time picker shows "Tap to select" instead of the
  old value, and the user must re-pick before Hours calculates. This is expected to be rare in
  practice — every value this app has ever actually written to those fields came from either
  `timeOfDayFromMinutes` itself (via a template or `ShiftDetails.placeholderFor`) or matches its
  shape — but it's a real, documented compromise, not an assumed-impossible case.
