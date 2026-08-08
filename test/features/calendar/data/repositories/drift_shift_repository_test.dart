// drift_shift_repository_test.dart
//
// Verifies Phase 3.4's Shift Template additions against a real in-memory
// Drift database — not a fake, so this exercises the actual migration
// path (AppDatabase.forTesting -> onCreate -> _insertDefaultTemplates)
// exactly as it runs on a real device, plus DriftShiftRepository's new
// template methods and the breakMinutes column added to `Shifts`.
//
// Existing shift CRUD is also covered here (not just templates) to confirm
// this phase's changes didn't regress it — see CLAUDE.md's "no regressions"
// rule and this phase's own validation checklist.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/database/app_database.dart';
import 'package:shift_companion/features/calendar/data/repositories/drift_shift_repository.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_details.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_template.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_type.dart';

void main() {
  late AppDatabase database;
  late DriftShiftRepository repository;

  setUp(() {
    // A fresh in-memory database per test — this is what actually drives
    // AppDatabase's onCreate migration path (the same one a real first
    // launch takes), so default-template seeding is genuinely exercised,
    // not assumed.
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftShiftRepository(database);
  });

  tearDown(() => database.close());

  group('default Shift Templates', () {
    test('are seeded exactly once on database creation', () async {
      final templates = await repository.getTemplates();

      expect(templates, hasLength(3));
      expect(templates.map((t) => t.name), containsAll(['Morning', 'Afternoon', 'Night']));

      final morning = templates.firstWhere((t) => t.name == 'Morning');
      expect(morning.startMinutes, 420);
      expect(morning.endMinutes, 930);
      expect(morning.breakMinutes, 30);

      final afternoon = templates.firstWhere((t) => t.name == 'Afternoon');
      expect(afternoon.startMinutes, 660);
      expect(afternoon.endMinutes, 1170);
      expect(afternoon.breakMinutes, 30);

      final night = templates.firstWhere((t) => t.name == 'Night');
      expect(night.startMinutes, 1320);
      expect(night.endMinutes, 360);
      expect(night.breakMinutes, 45);
    });

    test('are not duplicated by re-reading them', () async {
      await repository.getTemplates();
      final templates = await repository.getTemplates();
      expect(templates, hasLength(3));
    });
  });

  group('Shift Template CRUD', () {
    test('saveTemplate persists a new template', () async {
      await repository.saveTemplate(
        const ShiftTemplate(
          name: 'Split Shift',
          startMinutes: 540,
          endMinutes: 1080,
          breakMinutes: 60,
          notes: 'Two halves',
        ),
      );

      final templates = await repository.getTemplates();
      expect(templates, hasLength(4));
      final saved = templates.firstWhere((t) => t.name == 'Split Shift');
      expect(saved.id, isNotNull);
      expect(saved.notes, 'Two halves');
    });

    test('updateTemplate overwrites the existing row by id', () async {
      final templates = await repository.getTemplates();
      final morning = templates.firstWhere((t) => t.name == 'Morning');

      await repository.updateTemplate(
        ShiftTemplate(
          id: morning.id,
          name: 'Early Morning',
          startMinutes: 360,
          endMinutes: 900,
          breakMinutes: 30,
        ),
      );

      final updated = await repository.getTemplates();
      expect(updated, hasLength(3));
      expect(updated.any((t) => t.name == 'Early Morning'), isTrue);
      expect(updated.any((t) => t.name == 'Morning'), isFalse);
    });

    test('deleteTemplate removes only that template, never any shift', () async {
      final date = DateTime(2026, 8, 10);
      await repository.saveShift(date, ShiftDetails.placeholderFor(ShiftType.morning));

      final templates = await repository.getTemplates();
      final morning = templates.firstWhere((t) => t.name == 'Morning');
      await repository.deleteTemplate(morning.id!);

      final remaining = await repository.getTemplates();
      expect(remaining, hasLength(2));
      expect(remaining.any((t) => t.name == 'Morning'), isFalse);

      // The shift that happened to be filled in from the "Morning"
      // template is untouched — templates are presets only.
      final shift = await repository.getShift(date);
      expect(shift, isNotNull);
      expect(shift!.type, ShiftType.morning);
    });
  });

  group('breakMinutes on Shift', () {
    test('round-trips through save and read', () async {
      final date = DateTime(2026, 8, 11);
      await repository.saveShift(
        date,
        const ShiftDetails(type: ShiftType.morning, breakMinutes: 45),
      );

      final shift = await repository.getShift(date);
      expect(shift?.breakMinutes, 45);
    });

    test('stays null when not set, matching existing shift behavior', () async {
      final date = DateTime(2026, 8, 12);
      await repository.saveShift(date, ShiftDetails.placeholderFor(ShiftType.off));

      final shift = await repository.getShift(date);
      expect(shift?.breakMinutes, isNull);
    });
  });

  group('existing shift CRUD (regression check)', () {
    test('save, read, and delete a shift still work', () async {
      final date = DateTime(2026, 8, 13);
      expect(await repository.getShift(date), isNull);

      await repository.saveShift(date, ShiftDetails.placeholderFor(ShiftType.night));
      final saved = await repository.getShift(date);
      expect(saved?.type, ShiftType.night);

      await repository.deleteShift(date);
      expect(await repository.getShift(date), isNull);
    });
  });
}
