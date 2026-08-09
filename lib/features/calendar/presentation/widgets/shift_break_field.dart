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
//
// digitsOnly input formatter added alongside this phase's negative-break
// guard in WorkTimeCalculator: this makes a negative value structurally
// impossible to type via this field in the first place (defense in depth),
// while the calculator's own clamp is what actually keeps the calculation
// safe regardless of how a value reaches it.
//
// PHASE 3.6: the visible label changed from "Break" to "Unpaid break" —
// `breakMinutes` has always meant unpaid time only (see
// ShiftDetails.breakMinutes' own doc comment), but the old plain "Break"
// label didn't say so, risking a user entering a *paid* rest break here by
// mistake and having it wrongly deducted from worked hours. This widget's
// name, its `controller`/`errorText` API, and the underlying `breakMinutes`
// field/column are all unchanged — only the displayed text changed. See
// decisions/0005-unpaid-break-terminology.md.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The shift form's Unpaid break field — a plain minutes entry, with an
/// optional caller-supplied validation message (e.g. "break exceeds shift
/// duration"). Kept named `ShiftBreakField` (matching the underlying
/// `breakMinutes` it edits) even though its visible label reads "Unpaid
/// break" — see this file's own Phase 3.6 header note.
class ShiftBreakField extends StatelessWidget {
  /// Creates the Unpaid break field.
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Unpaid break (minutes)',
        hintText: 'e.g. 30',
        errorText: errorText,
      ),
    );
  }
}
