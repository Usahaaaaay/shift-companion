// shift_form_bottom_sheet_test.dart
//
// Regression coverage for Phase 3.5's UI behaviour: applying a Shift
// Template still fills Start/Finish/Break correctly (Phase 3.4 must keep
// working), and Hours recalculates live as Break changes, with no Save/
// reload required — the two behaviours this phase's spec calls out most
// explicitly (sections 8 and 9/16 of the brief). WorkTimeCalculator's own
// arithmetic is covered exhaustively in work_time_calculator_test.dart;
// this file verifies the widget actually wires it up correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_template.dart';
import 'package:shift_companion/features/calendar/presentation/widgets/shift_form_bottom_sheet.dart';

void main() {
  const morningTemplate = ShiftTemplate(
    id: 1,
    name: 'Morning',
    startMinutes: 420, // 7:00 AM
    endMinutes: 930, // 3:30 PM
    breakMinutes: 30,
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    required List<ShiftTemplate> templates,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShiftFormBottomSheet(
            date: DateTime(2026, 8, 10),
            onSave: (date, shift) async {},
            onDelete: (date) async {},
            getTemplates: () async => templates,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'applying a template fills Start/Finish/Break and calculates Hours',
    (tester) async {
      await pumpForm(tester, templates: [morningTemplate]);

      // Open the Template dropdown and select "Morning".
      await tester.tap(find.byType(DropdownButtonFormField<ShiftTemplate>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Morning').last);
      await tester.pumpAndSettle();

      // Start/Finish, converted from the template's minutes.
      expect(find.text('7:00 AM'), findsOneWidget);
      expect(find.text('3:30 PM'), findsOneWidget);
      // 930 - 420 = 510 minutes raw, minus 30 break = 480 minutes = 8.0h.
      expect(find.text('8.0 h'), findsOneWidget);
    },
  );

  testWidgets('Hours recalculates live when Break changes, no save needed', (
    tester,
  ) async {
    await pumpForm(tester, templates: [morningTemplate]);

    await tester.tap(find.byType(DropdownButtonFormField<ShiftTemplate>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning').last);
    await tester.pumpAndSettle();
    expect(find.text('8.0 h'), findsOneWidget);

    // Changing Break to 60 should immediately drop Hours to 7.5 — 510
    // raw minutes minus 60 = 450 minutes. The Break field is the only
    // numeric-keyboard TextField in this form, so it's uniquely findable
    // that way without depending on internal widget structure.
    final breakField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.keyboardType == TextInputType.number,
    );
    await tester.enterText(breakField, '60');
    await tester.pump();

    expect(find.text('7.5 h'), findsOneWidget);
    expect(find.text('8.0 h'), findsNothing);
  });
}
