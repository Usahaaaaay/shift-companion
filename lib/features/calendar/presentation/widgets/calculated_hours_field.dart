// calculated_hours_field.dart
//
// The shift form's read-only Hours display (Phase 3.5) — split out of
// shift_form_bottom_sheet.dart, both to keep that file under CLAUDE.md's
// "under 300 lines" guideline and because "Hours, calculated and
// formatted the same way" is exactly the kind of small display future
// phases (weekly summaries, payroll, statistics) are likely to want too —
// see WorkTimeCalculator's own header comment on why it's a shared
// utility rather than something private to this form.
//
// An InputDecorator, not a TextField: this value is never editable, and a
// disabled-looking TextField would suggest otherwise. See
// decisions/0004-automatic-hours-calculation.md for the full reasoning
// behind removing manual Hours entry.

import 'package:flutter/material.dart';
import '../../../../core/utils/work_time_calculator.dart';

/// Displays [hours] (already computed by WorkTimeCalculator) the same way
/// everywhere it's shown — "7.5 h", or an em dash while there's nothing to
/// calculate yet (Start or Finish not picked).
class CalculatedHoursField extends StatelessWidget {
  /// Creates the read-only Hours display.
  const CalculatedHoursField({super.key, required this.hours});

  /// The worked hours to display, or `null` if Start/Finish aren't both
  /// set yet — this widget doesn't calculate anything itself, it only
  /// formats and displays what its caller already computed.
  final double? hours;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Hours'),
      child: Text(
        hours == null ? '—' : '${WorkTimeCalculator.formatHours(hours!)} h',
      ),
    );
  }
}
