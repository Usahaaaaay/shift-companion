// notes_section.dart
//
// Read-only display of a shift's notes, shown at the bottom of
// calendar_bottom_sheet.dart. No editing — this phase is presentation
// only (see calendar_bottom_sheet.dart's own header comment).

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Displays [notes] under a "Notes" label, or a quiet "No notes"
/// placeholder when [notes] is `null` or blank — never crashes on a
/// missing value.
class NotesSection extends StatelessWidget {
  /// Creates the notes section.
  const NotesSection({super.key, required this.notes});

  /// The shift's note text, if any.
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasNotes = notes != null && notes!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hasNotes ? notes! : 'No notes',
          style: textTheme.bodyMedium?.copyWith(
            color: hasNotes
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
