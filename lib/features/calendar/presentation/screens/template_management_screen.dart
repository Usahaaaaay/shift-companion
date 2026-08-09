// template_management_screen.dart
//
// The Template Management screen (Phase 3.6) — lets a user create, view,
// edit, and delete their Shift Templates. Reached via an AppBar action on
// CalendarScreen (see that file's own note), not a bottom-nav tab — see
// decisions/0006-template-management-ui.md for why.
//
// Mirrors CalendarScreen's own shape closely: holds a [ShiftRepository]
// (injected, not constructed), loads its list once via a held Future,
// reassigns that Future to refresh after every create/edit/delete, and
// opens a bottom sheet (TemplateFormBottomSheet) for create/edit — the
// exact same pattern CalendarScreen/CalendarBottomSheet/
// ShiftFormBottomSheet already established for shifts, applied to
// templates instead of duplicating a new one.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_template.dart';
import '../../domain/repositories/shift_repository.dart';
import '../widgets/delete_template_dialog.dart';
import '../widgets/template_form_bottom_sheet.dart';
import '../widgets/template_list_tile.dart';

/// The Template Management screen — a list of the user's Shift Templates,
/// with actions to add, edit, and delete them.
class TemplateManagementScreen extends StatefulWidget {
  /// Creates the Template Management screen.
  ///
  /// [repository] is a required dependency, not constructed here — see
  /// routing/app_router.dart for where it's actually instantiated, the
  /// same shared instance CalendarScreen already receives.
  const TemplateManagementScreen({super.key, required this.repository});

  /// Where this screen's templates are read from and written to.
  final ShiftRepository repository;

  @override
  State<TemplateManagementScreen> createState() =>
      _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  late Future<List<ShiftTemplate>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = widget.repository.getTemplates();
  }

  void _refresh() {
    if (mounted) {
      // A block body, not `=> _templatesFuture = ...`: an arrow body would
      // make this closure *return* the assignment's value — the Future
      // itself — which `setState` explicitly rejects ("setState() callback
      // argument returned a Future"). CalendarBottomSheet's own `_refresh`
      // uses the same block-body shape for the same reason.
      setState(() {
        _templatesFuture = widget.repository.getTemplates();
      });
    }
  }

  Future<void> _openForm({ShiftTemplate? initialTemplate}) {
    return showTemplateFormBottomSheet(
      context,
      initialTemplate: initialTemplate,
      onSave: (template) async {
        // Editing (an id already exists) updates that row; creating (no
        // id yet) inserts a new one — never the other way around, so
        // editing can never accidentally create a duplicate record.
        if (template.id == null) {
          await widget.repository.saveTemplate(template);
        } else {
          await widget.repository.updateTemplate(template);
        }
        _refresh();
      },
      onDelete: (id) async {
        await widget.repository.deleteTemplate(id);
        _refresh();
      },
    );
  }

  Future<void> _handleDelete(ShiftTemplate template) async {
    final confirmed = await showDeleteTemplateDialog(
      context,
      templateName: template.name,
    );
    if (confirmed != true) return;
    await widget.repository.deleteTemplate(template.id!);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Templates'),
        actions: [
          IconButton(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            tooltip: 'Add template',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<ShiftTemplate>>(
          future: _templatesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final templates = snapshot.data ?? const [];
            if (templates.isEmpty) return _emptyState(context);

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final template = templates[index];
                return TemplateListTile(
                  template: template,
                  onEdit: () => _openForm(initialTemplate: template),
                  onDelete: () => _handleDelete(template),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Shown when the user has no templates yet — a clear explanation plus
  /// an obvious way to add one, matching CalendarBottomSheet's own
  /// "no shift scheduled" empty-state pattern.
  Widget _emptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No templates yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Save a shift\'s start, finish, and unpaid break as a '
              'template so you can reuse it later.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Template'),
            ),
          ],
        ),
      ),
    );
  }
}
