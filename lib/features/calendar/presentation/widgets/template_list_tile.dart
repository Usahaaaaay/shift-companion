// template_list_tile.dart
//
// A single row in the Template Management screen's list (Phase 3.6): name,
// time range, unpaid break, and Edit/Delete actions. Styled like
// ShiftInfoCard (a plain Card, same spacing scale) rather than inventing a
// new list-item visual language.
//
// Presentation only — this widget has no idea how to actually edit or
// delete a template; [onEdit]/[onDelete] are reported upward to
// TemplateManagementScreen, which owns the repository.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../domain/entities/shift_template.dart';

/// Displays one [ShiftTemplate] with Edit/Delete actions.
class TemplateListTile extends StatelessWidget {
  /// Creates a template list row for [template].
  const TemplateListTile({
    super.key,
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  /// The template this row describes.
  final ShiftTemplate template;

  /// Called when the user taps Edit.
  final VoidCallback onEdit;

  /// Called when the user taps Delete.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${AppDateFormat.timeOfDayFromMinutes(template.startMinutes)}'
                    ' → '
                    '${AppDateFormat.timeOfDayFromMinutes(template.endMinutes)}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Unpaid break: ${template.breakMinutes} min',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit template',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Delete template',
            ),
          ],
        ),
      ),
    );
  }
}
