// shift_break_field.dart
//
// The shift form's Break (minutes) field (Phase 3.5) — split out of
// shift_form_bottom_sheet.dart to keep that file under CLAUDE.md's "under
// 300 lines" guideline, mirroring the same per-field extraction already
// done for Start/Finish (shift_time_field.dart) and Shift Type
// (shift_type_dropdown.dart).
//
// Presentation only: this widget doesn't know what "too long" means for a
// break — [errorText] is computed by the caller (via
// WorkTimeCalculator.isBreakTooLong) and just displayed here, same
// separation of concerns as every other extracted field in this form.

import 'package:flutter/material.dart';

/// The shift form's Break field — a plain minutes entry, with an optional
/// caller-supplied validation message (e.g. "break exceeds shift
/// duration").
class ShiftBreakField extends StatelessWidget {
  /// Creates the Break field.
  const ShiftBreakField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  /// Backs this field's text — owned by the caller so it survives
  /// template application and feeds Hours' live calculation.
  final TextEditingController controller;

  /// A validation message to show below the field, or `null` when the
  /// current value is fine.
  final String? errorText;

  /// Called on every keystroke, so the caller can recompute Hours live.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Break (minutes)',
        hintText: 'e.g. 30',
        errorText: errorText,
      ),
    );
  }
}
