// template_form_bottom_sheet.dart
//
// The Template Management screen's unified create/edit form (Phase 3.6) —
// a bottom sheet, not a full screen, mirroring shift_form_bottom_sheet.dart
// almost exactly: one widget for both create and edit, distinguished only
// by whether [initialTemplate] is supplied, per this phase's "reuse
// existing... components wherever possible, do not create a separate
// visual system" instruction. Start/Finish reuse ShiftTimeField and Break
// reuses ShiftBreakField unchanged — the exact same widgets the shift form
// already uses, so a template's fields look and behave identically to a
// shift's.
//
// VALIDATION: unlike ShiftDetails (where a blank Start/Finish/Break is a
// legitimate "not applicable" state for shift types like Off/Leave), every
// field on a ShiftTemplate is required and non-nullable — a template with
// no name or no time range isn't a usable preset. This form is therefore
// the first in this codebase to actually block Save on invalid input,
// rather than tolerantly parsing blanks to `null`. It stays consistent
// with the app's existing lightweight validation style (inline `errorText`
// computed from plain getters) rather than introducing a `Form`/
// `TextFormField.validator` framework this codebase has never used.
//
// DEFAULTS: a brand-new template starts from sensible non-blank
// Start/Finish/Break defaults (9:00 AM-5:00 PM, no break) with only Name
// left blank — mirroring ShiftFormBottomSheet's own "defaults, not a blank
// form" convention for creating a new shift.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/work_time_calculator.dart';
import '../../domain/entities/shift_template.dart';
import 'calculated_hours_field.dart';
import 'delete_template_dialog.dart';
import 'shift_break_field.dart';
import 'shift_time_field.dart';

/// Opens the create/edit template form.
///
/// Pass [initialTemplate] to edit an existing template — fields
/// pre-filled, title reads "Edit Template", a Delete button appears. Omit
/// it to create a new one. [onSave] and [onDelete] are each called at
/// most once, and this sheet closes itself right after either.
Future<void> showTemplateFormBottomSheet(
  BuildContext context, {
  ShiftTemplate? initialTemplate,
  required Future<void> Function(ShiftTemplate template) onSave,
  required Future<void> Function(int id) onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => TemplateFormBottomSheet(
      initialTemplate: initialTemplate,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

/// The Template Management screen's create/edit form.
class TemplateFormBottomSheet extends StatefulWidget {
  /// Creates the template form.
  const TemplateFormBottomSheet({
    super.key,
    this.initialTemplate,
    required this.onSave,
    required this.onDelete,
  });

  /// The template being edited, or `null` when creating a new one — the
  /// only thing that distinguishes "create" from "edit" anywhere in this
  /// widget.
  final ShiftTemplate? initialTemplate;

  /// Called with the finished template when the user taps Save.
  final Future<void> Function(ShiftTemplate template) onSave;

  /// Called with the template's id when the user confirms deletion (edit
  /// mode only).
  final Future<void> Function(int id) onDelete;

  /// Whether this form is editing an existing template rather than
  /// creating a new one.
  bool get isEditing => initialTemplate != null;

  @override
  State<TemplateFormBottomSheet> createState() =>
      _TemplateFormBottomSheetState();
}

class _TemplateFormBottomSheetState extends State<TemplateFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _breakController;
  int? _startMinutes;
  int? _endMinutes;

  /// Whether Save has been attempted at least once — validation errors
  /// only show after a real attempt, so a brand-new form doesn't greet the
  /// user with a wall of red before they've typed anything.
  bool _validated = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialTemplate;
    _nameController = TextEditingController(text: seed?.name ?? '');
    _breakController = TextEditingController(
      text: (seed?.breakMinutes ?? 0).toString(),
    );
    // New templates start from sensible defaults (9:00 AM-5:00 PM) rather
    // than an empty picker — see this file's header note.
    _startMinutes = seed?.startMinutes ?? 9 * 60;
    _endMinutes = seed?.endMinutes ?? 17 * 60;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  int? get _breakMinutes => int.tryParse(_breakController.text.trim());

  /// `null` when there's nothing wrong — matching WorkTimeCalculator's own
  /// "unpaid break must not exceed the shift's raw duration" rule (reused
  /// here rather than re-implemented) plus this form's own requiredness
  /// rules.
  String? get _nameError {
    if (!_validated) return null;
    return _nameController.text.trim().isEmpty ? 'Enter a name' : null;
  }

  String? get _breakError {
    if (!_validated) return null;
    final breakMinutes = _breakMinutes;
    if (breakMinutes == null) return 'Enter a whole number of minutes';
    if (breakMinutes < 0) return 'Break cannot be negative';
    final start = _startMinutes;
    final end = _endMinutes;
    if (start != null &&
        end != null &&
        WorkTimeCalculator.isBreakTooLong(
          startMinutes: start,
          endMinutes: end,
          breakMinutes: breakMinutes,
        )) {
      return 'Unpaid break cannot exceed shift duration';
    }
    return null;
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _startMinutes != null &&
      _endMinutes != null &&
      _breakMinutes != null &&
      _breakMinutes! >= 0 &&
      !WorkTimeCalculator.isBreakTooLong(
        startMinutes: _startMinutes!,
        endMinutes: _endMinutes!,
        breakMinutes: _breakMinutes!,
      );

  /// The Hours a shift built from this template's current values would
  /// calculate to — a live preview only; never stored on the template
  /// itself (see this file's header note and decisions/0006).
  double? get _previewHours {
    final start = _startMinutes;
    final end = _endMinutes;
    final breakMinutes = _breakMinutes;
    if (start == null || end == null || breakMinutes == null) return null;
    return WorkTimeCalculator.calculateWorkedHours(
      startMinutes: start,
      endMinutes: end,
      breakMinutes: breakMinutes,
    );
  }

  Future<void> _handleSave() async {
    setState(() => _validated = true);
    if (!_isValid) return;

    final template = ShiftTemplate(
      // Editing keeps the existing row's id so `saveTemplate` (which
      // always inserts) is never called in place of `updateTemplate` —
      // see ShiftRepository.updateTemplate's own doc comment on why an id
      // is required for that path.
      id: widget.initialTemplate?.id,
      name: _nameController.text.trim(),
      startMinutes: _startMinutes!,
      endMinutes: _endMinutes!,
      breakMinutes: _breakMinutes!,
      notes: widget.initialTemplate?.notes,
    );
    await widget.onSave(template);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final id = widget.initialTemplate?.id;
    if (id == null) return;
    final confirmed = await showDeleteTemplateDialog(
      context,
      templateName: widget.initialTemplate!.name,
    );
    if (confirmed != true) return;
    await widget.onDelete(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Template' : 'Add Template',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Template name',
                hintText: 'e.g. Morning Opening',
                errorText: _nameError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            ShiftTimeField(
              label: 'Start time',
              minutes: _startMinutes,
              onChanged: (value) => setState(() => _startMinutes = value),
            ),
            const SizedBox(height: AppSpacing.md),
            ShiftTimeField(
              label: 'Finish time',
              minutes: _endMinutes,
              onChanged: (value) => setState(() => _endMinutes = value),
            ),
            const SizedBox(height: AppSpacing.md),
            ShiftBreakField(
              controller: _breakController,
              errorText: _breakError,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            // A live preview only — never persisted on the template. Shows
            // "—" until every field is valid, same convention
            // CalculatedHoursField already uses in the shift form.
            CalculatedHoursField(hours: _isValid ? _previewHours : null),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _handleDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete Template'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
