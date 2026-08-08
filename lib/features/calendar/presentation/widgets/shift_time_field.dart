// shift_time_field.dart
//
// A tappable, picker-backed replacement for the shift form's old free-text
// Start/Finish fields (Phase 3.5). Shows [minutes] formatted via
// AppDateFormat.timeOfDayFromMinutes, or a placeholder hint, and opens
// Flutter's built-in `showTimePicker` on tap — reused as-is rather than a
// hand-rolled picker, since it's already part of the Material framework
// this app is built on (no new dependency).
//
// Structured (minutes since midnight), not free text, so the shift form
// can feed [minutes] straight into WorkTimeCalculator for live Hours
// calculation without parsing a string on every keystroke — see
// decisions/0004-automatic-hours-calculation.md for why the old free-text
// fields had to change for this phase.
//
// Presentation only: this widget has no idea Hours exists, or that
// picking a time triggers a recalculation anywhere — it just reports the
// minutes the user picked via [onChanged], same separation of concerns as
// shift_type_dropdown.dart and shift_template_dropdown.dart.

import 'package:flutter/material.dart';
import '../../../../core/utils/app_date_format.dart';

/// A labeled, tappable field that opens a time picker and displays the
/// chosen time, formatted the same way every other time in this app is.
class ShiftTimeField extends StatelessWidget {
  /// Creates the time field.
  const ShiftTimeField({
    super.key,
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  /// The field's label, e.g. "Start time".
  final String label;

  /// The currently-selected time, in minutes since midnight, or `null` if
  /// nothing has been picked yet.
  final int? minutes;

  /// Called with the minutes-since-midnight value of whatever time the
  /// user picks.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => _pickTime(context),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          minutes == null
              ? 'Tap to select'
              : AppDateFormat.timeOfDayFromMinutes(minutes!),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    // Seed the picker with whatever's already selected, so reopening it
    // starts from the current value rather than always resetting to "now".
    final initialTime = minutes == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: minutes! ~/ 60, minute: minutes! % 60);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) onChanged(picked.hour * 60 + picked.minute);
  }
}
