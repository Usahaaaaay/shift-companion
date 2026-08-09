// shift_form_bottom_sheet_test.dart
//
// Regression coverage for Phase 3.5's UI behaviour: applying a Shift
// Template still fills Start/Finish/Break correctly (Phase 3.4 must keep
// working), and Hours recalculates live as Break changes, with no Save/
// reload required — the two behaviours this phase's spec calls out most
// explicitly (sections 8 and 9/16 of the brief). WorkTimeCalculator's own
// arithmetic is covered exhaustively in work_time_calculator_test.dart;
// this file verifies the widget actually wires it up correctly.
//
// PHASE 3.6: added coverage confirming the break field's visible label
// reads "Unpaid break (minutes)" (not plain "Break") — see
// decisions/0005-unpaid-break-terminology.md — and a real-world worked
// example (07:00-16:30, 40 min unpaid break) applied via a template.
//
// PHASE 3.6 (bug fix): Hours assertions updated from decimal ("8.0 h") to
// WorkTimeCalculator.formatDuration's "Xh Ym" form ("8h") — the display
// format changed, not the underlying calculation. See
// core/utils/work_time_calculator.dart's own Phase 3.6 bug-fix note.

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
      // 930 - 420 = 510 minutes raw, minus 30 break = 480 minutes = 8h.
      expect(find.text('8h'), findsOneWidget);
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
    expect(find.text('8h'), findsOneWidget);

    // Changing Break to 60 should immediately drop Hours to 7h 30m — 510
    // raw minutes minus 60 = 450 minutes. The Break field is the only
    // numeric-keyboard TextField in this form, so it's uniquely findable
    // that way without depending on internal widget structure.
    final breakField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.keyboardType == TextInputType.number,
    );
    await tester.enterText(breakField, '60');
    await tester.pump();

    expect(find.text('7h 30m'), findsOneWidget);
    expect(find.text('8h'), findsNothing);
  });

  testWidgets('the break field is labeled "Unpaid break", not "Break"', (
    tester,
  ) async {
    await pumpForm(tester, templates: const []);

    expect(find.text('Unpaid break (minutes)'), findsOneWidget);
    expect(find.text('Break (minutes)'), findsNothing);
    expect(find.text('Break'), findsNothing);
  });

  testWidgets('a real-world opening shift (07:00-16:30, 40 min unpaid break) '
      'calculates correctly via a template', (tester) async {
    const openingTemplate = ShiftTemplate(
      id: 2,
      name: 'Morning Opening',
      startMinutes: 420, // 7:00 AM
      endMinutes: 990, // 4:30 PM
      breakMinutes: 40,
    );
    await pumpForm(tester, templates: [openingTemplate]);

    await tester.tap(find.byType(DropdownButtonFormField<ShiftTemplate>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning Opening').last);
    await tester.pumpAndSettle();

    expect(find.text('7:00 AM'), findsOneWidget);
    expect(find.text('4:30 PM'), findsOneWidget);
    // 990 - 420 = 570 minutes raw, minus 40 break = 530 minutes = 8h 50m —
    // this is the exact bug this fix addresses: it used to display as the
    // confusing decimal "8.83 h".
    expect(find.text('8h 50m'), findsOneWidget);
  });
}
