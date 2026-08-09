// template_form_bottom_sheet_test.dart
//
// Verifies Phase 3.6's create/edit template form: validation (blank name,
// break exceeding duration), that a valid new template saves with the
// expected values, and that editing an existing template calls the update
// path — never the create path, which would risk a duplicate record (see
// decisions/0006-template-management-ui.md).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/features/calendar/domain/entities/shift_template.dart';
import 'package:shift_companion/features/calendar/presentation/widgets/template_form_bottom_sheet.dart';

void main() {
  Finder nameField() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.keyboardType != TextInputType.number,
  );

  Finder breakField() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.keyboardType == TextInputType.number,
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    ShiftTemplate? initialTemplate,
    required void Function(ShiftTemplate) onSave,
    void Function(int)? onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateFormBottomSheet(
            initialTemplate: initialTemplate,
            onSave: (template) async => onSave(template),
            onDelete: (id) async => onDelete?.call(id),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a valid new template saves with the typed name and default times',
    (tester) async {
      ShiftTemplate? saved;
      await pumpForm(tester, onSave: (t) => saved = t);

      await tester.enterText(nameField(), 'Morning Opening');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.id, isNull); // create, not edit
      expect(saved!.name, 'Morning Opening');
      expect(saved!.startMinutes, 9 * 60); // default 9:00 AM
      expect(saved!.endMinutes, 17 * 60); // default 5:00 PM
      expect(saved!.breakMinutes, 0); // default no break
    },
  );

  testWidgets('a blank name is rejected and does not save', (tester) async {
    var saveCalled = false;
    await pumpForm(tester, onSave: (_) => saveCalled = true);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saveCalled, isFalse);
    expect(find.text('Enter a name'), findsOneWidget);
  });

  testWidgets(
    'an unpaid break exceeding the shift duration is rejected and does not save',
    (tester) async {
      var saveCalled = false;
      await pumpForm(tester, onSave: (_) => saveCalled = true);

      await tester.enterText(nameField(), 'Too much break');
      // Default shift span is 9:00 AM-5:00 PM = 480 minutes.
      await tester.enterText(breakField(), '600');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saveCalled, isFalse);
      expect(
        find.text('Unpaid break cannot exceed shift duration'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'editing an existing template updates it, never creates a new one',
    (tester) async {
      const existing = ShiftTemplate(
        id: 7,
        name: 'Morning',
        startMinutes: 420,
        endMinutes: 930,
        breakMinutes: 30,
      );
      ShiftTemplate? saved;
      await pumpForm(
        tester,
        initialTemplate: existing,
        onSave: (t) => saved = t,
      );

      // Fields start pre-filled from the existing template.
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('7:00 AM'), findsOneWidget);
      expect(find.text('3:30 PM'), findsOneWidget);

      await tester.enterText(nameField(), 'Early Morning');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.id, 7); // same row — an update, not a new template
      expect(saved!.name, 'Early Morning');
      expect(saved!.startMinutes, 420);
      expect(saved!.endMinutes, 930);
      expect(saved!.breakMinutes, 30);
    },
  );

  testWidgets('the Delete button only appears in edit mode', (tester) async {
    await pumpForm(tester, onSave: (_) {});
    expect(find.text('Delete Template'), findsNothing);

    const existing = ShiftTemplate(
      id: 1,
      name: 'Morning',
      startMinutes: 420,
      endMinutes: 930,
      breakMinutes: 30,
    );
    await pumpForm(tester, initialTemplate: existing, onSave: (_) {});
    expect(find.text('Delete Template'), findsOneWidget);
  });
}
