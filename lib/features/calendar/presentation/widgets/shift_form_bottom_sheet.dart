// shift_form_bottom_sheet.dart
//
// The Calendar's unified create/edit shift form (Phase 3.3) — the single
// widget used both to create a new shift and to edit an existing one, per
// this phase's "do not create a separate EditShiftDialog" rule. Whether
// it's creating or editing is purely a presentation decision — the title,
// whether fields start blank/default or pre-filled, and whether the
// Delete button shows — never a persistence decision: both paths call the
// same [onSave], which reaches CalendarScreen's `ShiftRepository.saveShift`
// (already an upsert; see that method's own doc comment), so there is no
// separate create-vs-update code path to keep in sync.
//
// Replaces shift_picker_bottom_sheet.dart, which only let a user pick a
// type with no other field — it couldn't be "pre-populated" for editing,
// which this phase requires, so it's superseded rather than kept alongside
// this widget (avoiding exactly the "duplicate dialog" this phase forbids).
//
// A bottom sheet, not a Material Dialog — matching every other Calendar
// interaction sheet, rather than the brief's generic "Dialog" wording. Per
// docs/Design_System.md Section 8.10, a real Dialog is reserved
// specifically for "genuinely destructive, hard-to-reverse confirmations"
// — exactly the delete-confirmation step below, the one place in this
// widget a Dialog actually belongs.
//
// PHASE 3.4: added a Template selector (see [_applyTemplate]) and a Break
// field. Picking a template only fills this form's Start time, Finish
// time, Break, and Notes controllers — it's a one-shot convenience action,
// not a bound value; nothing is saved until the user still taps Save, same
// as every other field here. [getTemplates] is a callback (matching the
// shape [onSave]/[onDelete] already have) rather than a pre-fetched list,
// so this widget — not its caller — owns exactly when its own data loads,
// consistent with how CalendarBottomSheet already loads its own
// ShiftDetails via a held Future + FutureBuilder.
//
// PHASE 3.5: Start/Finish became structured (minutes since midnight,
// picked via ShiftTimeField) instead of free text, and Hours is no longer
// typed — it's calculated live from Start/Finish/Break via
// WorkTimeCalculator and shown read-only. See
// decisions/0004-automatic-hours-calculation.md for why the old free-text
// time fields had to change to make that possible, and why this still
// required no repository or database change (ShiftDetails.startTime/
// endTime/hours keep their existing types; only how this form builds and
// seeds them changed). [_applyTemplate] got simpler as a result — a
// template's minutes now assign directly to [_startMinutes]/[_endMinutes],
// no string round-trip needed.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/work_time_calculator.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_template.dart';
import '../../domain/entities/shift_type.dart';
import 'calculated_hours_field.dart';
import 'delete_shift_dialog.dart';
import 'shift_break_field.dart';
import 'shift_template_dropdown.dart';
import 'shift_time_field.dart';
import 'shift_type_dropdown.dart';

/// Opens the create/edit shift form for [date].
///
/// Pass [initialShift] to edit an existing shift — fields pre-filled,
/// title reads "Edit Shift", a Delete button appears. Omit it to create a
/// new one — fields start from sensible defaults, title reads
/// "Add Shift", no Delete button. [onSave] and [onDelete] are each called
/// at most once, and this sheet closes itself right after either.
Future<void> showShiftFormBottomSheet(
  BuildContext context, {
  required DateTime date,
  ShiftDetails? initialShift,
  required Future<void> Function(DateTime date, ShiftDetails shift) onSave,
  required Future<void> Function(DateTime date) onDelete,
  required Future<List<ShiftTemplate>> Function() getTemplates,
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
    builder: (context) => ShiftFormBottomSheet(
      date: date,
      initialShift: initialShift,
      onSave: onSave,
      onDelete: onDelete,
      getTemplates: getTemplates,
    ),
  );
}

/// The Calendar's create/edit shift form.
class ShiftFormBottomSheet extends StatefulWidget {
  /// Creates the shift form for [date].
  const ShiftFormBottomSheet({
    super.key,
    required this.date,
    this.initialShift,
    required this.onSave,
    required this.onDelete,
    required this.getTemplates,
  });

  /// The date this shift belongs to.
  final DateTime date;

  /// The shift being edited, or `null` when creating a new one — the only
  /// thing that distinguishes "create" from "edit" anywhere in this
  /// widget.
  final ShiftDetails? initialShift;

  /// Called with the form's current values when the user taps Save.
  final Future<void> Function(DateTime date, ShiftDetails shift) onSave;

  /// Called when the user confirms deletion (edit mode only).
  final Future<void> Function(DateTime date) onDelete;

  /// Reads the user's Shift Templates for the Template selector.
  final Future<List<ShiftTemplate>> Function() getTemplates;

  /// Whether this form is editing an existing shift rather than creating
  /// a new one.
  bool get isEditing => initialShift != null;

  @override
  State<ShiftFormBottomSheet> createState() => _ShiftFormBottomSheetState();
}

class _ShiftFormBottomSheetState extends State<ShiftFormBottomSheet> {
  late ShiftType _type;

  /// The shift's start time, in minutes since midnight — `null` until the
  /// user (or a template) picks one. Structured rather than free text so
  /// [_hoursDisplay] can feed it straight into WorkTimeCalculator; see this
  /// file's own Phase 3.5 header note.
  int? _startMinutes;

  /// The shift's finish time, in minutes since midnight — see
  /// [_startMinutes] for why this isn't free text.
  int? _endMinutes;
  late final TextEditingController _breakController;
  late final TextEditingController _notesController;

  /// The template last picked from the selector this session, or `null`
  /// until the user chooses one — see ShiftTemplateDropdown's own doc
  /// comment on why this isn't a value the form itself computes.
  ShiftTemplate? _selectedTemplate;

  /// Loaded once in [initState], not re-fetched afterward — this form
  /// never mutates the template list itself, so there's nothing for a
  /// refetch to pick up. Matches the same "load once via a held Future"
  /// shape CalendarBottomSheet uses for its own async data.
  late final Future<List<ShiftTemplate>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    // Editing starts from the stored shift's actual values. Creating
    // starts from ShiftDetails' own sensible defaults (a Morning shift's
    // usual hours) rather than a blank form — the user can freely change
    // or clear anything from there; "defaults", not "required".
    final seed =
        widget.initialShift ?? ShiftDetails.placeholderFor(ShiftType.morning);
    _type = seed.type;
    // Parses the saved formatted string back into minutes — the one place
    // in this form that still parses a time string, and only to seed the
    // picker from history; see AppDateFormat.minutesFromTimeOfDay's own doc
    // comment on why a `null` result (an unparseable legacy value) is
    // handled gracefully rather than assumed impossible.
    _startMinutes = seed.startTime == null
        ? null
        : AppDateFormat.minutesFromTimeOfDay(seed.startTime!);
    _endMinutes = seed.endTime == null
        ? null
        : AppDateFormat.minutesFromTimeOfDay(seed.endTime!);
    _breakController = TextEditingController(
      text: seed.breakMinutes?.toString() ?? '',
    );
    _notesController = TextEditingController(text: seed.notes ?? '');
    _templatesFuture = widget.getTemplates();
  }

  @override
  void dispose() {
    _breakController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// This form's current break value, or `null` if the field is blank or
  /// unparseable — the same tolerant-parsing convention [_handleSave]
  /// already used before this phase.
  int? get _breakMinutes => int.tryParse(_breakController.text.trim());

  /// Whether the current break exceeds the raw Start-to-Finish span —
  /// shown as an inline error on the Break field. `false` whenever Start
  /// or Finish hasn't been picked yet, since there's nothing to compare
  /// against.
  bool get _breakTooLong {
    final start = _startMinutes;
    final end = _endMinutes;
    final breakMinutes = _breakMinutes;
    if (start == null || end == null || breakMinutes == null) return false;
    return WorkTimeCalculator.isBreakTooLong(
      startMinutes: start,
      endMinutes: end,
      breakMinutes: breakMinutes,
    );
  }

  /// The live-calculated Hours value shown in the read-only display below
  /// — recomputed on every build from whatever Start/Finish/Break
  /// currently hold, per this phase's "no Save button required to trigger
  /// recalculation" requirement. `null` until both Start and Finish are
  /// picked — there's nothing to calculate yet, and showing "0.0 h" in
  /// that case would misleadingly look like a real answer.
  double? get _calculatedHours {
    final start = _startMinutes;
    final end = _endMinutes;
    if (start == null || end == null) return null;
    return WorkTimeCalculator.calculateWorkedHours(
      startMinutes: start,
      endMinutes: end,
      breakMinutes: _breakMinutes ?? 0,
    );
  }

  /// Copies [template]'s values into this form's Start time, Finish time,
  /// Break, and Notes fields — the exact four fields this phase's brief
  /// specifies a template fills. Deliberately does not touch [_type]: it
  /// isn't part of what a template describes. Hours is no longer a field
  /// to fill at all as of Phase 3.5 — it's calculated live from whatever
  /// Start/Finish/Break end up being, template-supplied or not.
  ///
  /// This only updates local form state — nothing is persisted here. The
  /// underlying shift (if editing one) isn't touched until Save is
  /// pressed, same as every other field in this form.
  void _applyTemplate(ShiftTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _startMinutes = template.startMinutes;
      _endMinutes = template.endMinutes;
      _breakController.text = template.breakMinutes.toString();
      _notesController.text = template.notes ?? '';
    });
  }

  /// A blank field becomes `null` — matching [ShiftDetails]' own "not
  /// applicable for this shift" convention (see that entity's doc
  /// comments) rather than storing an empty string.
  static String? _blankToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _handleSave() async {
    final start = _startMinutes;
    final end = _endMinutes;
    final shift = ShiftDetails(
      type: _type,
      // Converted back to the formatted-string shape ShiftDetails has
      // always used — no schema change; only this form's own internal
      // representation of "in progress" Start/Finish values changed.
      startTime: start == null
          ? null
          : AppDateFormat.timeOfDayFromMinutes(start),
      endTime: end == null ? null : AppDateFormat.timeOfDayFromMinutes(end),
      // Calculated, not read from a text field the user typed into — this
      // phase's whole point. `_calculatedHours` is `null` exactly when
      // Start or Finish is unset, matching how Off/Leave/Public Holiday
      // shifts have always had no hours value at all.
      hours: _calculatedHours,
      breakMinutes: _breakMinutes,
      notes: _blankToNull(_notesController.text),
    );
    await widget.onSave(widget.date, shift);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDeleteShiftDialog(context);
    if (confirmed != true) return;
    await widget.onDelete(widget.date);
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
        // Room for the on-screen keyboard, so the field being typed into
        // is never covered by it.
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Shift' : 'Add Shift',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // The Template selector loads independently of the rest of
            // this form (see [_templatesFuture]) — a brief loading gap
            // here shouldn't block typing into any other field, so only
            // this one small piece is wrapped in a FutureBuilder rather
            // than the whole form.
            FutureBuilder<List<ShiftTemplate>>(
              future: _templatesFuture,
              builder: (context, snapshot) {
                final templates = snapshot.data ?? const [];
                if (templates.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ShiftTemplateDropdown(
                    templates: templates,
                    selected: _selectedTemplate,
                    onSelected: _applyTemplate,
                  ),
                );
              },
            ),
            ShiftTypeDropdown(
              selected: _type,
              onSelected: (value) => setState(() => _type = value),
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
              // Hours depends on this field, so every keystroke needs to
              // trigger a rebuild — a plain TextField doesn't do that on
              // its own the way a value passed into `setState` would.
              onChanged: (_) => setState(() {}),
              errorText: _breakTooLong
                  ? 'Unpaid break cannot exceed shift duration'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            CalculatedHoursField(hours: _calculatedHours),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
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
                  child: const Text('Delete Shift'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
