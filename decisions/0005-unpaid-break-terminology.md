# 0005: "Unpaid break" terminology — clarifying what `breakMinutes` deducts

**Status:** Accepted (2026-08-09)

## Context

`breakMinutes` (introduced in Phase 3.4, deducted from worked time by `WorkTimeCalculator`
since Phase 3.5) has only ever meant **unpaid** break time — the domain/data-layer doc comments
have said "unpaid break length" since it was first added. That internal semantic was never
ambiguous. The user-facing UI, however, only ever showed the plain word "Break" — on the shift
form's input field, its "too long" validation message, and the read-only shift-info card's
display row.

A plain "Break" label doesn't tell a user which kind of break it means. A worker who gets a
paid 10-minute rest break *and* an unpaid 40-minute meal break has a real reason to enter the
combined 50 minutes into a field just labeled "Break" — silently producing incorrect (too low)
calculated hours. `WorkTimeCalculator`'s formula was always correct for its actual input; the
risk was purely in what a user might reasonably type into an ambiguously-labeled field.

## Decision

Rename the user-facing label from "Break" to **"Unpaid break"** everywhere it appears:

- The shift form's break input field: "Break (minutes)" → "Unpaid break (minutes)"
  (`shift_break_field.dart`).
- Its validation message: "Break cannot exceed shift duration" → "Unpaid break cannot exceed
  shift duration" (`shift_form_bottom_sheet.dart`).
- The read-only shift-info card's break row label: "Break" → "Unpaid break"
  (`shift_info_card.dart`).

No code identifier changed: `breakMinutes` (domain/data), `ShiftBreakField` (widget class),
`break_minutes` (database column) all keep their existing names — only the three strings a user
actually reads changed. This is a pure terminology fix, not a semantic or schema change.

## Alternatives considered

- **"Unpaid meal break".** The brief's own suggested alternative, preferred only where context
  specifically implies a meal break. Nothing in this app's current UI is meal-specific (a
  night-shift's break isn't necessarily a "meal" in the way a midday break usually is), so the
  more general "Unpaid break" fits every current call site better.
- **Renaming `breakMinutes` itself (e.g. to `unpaidBreakMinutes`).** Rejected: the brief
  explicitly asks not to blindly rename already-correctly-named internal identifiers, and doing
  so here would touch the `Shifts`/`ShiftTemplates` tables, both repository implementations, and
  every call site — a much larger, riskier change for a label wording fix, with no behavioral
  benefit since the internal name was never actually ambiguous to begin with (only its on-screen
  presentation was).
- **Adding a distinct paid-rest-break field/calculation.** Explicitly out of scope for this
  phase (and not something the brief asked for) — `breakMinutes` remains the only break concept
  in this app; a paid-rest-break concept is a future feature, if ever needed, not introduced
  here.

## Consequences

- Zero calculation change: `WorkTimeCalculator` is untouched, and every existing calculation
  test still passes unmodified.
- Zero schema/migration/repository change.
- Future phases (weekly summaries, payroll, statistics) inherit an unambiguous label convention
  for this value — "Unpaid break" is now the one term this app uses, everywhere it's shown.
