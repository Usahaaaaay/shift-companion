// dashboard_screen.dart
//
// The Dashboard — the app's landing view, described in
// docs/Software_Requirements.md Section 5.1 and docs/Feature_List.md
// ("Dashboard", Core Features).
//
// This screen is currently read-only: it renders a single hardcoded
// DashboardSummary (see ../dashboard_mock_data.dart) with no calendar,
// editing, or scheduling behavior, per this task's scope. Business logic
// stays out of this widget — it composes smaller, single-purpose widgets
// (GreetingHeader, TodayShiftCard, QuickStatsGrid, UpcomingShiftCard,
// QuickActionsSection, MotivationCard) and hands each one the slice of data
// it needs, exactly as ARCHITECTURE.md's presentation layer describes.
//
// FUTURE DATA CONNECTION: once the Dashboard needs live data, turn this
// into a ConsumerWidget and replace the `DashboardMockData.summary` read
// below with `ref.watch(dashboardSummaryProvider)` — a provider that will
// live in presentation/providers/. None of the widgets this screen composes
// should need to change when that happens; they already consume a
// DashboardSummary, not this mock source.
//
// VISUAL REFRESH (Dashboard V1.1): every section now gets more surrounding
// whitespace (screen padding and inter-section gaps moved up the
// AppSpacing scale), and each section fades/slides gently into place on
// first load via the private `_FadeSlideIn` helper below — a single,
// shared, one-shot animation kept here rather than duplicated into every
// widget file, so the composing screen owns the page's motion choreography
// while each widget stays focused on its own layout.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../dashboard_mock_data.dart';
import '../widgets/greeting_header.dart';
import '../widgets/motivation_card.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/quick_stats_grid.dart';
import '../widgets/today_shift_card.dart';
import '../widgets/upcoming_shift_card.dart';

/// The Dashboard screen — a single-glance, read-only summary of the user's
/// day.
///
/// A plain [StatelessWidget] for now since there is no state to hold — see
/// the FUTURE DATA CONNECTION note above for what changes once real data
/// arrives.
class DashboardScreen extends StatelessWidget {
  /// Creates the Dashboard screen.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(dashboard-data): swap for `ref.watch(dashboardSummaryProvider)`
    // once a real data/domain stack exists for this feature — see the
    // FUTURE DATA CONNECTION note above and dashboard_mock_data.dart.
    final summary = DashboardMockData.summary;

    return Scaffold(
      // No AppBar here — see GreetingHeader's doc comment for why the
      // greeting and date live in the scrollable body instead.
      body: SafeArea(
        child: SingleChildScrollView(
          // More generous outer margin than the app's default spacing —
          // "increase whitespace... everything should breathe".
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FadeSlideIn(child: GreetingHeader(name: summary.greetingName)),
              // Extra room under the greeting specifically, per this
              // task's "increase whitespace underneath [the greeting]".
              const SizedBox(height: AppSpacing.xxl),

              // Section 1 — Today's Shift: the screen's hero.
              _FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: TodayShiftCard(shift: summary.today),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Section 2 — Quick Stats: four figures in a 2x2 grid.
              _FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: QuickStatsGrid(stats: summary.quickStats),
              ),

              // Section 3 — Upcoming Shift (only shown when one exists).
              if (summary.upcomingShift != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: UpcomingShiftCard(shift: summary.upcomingShift!),
                ),
              ],

              // Section 4 — Quick Actions: navigation only, no behavior yet.
              const SizedBox(height: AppSpacing.xl),
              _FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: const QuickActionsSection(),
              ),

              // Section 5 — Motivation: one contextual message.
              const SizedBox(height: AppSpacing.xl),
              _FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: MotivationCard(message: summary.motivationalMessage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and gently slides [child] upward once, when it first appears on
/// screen, then stays put — used to give the Dashboard's sections a soft,
/// staggered entrance instead of popping straight into view. [delay]
/// offsets when each section starts, producing the cascade down the page.
///
/// This is a one-shot visual entrance only: once each tween reaches 1.0 it
/// stops driving, so — beyond the moment sections settle in — this adds no
/// ongoing rebuild or repaint cost, per this task's Performance
/// requirements. It also honors the OS "reduce motion" accessibility
/// setting (docs/UI_UX_Principles.md Section 15) by skipping straight to
/// the settled state when that's enabled, rather than forcing motion on a
/// user who's asked not to see it.
///
/// Kept private to this file rather than promoted to a shared widget:
/// per-widget entrance choreography belongs to whoever is composing a
/// screen, not to the individual widgets being composed — and nothing
/// else in the app needs it yet (see core/widgets/README.md's "promote
/// only on a real second use" rule).
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;

    return FutureBuilder<void>(
      future: delay == Duration.zero ? null : Future<void>.delayed(delay),
      builder: (context, snapshot) {
        final settled =
            delay == Duration.zero ||
            snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: settled ? 1.0 : 0.0),
          duration: AppConstants.animationStandard,
          curve: Curves.easeOutCubic,
          builder: (context, value, animatedChild) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: animatedChild,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}
