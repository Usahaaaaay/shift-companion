// calendar_screen.dart
//
// The Calendar — the app's monthly schedule view, described in
// docs/Software_Requirements.md Section 5.2 and docs/Feature_List.md
// ("Shift Calendar", Core Features).
//
// PHASE 2.1 SCOPE: this screen is purely static — today's real month,
// rendered with no month navigation. It exists so the Calendar tab has
// something real to look at in the emulator before any of that behavior is
// built. See the widgets this screen composes (MonthHeader, WeekdayRow,
// CalendarGrid) for what's deliberately deferred to later phases.
//
// PHASE 2.2: each day can now show a small shift-color dot (see
// CalendarGrid/CalendarDayCell). This screen is still the one place that
// decides where that data comes from — so a real data source later only
// touches this file, not the grid or cell widgets.
//
// PHASE 2.3: the calendar is now interactive — a single day can be
// selected. The selected date lives here, at the screen level (see
// _selectedDate below), and flows downward through CalendarGrid to
// CalendarDayCell; taps flow back up through a callback. See this file's
// State class for why it's owned here rather than deeper in the tree.
//
// PHASE 2.4: selecting a day now also opens a shift-details bottom sheet
// (see widgets/calendar_bottom_sheet.dart) — the only new behavior that
// phase added. Selection itself, the grid, month header, and weekday row
// were otherwise untouched.
//
// PHASE 2.5: this screen started owning a real (if purely in-memory)
// shift map, replacing a fixed dummy source, with getShift/addShift
// passed down to the bottom sheet as callbacks.
//
// PHASE 2.6: this screen no longer *owns* shift storage at all — it holds
// a [ShiftRepository] (injected via the constructor, not created here) and
// every read/write goes through it.
//
// PHASE 3.2A: [ShiftRepository] is now asynchronous (real SQLite access,
// once DriftShiftRepository is wired in, can't be read synchronously —
// see that interface's own note). CalendarGrid still needs a plain
// `Map<DateTime, ShiftDetails>` synchronously inside `build()`, so this
// screen now keeps a local [_shifts] cache: loaded once in `initState`,
// reloaded after every write. This is a cache of what the repository
// already holds, not a second source of truth — the repository is still
// the only place data is actually written.
//
// PHASE 3.3: `addShift(date, type)` — which only ever built a
// ShiftDetails.placeholderFor(type) — is replaced by [saveShift], which
// takes a full ShiftDetails from the new create/edit form. [deleteShift]
// is new: ShiftRepository.deleteShift already existed (added in Phase
// 2.6), but nothing called it until the form's Delete button needed it.
// Neither required any repository or database change — see this feature's
// Phase 3.3 summary for why.
//
// PHASE 3.4: added [getTemplates] — a thin pass-through to
// `widget.repository.getTemplates()`, exactly like [getShift] already is
// for `getShift`. This screen still doesn't compute or cache anything
// about templates itself; it's simply the one place (per
// ARCHITECTURE.md's "no widget touches the database directly" rule) that
// holds the repository and can hand a read of it down to whatever needs
// one.
//
// Unlike the Dashboard, this screen uses a real AppBar — per
// docs/Design_System.md Section 8.8, every screen except the landing tab
// gets one; Calendar isn't the landing tab, so it follows the default.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/shift_details.dart';
import '../../domain/entities/shift_template.dart';
import '../../domain/repositories/shift_repository.dart';
import '../widgets/calendar_bottom_sheet.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/month_header.dart';
import '../widgets/weekday_row.dart';

/// The Calendar screen — a monthly grid for the current month, with a
/// single selectable day, backed by a [ShiftRepository] the screen
/// receives rather than creates.
class CalendarScreen extends StatefulWidget {
  /// Creates the Calendar screen.
  ///
  /// [repository] is a required dependency, not constructed here — see
  /// routing/app_router.dart for where it's actually instantiated. This
  /// keeps the screen independent of *how* shifts are stored; it only
  /// needs something that satisfies [ShiftRepository].
  const CalendarScreen({super.key, required this.repository});

  /// Where this screen's shift data is read from and written to.
  final ShiftRepository repository;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// The single currently-selected day, or `null` until the user taps one.
  ///
  /// Owned here, at the screen level — this is transient view state local
  /// to one screen, not app data, so it doesn't need Riverpod (see
  /// decisions/0001-state-management-and-navigation.md, which reserves
  /// Riverpod for state that needs DI or cross-screen sharing; a selected
  /// calendar day is neither).
  DateTime? _selectedDate;

  /// A local cache of [widget.repository]'s shifts, for CalendarGrid's
  /// benefit — `build()` can't `await` the repository directly. Loaded
  /// once in [initState] and refreshed after every [addShift]; the
  /// repository itself remains the single source of truth.
  Map<DateTime, ShiftDetails> _shifts = {};

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final shifts = await widget.repository.getAllShifts();
    if (mounted) setState(() => _shifts = shifts);
  }

  /// Returns the shift assigned to [date], if any. Passed down to the
  /// bottom sheet as a callback (see calendar_bottom_sheet.dart) rather
  /// than a value, so it can be re-read after [saveShift]/[deleteShift]
  /// change it.
  Future<ShiftDetails?> getShift(DateTime date) =>
      widget.repository.getShift(date);

  /// Returns every currently-stored Shift Template, for the create/edit
  /// form's Template selector. Passed down as a callback (not a value),
  /// same as [getShift] — it's re-invoked fresh each time the form opens
  /// rather than read once here and grown stale.
  Future<List<ShiftTemplate>> getTemplates() =>
      widget.repository.getTemplates();

  /// Records [shift] for [date] via [widget.repository] — creating a new
  /// row or overwriting an existing one; `ShiftRepository.saveShift` is
  /// already an upsert, so there's no separate path for either case — then
  /// reloads [_shifts] so the calendar grid's dot updates immediately.
  Future<void> saveShift(DateTime date, ShiftDetails shift) async {
    await widget.repository.saveShift(date, shift);
    await _loadShifts();
  }

  /// Removes the shift for [date] via [widget.repository], then reloads
  /// [_shifts] so the calendar grid's dot disappears immediately.
  Future<void> deleteShift(DateTime date) async {
    await widget.repository.deleteShift(date);
    await _loadShifts();
  }

  void _handleDaySelected(DateTime date) {
    // Update selection first (so the selected circle appears immediately
    // behind the sheet), then open the sheet — matching the established
    // flow: "Selected day updates" before "showModalBottomSheet()".
    setState(() => _selectedDate = date);
    showCalendarBottomSheet(
      context,
      selectedDate: date,
      getShift: getShift,
      onSaveShift: saveShift,
      onDeleteShift: deleteShift,
      getTemplates: getTemplates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final displayedMonth = DateTime(today.year, today.month);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthHeader(month: displayedMonth),
              const SizedBox(height: AppSpacing.lg),
              const WeekdayRow(),
              const SizedBox(height: AppSpacing.sm),
              CalendarGrid(
                month: displayedMonth,
                today: today,
                shifts: _shifts,
                selectedDate: _selectedDate,
                onDaySelected: _handleDaySelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
