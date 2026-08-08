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
//
// PHASE 3.4: schemaVersion bumped to 3 for Shift Templates. Two additive
// changes, both simple `ALTER`-shaped migrations (no `TableMigration`
// recreate needed, unlike the v1->v2 change above, since neither adds a
// constraint): `shifts` gains a nullable `breakMinutes` column, and the
// new `shiftTemplates` table is created. The three default templates
// (Morning/Afternoon/Night) are inserted right after, in both `onCreate`
// (fresh installs) and this `onUpgrade` branch (installs upgrading from an
// earlier schema) — see `_insertDefaultTemplates` below for why that's the
// correct place for this one-time seed rather than anywhere in the
// repository layer.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../features/calendar/data/datasources/shift_table.dart';
import '../features/calendar/data/datasources/shift_template_table.dart';
// Needed directly (not just transitively via shift_table.dart) because
// this file's generated `part`, app_database.g.dart, shares this file's
// own library scope — a plain `import` doesn't forward the types a
// dependency imported, only what it declares itself.
import '../features/calendar/domain/entities/shift_type.dart';

part 'app_database.g.dart';

/// The app's Drift database. Registers every persisted table across every
/// feature — currently [Shifts] and [ShiftTemplates].
@DriftDatabase(tables: [Shifts, ShiftTemplates])
class AppDatabase extends _$AppDatabase {
  /// Opens (or creates) the app's on-disk SQLite database.
  AppDatabase() : super(_openConnection());

  /// Opens an [AppDatabase] against a caller-supplied executor instead of
  /// the default on-disk connection — for tests that want an isolated or
  /// in-memory database rather than touching the real one.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _insertDefaultTemplates();
    },
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
      if (from < 3) {
        // Both changes here are plain additions — a nullable column and a
        // brand-new table — so a straightforward `addColumn`/`createTable`
        // is enough; no existing row shape changes, so no risk to already
        // -saved shifts.
        await m.addColumn(shifts, shifts.breakMinutes);
        await m.createTable(shiftTemplates);
        await _insertDefaultTemplates();
      }
    },
  );

  /// Seeds the three default Shift Templates (Morning/Afternoon/Night) —
  /// called exactly once per database, from [migration]'s `onCreate` for a
  /// brand-new database and from its `onUpgrade` `from < 3` branch for a
  /// database created before Shift Templates existed. Both call sites run
  /// at most once in a given database's lifetime (a fresh database is only
  /// ever created once; upgrading past schema 3 only ever happens once),
  /// so "insert only once, never duplicate" falls out of Drift's own
  /// migration lifecycle rather than needing an application-level
  /// "have I done this before?" check — the correct place for a one-time
  /// persistence-layer concern like this, matching CLAUDE.md's "Drift owns
  /// persistence only" boundary: the repository layer never needs to know
  /// this seeding happened at all.
  Future<void> _insertDefaultTemplates() {
    return batch((batch) {
      batch.insertAll(shiftTemplates, [
        ShiftTemplatesCompanion.insert(
          name: 'Morning',
          startMinutes: 420,
          endMinutes: 930,
          breakMinutes: 30,
        ),
        ShiftTemplatesCompanion.insert(
          name: 'Afternoon',
          startMinutes: 660,
          endMinutes: 1170,
          breakMinutes: 30,
        ),
        ShiftTemplatesCompanion.insert(
          name: 'Night',
          startMinutes: 1320,
          endMinutes: 360,
          breakMinutes: 45,
        ),
      ]);
    });
  }

  static QueryExecutor _openConnection() {
    // drift_flutter's helper picks the right storage location per
    // platform (app documents directory on mobile/desktop, IndexedDB/OPFS
    // on web) — the "current recommended Flutter ecosystem" approach,
    // replacing the older pattern of manually wiring path_provider to a
    // NativeDatabase.
    return driftDatabase(name: 'shift_companion');
  }
}
