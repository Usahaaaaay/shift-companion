# 0002: Local persistence — Drift (SQLite)

**Status:** Accepted (2026-08-08)

## Context

Shift Companion's shift data has lived only in memory since Phase 2.5
(`MemoryShiftRepository`, behind the `ShiftRepository` interface introduced in Phase 2.6)
— every restart discards it, which was correct for prototyping the UI but isn't viable
for a real app whose entire value proposition is remembering a user's schedule. A real,
on-device persistence layer was always the plan (see ARCHITECTURE.md's "not yet decided"
list), deferred until a feature actually forced the decision, per CLAUDE.md's "decide
when forced" rule. Phase 3.1 is that point.

The choice needed to:
- Slot behind the existing `ShiftRepository` interface without that interface (or the
  UI above it) needing to change shape.
- Support a real relational schema, since shift data has clear structure (date, time
  range, type) and will grow more relational fields over time (leave, earnings, multiple
  jobs — see docs/Feature_List.md).
- Support schema migrations, since the schema is explicitly expected to grow (notes,
  overtime, leave type, timestamps are already anticipated — see
  `features/calendar/data/datasources/shift_table.dart`).
- Work fully offline, per docs/Software_Requirements.md's offline requirements (OFF-1
  through OFF-5) — ruling out anything cloud-first by default.

## Decision

Use **Drift** (built on `sqlite3`/SQLite) for local persistence, via `drift_flutter` for
platform-appropriate database setup.

## Alternatives considered

- **Hive** — Simple key-value/object storage, fast for small apps, but no real query
  language or relational structure — a poor fit once shift data needs filtering by date
  range, joining against leave/earnings data, or aggregating for Reports (all named
  future features). Would likely need replacing later anyway.
- **Isar** — Fast, modern NoSQL-ish store with decent query support, but a smaller
  ecosystem and — at time of writing — a less certain long-term maintenance trajectory
  than Drift, which is built directly on SQLite (a format with decades of stability and
  tooling behind it).
- **sqflite (raw)** — Direct SQLite access without a generated, type-safe query layer;
  every query would be hand-written SQL strings with manual row mapping, which is
  exactly the kind of error-prone boilerplate Drift's code generation exists to remove.
- **shared_preferences** — Fine for flags/settings, structurally wrong for a growing set
  of relational shift records.
- **Firebase / Supabase / any cloud-first store** — Explicitly out of scope: this phase
  (and this project's current stage generally) is local-only, cloud sync is an
  explicitly deferred future feature (Feature_List.md's "Cloud Backup", "Multi-device
  Sync"), and a cloud-first store would violate the offline-first requirement outright.

## Consequences

- Adds `drift`, `drift_flutter`, and `sqlite3_flutter_libs` as runtime dependencies, and
  `drift_dev` + `build_runner` as dev dependencies (code generation).
- Every table definition lives inside its owning feature's `data/datasources/` (per
  ARCHITECTURE.md, which already named Drift as the intended occupant of that folder);
  the aggregating `AppDatabase` class lives in a new top-level `database/` folder,
  alongside `core/` and `routing/`, since it necessarily imports across features the
  same way `routing/app_router.dart` already does — see ARCHITECTURE.md's Folder
  Structure section for the full reasoning.
- `AppDatabase.schemaVersion` starts at 1. Every future schema change (adding a column,
  a table, etc.) is a real migration: bump the version and add a `MigrationStrategy`
  step — not an ad hoc data-loss-risking change.
- As of Phase 3.1, this is infrastructure only — `AppDatabase` and `Shifts` exist and
  are verified to open and query correctly, but no `ShiftRepository` implementation
  reads from or writes to them yet. `MemoryShiftRepository` remains the active
  implementation. A near-future phase adds `DriftShiftRepository implements
  ShiftRepository` and swaps which one `routing/app_router.dart` constructs — the one
  place that needs to change; the UI and the `ShiftRepository` interface don't.
- `ShiftRepository`'s methods are currently synchronous, matching `MemoryShiftRepository`.
  A Drift-backed implementation is naturally asynchronous (real disk I/O), so adopting
  it will require widening the interface to return `Future`s — which will, in turn,
  require the UI call sites (`CalendarBottomSheet` in particular) to move from a direct
  synchronous read to something like a `FutureBuilder` or a preloaded value. This is a
  known, deliberately deferred piece of follow-up work, not an oversight — see Phase
  3.1's own deliverables for the full reasoning on why it wasn't solved preemptively.
