// shift_picker_bottom_sheet.dart
//
// The Calendar's shift-type picker (Phase 2.5) — opened from
// calendar_bottom_sheet.dart when the selected day has no shift yet.
// Presentation only: selecting an option hands the chosen ShiftType back
// to the caller via [onShiftSelected] and closes itself. It doesn't touch
// the in-memory shift map directly — CalendarScreen owns that (see its
// addShift method) — so this stays a plain, reusable picker with no
// knowledge of where the app's shift data actually lives.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_type.dart';
import '../shift_colors.dart';

/// Opens the shift-type picker bottom sheet. Calls [onShiftSelected]
/// exactly once, with the chosen type, if the user picks an option — never
/// if they cancel or dismiss the sheet.
Future<void> showShiftPickerBottomSheet(
  BuildContext context, {
  required ValueChanged<ShiftType> onShiftSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    // Same Material 3 drag handle and rounded-top-corner treatment as
    // CalendarBottomSheet, so the two sheets read as one consistent style.
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) =>
        ShiftPickerBottomSheet(onShiftSelected: onShiftSelected),
  );
}

/// A short list of shift types to choose from, plus Cancel.
///
/// Deliberately not `isScrollControlled` / height-constrained like
/// CalendarBottomSheet — a five-item list is short enough to size itself
/// to its content.
class ShiftPickerBottomSheet extends StatelessWidget {
  /// Creates the shift-type picker sheet.
  const ShiftPickerBottomSheet({super.key, required this.onShiftSelected});

  /// Called with the chosen type when the user taps an option.
  final ValueChanged<ShiftType> onShiftSelected;

  /// The picker's option list — the shift types a user can currently
  /// assign to a day. [ShiftType.publicHoliday] is a valid type elsewhere
  /// in the app (e.g. calendar display) but isn't offered here yet,
  /// matching this phase's explicit scope.
  static const List<_ShiftOption> _options = [
    _ShiftOption(ShiftType.morning, Icons.wb_sunny_outlined, 'Morning'),
    _ShiftOption(ShiftType.afternoon, Icons.light_mode_outlined, 'Afternoon'),
    _ShiftOption(ShiftType.night, Icons.dark_mode_outlined, 'Night'),
    _ShiftOption(ShiftType.leave, Icons.beach_access_outlined, 'Leave'),
    _ShiftOption(ShiftType.off, Icons.weekend_outlined, 'Day Off'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Shift',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final option in _options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                option.icon,
                color: ShiftColors.colorFor(option.type),
              ),
              title: Text(option.label, style: textTheme.bodyLarge),
              onTap: () {
                // Close first, then notify — matches this phase's specified
                // flow ("Bottom sheet closes" before "Calendar/details
                // update").
                Navigator.pop(context);
                onShiftSelected(option.type);
              },
            ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single option's icon + label + the [ShiftType] it creates.
class _ShiftOption {
  const _ShiftOption(this.type, this.icon, this.label);

  final ShiftType type;
  final IconData icon;
  final String label;
}
