// app_database.dart
//
// The app's single Drift database (Phase 3.1 — infrastructure only;
// nothing in the app constructs or reads from this yet). Opens SQLite,
// registers every table, and exposes Drift's generated query API — that's
// its entire job. No repository logic and no business logic belongs here,
// matching this phase's explicit constraint.
//
// Lives in lib/database/ — a top-level folder, sibling to core/ and
// features/ — rather than inside core/ or a feature. This mirrors
// lib/routing/app_router.dart's own position: both are app-level
// composition roots that import from multiple features to wire something
// app-wide together (the router wires screens into routes; this wires
// table definitions into one database). ARCHITECTURE.md's core/ is for
// things every feature depends ON, never the reverse — since a shared
// AppDatabase necessarily imports table definitions that live inside
// their owning features (e.g. features/calendar/data/datasources/
// shift_table.dart), putting it inside core/ would invert that dependency
// direction. As more features gain their own tables, this file registers
// them the same way app_router.dart registers each feature's routes.
//
// PHASE 3.2A: `DriftShiftRepository` (see
// features/calendar/data/repositories/drift_shift_repository.dart) now
// reads/writes through an `AppDatabase` instance — but nothing in the
// running app constructs one yet; `MemoryShiftRepository` is still what
// routing/app_router.dart wires up. That wiring swap is a later phase's
// job, not this one's.
//
// schemaVersion bumped to 2 for that repository's sake: shift_table.dart
// gained an `hours` column and a uniqueness constraint on `date` (needed
// for a correct upsert-by-date — see that file's own note). Since no real
// on-device database has ever been created from schema 1 (nothing has
// constructed AppDatabase outside of tests), the migration below is
// simple by necessity, not by cutting a corner — there's no real user data
// it could risk.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../features/calendar/data/datasources/shift_table.dart';
// Needed directly (not just transitively via shift_table.dart) because
// this file's generated `part`, app_database.g.dart, shares this file's
// own library scope — a plain `import` doesn't forward the types a
// dependency imported, only what it declares itself.
import '../features/calendar/domain/entities/shift_type.dart';

part 'app_database.g.dart';

/// The app's Drift database. Registers every persisted table across every
/// feature — currently just [Shifts].
@DriftDatabase(tables: [Shifts])
class AppDatabase extends _$AppDatabase {
  /// Opens (or creates) the app's on-disk SQLite database.
  AppDatabase() : super(_openConnection());

  /// Opens an [AppDatabase] against a caller-supplied executor instead of
  /// the default on-disk connection — for tests that want an isolated or
  /// in-memory database rather than touching the real one.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // SQLite can't ALTER TABLE to add a uniqueness constraint
        // directly, so `TableMigration` recreates `shifts` to match its
        // current Dart definition (both the new `hours` column and the
        // new `date` uniqueness constraint) and copies existing rows
        // across by matching column name — the standard Drift pattern for
        // this kind of change.
        await m.alterTable(TableMigration(shifts));
      }
    },
  );

  static QueryExecutor _openConnection() {
    // drift_flutter's helper picks the right storage location per
    // platform (app documents directory on mobile/desktop, IndexedDB/OPFS
    // on web) — the "current recommended Flutter ecosystem" approach,
    // replacing the older pattern of manually wiring path_provider to a
    // NativeDatabase.
    return driftDatabase(name: 'shift_companion');
  }
}
