// shift_type_dropdown.dart
//
// The create/edit shift form's Shift Type selector — split out of
// shift_form_bottom_sheet.dart (Phase 3.4), which had grown past
// CLAUDE.md's "keep widgets under 300 lines" guideline once that phase's
// Template selector and Break field were added. Behavior and labels are
// unchanged from what was previously inline; this is a pure extraction,
// not a redesign — mirrors shift_template_dropdown.dart's own split for
// the same reason.

import 'package:flutter/material.dart';
import '../../domain/entities/shift_type.dart';

/// A dropdown for picking a shift's [ShiftType].
class ShiftTypeDropdown extends StatelessWidget {
  /// Creates the Shift Type selector.
  const ShiftTypeDropdown({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// The currently-selected shift type.
  final ShiftType selected;

  /// Called with the type the user picked.
  final ValueChanged<ShiftType> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShiftType>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Shift type'),
      items: [
        for (final type in ShiftType.values)
          DropdownMenuItem(value: type, child: Text(_typeLabel(type))),
      ],
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }

  /// A short, human label for [type] within this dropdown — kept local
  /// rather than shared with ShiftInfoCard's differently-phrased labels
  /// ("Morning Shift" there vs. "Morning" here), same reasoning as that
  /// file's own note on why these small mappings aren't forced to share
  /// one definition.
  static String _typeLabel(ShiftType type) {
    switch (type) {
      case ShiftType.morning:
        return 'Morning';
      case ShiftType.afternoon:
        return 'Afternoon';
      case ShiftType.night:
        return 'Night';
      case ShiftType.off:
        return 'Day Off';
      case ShiftType.leave:
        return 'Leave';
      case ShiftType.publicHoliday:
        return 'Public Holiday';
    }
  }
}
