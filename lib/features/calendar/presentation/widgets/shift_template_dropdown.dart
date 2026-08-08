// shift_template_dropdown.dart
//
// The create/edit shift form's Template selector (Phase 3.4) — split out
// of shift_form_bottom_sheet.dart into its own small, focused widget per
// CLAUDE.md's "keep widgets under 300 lines... split into smaller widgets"
// rule, and reusable if a future screen ever needs the same selector.
//
// Presentation only: this widget renders whatever templates it's given and
// reports which one was picked. It has no idea what "applying" a template
// means to the form (filling Start/Finish/Break/Notes) — that's
// shift_form_bottom_sheet.dart's job, keeping business logic out of this
// widget per ARCHITECTURE.md's presentation-layer rule.

import 'package:flutter/material.dart';
import '../../domain/entities/shift_template.dart';

/// A dropdown for picking one of the user's Shift Templates.
///
/// Selecting a template only reports it via [onSelected] — it never saves
/// or mutates anything itself; the caller decides what to do with the
/// chosen [ShiftTemplate] (see ShiftFormBottomSheet, which copies its
/// values into the form's other fields).
class ShiftTemplateDropdown extends StatelessWidget {
  /// Creates the Template selector.
  const ShiftTemplateDropdown({
    super.key,
    required this.templates,
    required this.selected,
    required this.onSelected,
  });

  /// The templates available to choose from.
  final List<ShiftTemplate> templates;

  /// The currently-selected template, or `null` if none has been picked
  /// yet this session — shown as a hint rather than a real value, since
  /// picking a template is a one-shot fill action, not a persisted choice.
  final ShiftTemplate? selected;

  /// Called with the template the user picked.
  final ValueChanged<ShiftTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShiftTemplate>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Template',
        hintText: 'Choose a template to pre-fill this form',
      ),
      items: [
        for (final template in templates)
          DropdownMenuItem(value: template, child: Text(template.name)),
      ],
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}
