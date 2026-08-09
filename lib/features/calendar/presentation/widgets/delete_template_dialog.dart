// delete_template_dialog.dart
//
// The Template Management screen's delete-confirmation dialog (Phase 3.6)
// — mirrors delete_shift_dialog.dart's exact structure and styling (same
// AlertDialog shape, same Cancel/destructive-FilledButton pair), per this
// phase's "provide the app's existing confirmation-dialog pattern"
// instruction. Kept as its own small function rather than generalizing
// delete_shift_dialog.dart into a shared parameterized dialog: the two
// call sites want different, specific copy (this one's whole reason to
// exist is clarifying that shifts are unaffected), and duplicating this
// small a widget costs less than the indirection of a shared abstraction
// would for exactly two call sites — see CLAUDE.md's "don't force
// composition where it adds ceremony without benefit".
//
// A real Material Dialog, not a bottom sheet — same reasoning as
// delete_shift_dialog.dart: docs/Design_System.md Section 8.10 reserves
// Dialog specifically for destructive, hard-to-reverse confirmations.

import 'package:flutter/material.dart';

/// Shows a confirmation dialog for deleting [templateName]. Resolves to
/// `true` if the user confirmed, `false`/`null` if they backed out.
///
/// The copy explicitly states that existing shifts are unaffected — a
/// template is a reusable input preset a shift was filled in *from*, not a
/// parent record shifts depend on (see decisions/0003 and
/// decisions/0006-template-management-ui.md), so deleting one must never
/// read as "this might delete my shifts too".
Future<bool?> showDeleteTemplateDialog(
  BuildContext context, {
  required String templateName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: Text('Delete "$templateName"?'),
        content: const Text(
          "This can't be undone. Shifts you already created using this "
          "template will not be changed or deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
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
