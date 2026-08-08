// delete_shift_dialog.dart
//
// The shift form's delete-confirmation dialog (Phase 3.4) — split out of
// shift_form_bottom_sheet.dart, which had grown past CLAUDE.md's "keep
// widgets under 300 lines" guideline once this phase's Template selector
// and Break field were added. Behavior is unchanged from what
// ShiftFormBottomSheet._handleDelete previously built inline; this is a
// pure extraction, not a redesign.
//
// A real Material Dialog, not a bottom sheet — per docs/Design_System.md
// Section 8.10, reserved specifically for "genuinely destructive,
// hard-to-reverse confirmations", exactly what deleting a shift is.

import 'package:flutter/material.dart';

/// Shows a confirmation dialog for deleting a shift. Resolves to `true` if
/// the user confirmed, `false`/`null` if they backed out.
Future<bool?> showDeleteShiftDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: const Text('Delete this shift?'),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          // Styled distinctly from routine actions per
          // docs/UI_UX_Principles.md Section 9 ("destructive actions look
          // different").
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
