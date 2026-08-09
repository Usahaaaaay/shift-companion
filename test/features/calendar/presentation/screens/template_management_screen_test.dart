// template_management_screen_test.dart
//
// Verifies Phase 3.6's Template Management screen against a real
// ShiftRepository implementation (MemoryShiftRepository, reused as a
// lightweight fake rather than hand-building a mock — it already
// implements the full interface, including the same default-template
// seeding DriftShiftRepository does): the empty state, the populated
// list, and that deleting a template shows the "shifts are unaffected"
// confirmation and only removes the template, never any shift.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/features/calendar/data/repositories/memory_shift_repository.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_details.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_type.dart';
import 'package:shift_companion/features/calendar/presentation/screens/template_management_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    MemoryShiftRepository repository,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TemplateManagementScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the populated list with name, time range, and break', (
    tester,
  ) async {
    final repository = MemoryShiftRepository();
    await pumpScreen(tester, repository);

    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('7:00 AM → 3:30 PM'), findsOneWidget);
    // Both default "Morning" and "Afternoon" templates have a 30-minute
    // break, so this text legitimately appears twice — see Night's own
    // distinct 45-minute break below for an unambiguous single match.
    expect(find.text('Unpaid break: 30 min'), findsNWidgets(2));
    expect(find.text('Unpaid break: 45 min'), findsOneWidget);
  });

  testWidgets(
    'shows an empty state with an Add Template action when there are none',
    (tester) async {
      final repository = MemoryShiftRepository();
      // Clear the seeded defaults to exercise the empty state specifically.
      for (final template in await repository.getTemplates()) {
        await repository.deleteTemplate(template.id!);
      }

      await pumpScreen(tester, repository);

      expect(find.text('No templates yet'), findsOneWidget);
      expect(find.text('Add Template'), findsOneWidget);
    },
  );

  testWidgets(
    'deleting a template asks for confirmation, clarifies shifts are unaffected, '
    'and never touches an existing shift',
    (tester) async {
      final repository = MemoryShiftRepository();
      final date = DateTime(2026, 8, 10);
      await repository.saveShift(
        date,
        ShiftDetails.placeholderFor(ShiftType.morning),
      );

      await pumpScreen(tester, repository);

      await tester.tap(find.byTooltip('Delete template').first);
      await tester.pumpAndSettle();

      expect(find.textContaining("Shifts you already created"), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      final remaining = await repository.getTemplates();
      expect(remaining.any((t) => t.name == 'Morning'), isFalse);

      // The shift is completely untouched.
      final shift = await repository.getShift(date);
      expect(shift, isNotNull);
      expect(shift!.type, ShiftType.morning);
    },
  );

  testWidgets('canceling the delete confirmation keeps the template', (
    tester,
  ) async {
    final repository = MemoryShiftRepository();
    await pumpScreen(tester, repository);

    await tester.tap(find.byTooltip('Delete template').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final remaining = await repository.getTemplates();
    expect(remaining.any((t) => t.name == 'Morning'), isTrue);
  });
}
