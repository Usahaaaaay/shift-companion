# Shift Companion — UX & Product Design Plan

*This document is the complete application-experience plan: navigation, information
architecture, screen-by-screen design, the Calendar's interaction model, a design-system
extension for shift-type color coding, and a phased roadmap. It sits one level below
[VISION.md](VISION.md) (why) and [UI_UX_Principles.md](UI_UX_Principles.md) (how every
screen should feel) and one level above individual feature specs — it's where those
principles get applied to actual screens, in order.*

*Related documents: [VISION.md](VISION.md) (mission, audience, product principles this
plan is built to serve), [Software_Requirements.md](Software_Requirements.md) (the
functional requirements each screen below must satisfy — FR-DASH-\*, FR-CAL-\*, FR-AL-\*,
etc.), [Feature_List.md](Feature_List.md) (priority and version tier for every feature
referenced here), [UI_UX_Principles.md](UI_UX_Principles.md) (the design philosophy this
plan applies), [Design_System.md](Design_System.md) (the concrete tokens and component
specs this plan's screens are built from — including the finalized shift-color palette
that §8.2 below only scoped, not resolved), [ARCHITECTURE.md](../ARCHITECTURE.md) (how
this eventually becomes code — not addressed here by design).*

*Status: proposed. No code, no data models, no backend covered — see
[Important Constraints](#12-out-of-scope-by-design) at the end.*

---

## 0. How to Read This Document

Twelve sections, each answering one part of the brief: philosophy, app map, navigation,
screens, journeys, Calendar flow, Dashboard layout, design system, UX improvements,
usability risks, deferred features, and roadmap. Where a recommendation **disagrees**
with the starting brief, it's called out explicitly with the reasoning — this document
exists to pressure-test the plan, not just transcribe it.

---

## 1. Product Philosophy

Everything below is downstream of three lines already in VISION.md, applied specifically
to navigation and screen design:

- **"The best tool for a tired person is the one that asks the least of them."** →
  Every screen in this plan is scored against a single question: *does this reduce or
  add to what the user has to hold in their head?* A feature that's impressive but adds
  a decision loses to a feature that's boring but removes one.
- **"Clarity over completeness."** → Nothing in this plan ships "everything possible" in
  v1. Every screen below has an explicit MVP cut and a clearly labeled "later" list.
- **"Progressive depth."** → Simple by default, more available on request. This shows up
  concretely as: summary numbers before charts, a bottom sheet before a full edit screen,
  four dashboard tiles before a customizable grid.

One addition this plan makes explicit, because it will get tested constantly as the app
grows: **every screen must be reachable in a way that survives losing three more screens
to the app later.** Concretely — no screen should be the *only* way to reach a piece of
information. (Today's shift lives on the Dashboard *and* the Calendar. A leave balance
will live on the Leave screen *and* the Dashboard *and*, eventually, inline wherever a
leave date appears.) Redundant access, not redundant UI — this is what "future features
extend rather than replace" means in practice.

---

## 2. Navigation Architecture

### 2.1 Evaluating the proposed structure

The brief proposes: **Dashboard · Calendar · Leave · Reports · Settings.**

This is workable, but it has one real problem and one soft problem.

**The real problem: Earnings has no home.** VISION.md doesn't treat earnings as a nice-
to-have — it's named as one of the two things (alongside time) "workers can least afford
to be wrong about," and Section 6 calls out earnings/payroll awareness as a named
differentiator ("most tools stop at 'when do I work'"). Feature_List.md rates *Weekly
Earnings* and *Monthly Earnings* **High priority, Version 1.0** — the same tier as Leave.
A five-tab structure that gives Leave a permanent tab and gives Earnings *nothing* sends
the opposite signal from the one the product is supposed to send. This isn't a minor
omission to patch later — earnings navigation is exactly the kind of decision that's
expensive to retrofit once users have a year of muscle memory pointing at "Reports" for
something that was never really a report.

**The soft problem: Reports and Settings are both low-frequency.** Bottom-tab real
estate is the most expensive real estate in the app — it's on screen 100% of the time,
it's within thumb reach, and there are only ever four or five slots. Reports (Feature
List: *Statistics (Core)*, **Medium** priority, 1.0) is something a user checks weekly or
monthly, not daily. Settings is something a user visits during onboarding and then
almost never again. Two of five permanent slots going to occasional-use destinations is
a worse trade than it looks — every day, twice a slot's worth of thumb-reach is spent on
something most users won't touch that day.

### 2.2 Recommended structure

| # | Tab | Why it earns a permanent slot |
|---|---|---|
| 1 | **Dashboard** | The daily landing question: "what does today look like." Highest frequency in the app. |
| 2 | **Calendar** | The system of record (per ARCHITECTURE.md's own framing) and, per the brief, the app's gravitational center. Second-highest frequency. |
| 3 | **Leave** | A distinct, recurring question ("how much do I have left," "can I take Friday off") that doesn't naturally live inside a date grid — see §2.3. High priority, 1.0. |
| 4 | **Earnings** | Restores the pillar the original structure dropped. High priority, 1.0, and a named product differentiator per VISION.md. |
| 5 | **More** | Umbrella tab for everything genuinely infrequent: Reports/Statistics, Settings, Profile, Export/Import, Help & About. |

This keeps the "maximum five tabs" constraint, keeps the calm four-primary-destinations
feel the brief is going for, and fixes the earnings gap without adding a sixth tab.

**"More" is a well-tested pattern, not a dumping ground** — Instagram's profile tab,
most banking apps' "Account" tab, and WhatsApp's "More" all use exactly this shape:
one predictable slot for "everything I need occasionally but not today." Reports gets a
prominent first position *inside* More (it's the most-used of that group), with Settings,
Profile, Export, and Help below it. Nothing here needs its own tab to be discoverable —
it needs one tap to be discoverable, and one tap is what More provides.

**This is explicitly reversible without a redesign.** If usage data post-launch shows
Reports genuinely gets opened daily (some users are numbers people), promoting it from
"inside More" to "own tab" is a navigation-bar change, not an information-architecture
change — the screen itself doesn't move or get rebuilt. That reversibility is the actual
point of deferring the decision now rather than guessing.

### 2.3 Why Leave stays a full tab (and doesn't fold into Calendar)

This was worth stress-testing, because "Leave is just colored days on the calendar" is a
reasonable-sounding simplification. Three reasons it doesn't hold up:

1. **The questions are different verbs.** Calendar answers "when." Leave answers "how
   much do I have, and can I afford to take more." Those are different mental tasks even
   when they touch the same dates.
2. **Three leave types, each with entitlement/balance/history** (Annual, Sick,
   Alternative Holiday — FR-AL/FR-SL/FR-AH) is real surface area. Squeezing entitlement
   math and balance warnings into a calendar day-cell sheet would violate "one clear
   purpose per card" at the sheet level.
3. **It's the kind of question asked away from the calendar** — texting a manager "can I
   take next Friday off" happens before anyone opens a date grid. It needs a
   glanceable, standalone answer.

Calendar and Leave stay **two-way linked** instead (§2.4): tapping a leave day on the
Calendar deep-links into that leave record on the Leave tab; every leave entry on the
Leave tab can jump to "view on calendar." Two tabs, one shared source of truth, no
duplicate editing surfaces.

### 2.4 Cross-linking rule (stated once, applied everywhere)

Any piece of information that could reasonably be reached from two tabs **must** be, via
a visible link, not a hidden gesture. This is the concrete mechanism behind §1's "no
screen is the only way in" principle, and it's cheap to build correctly from the start,
expensive to retrofit later:

- Dashboard's "Today's Shift" ↔ that day's Calendar cell.
- A Calendar day showing leave ↔ that entry on the Leave tab.
- A Calendar shift ↔ its earnings line on the Earnings tab (once pay rates exist).
- Earnings period totals ↔ the Reports screen (inside More) for the trend view.

---

## 3. Complete App Map

```
Bottom Navigation
├── Dashboard
│   ├── → Today's Shift detail (opens the same bottom sheet Calendar uses — one
│   │      component, two entry points, per §2.4)
│   └── Quick Actions → Add Shift · Earnings · Leave · History
│         (each a deep link into another tab, never a new destination)
│
├── Calendar
│   ├── Month view (default) ⇄ Week view (segmented control, satisfies FR-CAL-1)
│   ├── Day bottom sheet → view details
│   │     └── Edit → full-screen edit form (only reached deliberately, never by
│   │           default — see §6)
│   │     └── Delete → confirmation (destructive-action pattern, §8)
│   ├── Shift Pattern Generator (multi-step, entered via FAB/overflow — a distinct
│   │     flow, not a form field, because it's a one-time setup task)
│   └── Search / Filter (FR-CAL-7 — icon in the app bar, not a tab)
│
├── Leave
│   ├── Balance summary (Annual / Sick / Alternative Holiday — three cards)
│   ├── Request/record leave (date range → type → confirm)
│   ├── Leave history (past entries, filterable by type)
│   └── Public Holidays (region list; flags which fall on a scheduled shift)
│
├── Earnings
│   ├── Period hero (This Week / This Month / This Year — segmented, mirrors
│   │     TodayShiftCard's hero treatment for visual consistency)
│   ├── Pay rate setup (base / overtime / differential — FR-EARN-2)
│   └── Per-shift breakdown (drill-down; cross-linked from Calendar day sheet)
│
└── More
    ├── Reports & Statistics (top of the list — most-used item in this tab)
    ├── Settings (theme, region/currency, first day of week, notifications,
    │     accessibility)
    ├── Profile (name, jobs/employers, avatar)
    ├── Export / Import data
    └── Help, About, Privacy
```

A secondary, low-emphasis **settings/profile icon** also lives in the Dashboard's top
corner (not a second nav system — just a shortcut). New users configuring leave
entitlement or a pay rate right after install shouldn't have to learn "More → Settings"
is where setup lives; returning users who already know where things are will use the
tab. Both point at the same screen — this is a shortcut, not a duplicate destination.

---

## 4. Screen-by-Screen Breakdown

Each entry: primary question it answers, what's emphasized, what's deliberately hidden.

### Dashboard *(already built — see §7 for validation against this plan)*
- **Answers:** "What does today look like, right now?"
- **Emphasizes:** Today's shift (hero), this week's hours, what's next.
- **Hides:** Anything requiring a decision. Dashboard is read-only by design (already
  true of the current build) — every action it offers navigates elsewhere.

### Calendar
- **Answers:** "What does my month/week look like, and what's on a specific day?"
- **Emphasizes:** Color-coded day states, the current day's position, the monthly
  summary strip.
- **Hides:** Editing (behind an explicit tap-through, §6), notes/details (behind the
  bottom sheet, not inline in the grid — a day cell has room for a color and a time,
  not a paragraph).

### Leave
- **Answers:** "How much leave do I have, and what have I used?"
- **Emphasizes:** The three balances, in the same visual weight as each other (no leave
  type should look more or less important by default — that's a per-user reality, not a
  design choice to make for them).
- **Hides:** Full history by default (collapsed behind "view all"); entitlement-editing
  (a Settings-adjacent action, not a daily one).

### Earnings
- **Answers:** "What am I on track to earn, and did last period look right?"
- **Emphasizes:** The current period's estimate, clearly labeled *estimate* per BR-5 —
  this label is non-negotiable per VISION.md's "accuracy is non-negotiable" and must
  never be visually de-emphasized into fine print.
- **Hides:** Multi-job breakdowns and pay-rate configuration behind drill-in — most
  users have one job and one rate; don't make them look at a table to see one number.

### Leave Request flow *(modal-like, not a tab)*
- **Answers:** nothing on its own — it's a task, not a place. Should feel like it,
  visually: a focused, dismissible flow, not a screen you "arrive" at.

### Reports (inside More)
- **Answers:** "What's my pattern been, lately?"
- **Emphasizes:** Whichever 3–4 reports are actually shipped first (§11) — resist
  building a report picker/grid for reports that don't exist yet.
- **Hides:** Everything else, until it's real.

### Settings
- **Answers:** nothing directly — configures how every other screen behaves.
- **Emphasizes:** The handful of settings people actually change (theme, region,
  notifications). See §4.1 in the "Settings" brief section below for the full list and
  what's deliberately excluded.

---

## 5. User Journeys for Common Tasks

| Task | Path | Taps | Notes |
|---|---|---|---|
| "What time do I start tomorrow?" | Dashboard (Upcoming Shift card is already visible) | 0 | This is the whole point of the Dashboard existing — if this ever takes a tap, something regressed. |
| "What's on Friday?" | Calendar → tap Friday | 2 | Bottom sheet, not a new screen — stays fast. |
| "How much annual leave do I have?" | Leave tab | 1 | Glanceable, no drill-down needed for the number itself. |
| "Request Friday off" | Leave tab → Request → pick date/type → confirm | ~5 | Acceptable — this is a "write," not a glance; per UI_UX_Principles §10, the form should still pre-fill sensible defaults (type defaults to Annual, not blank). |
| "What did I earn this month?" | Earnings tab | 1 | Monthly should be the tab's default view, since "am I on track" is asked more than "what was my exact week." |
| "Set up my 4-on-4-off roster" | Calendar → Pattern Generator → guided steps | multi-step | Not a speed target — a one-time setup task. Must be resumable (UI_UX_Principles §10) since users will realistically get interrupted mid-setup. |
| "I got a shift change text — update Tuesday" | Calendar → Tuesday → Edit → save | 4 | The one flow above where speed does matter again — "Predictability over cleverness" applies: editing should look exactly like the pattern already learned from viewing. |

---

## 6. Calendar Interaction Flow

The proposed flow — **tap day → bottom sheet → view details → optional Edit** — is
correct and shouldn't change. It matches UI_UX_Principles §4 ("modals are for focused,
temporary tasks") and directly avoids the classic calendar-app mistake of one tap
dropping a user into an edit form for information they only wanted to glance at.

**Refinements:**

- **The grid should reduce how often the sheet is even needed.** If a day cell already
  shows a color dot *and* a compact time range (e.g. "7–4:30"), many "what time do I
  start" questions resolve without opening anything. The bottom sheet is for depth, not
  for information that fits in a cell.
- **Dismiss gesture:** swipe-down-to-dismiss on the sheet, consistent with system sheet
  conventions — no separate "close" tap required.
- **Long-press on an empty day** as a future fast-path to "add shift here" — not in v1
  (adds a discoverability problem before there's a design for teaching it), but worth
  reserving the gesture now so it isn't claimed by something else later.

### 6.1 Bottom sheet content — additions to what was listed

The brief's list (Date, Shift type, Start/Finish, Hours, Department, Notes, Edit,
Delete) is the right core. Additions, each justified against "useful without crowding":

| Addition | Why it earns a place | Priority |
|---|---|---|
| **Relative time** ("Starts in 3 days" / "Started 2h ago") | Directly serves "glanceable first" — turns an absolute date into the answer the user actually wanted. | Ship with v1 |
| **Status flag** (Confirmed / Swapped / Cancelled) | FR-CAL-6 already requires tracking this; surfacing it here (small badge next to shift type) means it doesn't need a separate screen. | Ship when FR-CAL-6 lands |
| **Public holiday indicator** | A shift landing on a public holiday has pay implications (FR-PH-3/FR-PH-5) users will specifically want to know about *before* opening Earnings. | Ship with Public Holiday feature |
| **Break duration** | Already part of the shift entry per FR-CAL-3; showing it here avoids a second sheet just for breaks. | Ship with v1 |
| **Estimated pay for this shift** | Cross-links Calendar → Earnings without leaving the sheet — but only once pay rates exist; showing "—" or hiding the row entirely beforehand, never a fake $0. | Ship with Earnings |
| **Duplicate to next week** | A genuinely common shift-worker action (same shift, different week) that today would otherwise mean re-entering everything. | Consider for 1.1, not MVP |

Two of these (status flag, estimated pay) only make sense once other features exist —
the sheet's layout should reserve visual space/priority for them conceptually now, so
adding them later is "un-hiding a row," not restructuring the sheet.

### 6.2 Monthly summary — refinement

The proposed content (hours, shifts, days off, leave days) is good and should **stay at
four numbers, not grow** — this is the one part of the Calendar screen most at risk of
slowly accumulating "just one more stat" until it becomes a second Dashboard. Two
structural additions instead of more numbers:

- **Month navigation built into the same bar** (prev/next arrows, tap the month name to
  jump, a "Today" shortcut when scrolled away from the current month) — this is
  currently unaddressed in the brief and is a hard requirement once someone starts
  swiping through months.
- **A comparison delta, opt-in only** (e.g., tapping the hours figure reveals "vs 152
  last month") — progressive disclosure per UI_UX_Principles §2, not shown by default.

---

## 7. Dashboard Layout — Validation Against What Was Already Built

The Dashboard already exists (GreetingHeader, TodayShiftCard as hero, a 2×2 Quick Stats
grid, UpcomingShiftCard, QuickActionsSection, MotivationCard). Checking it against the
five questions this brief poses:

| Question | Answered by the current build? |
|---|---|
| "When do I work next?" | ✅ TodayShiftCard (if working today) / UpcomingShiftCard otherwise. |
| "How many hours this week?" | ✅ Quick Stats — "Hours This Week" tile. |
| "What shifts are coming up?" | ✅ UpcomingShiftCard, though only the single next shift — a short 2–3 day look-ahead list is worth considering once real data exists (see below). |
| "When is my next day off?" | ⚠️ **Gap.** The current Quick Stats grid has a "Next Leave" tile, which is a different question — leave is a *booked* day off; "next day off" could be as soon as tomorrow with no leave involved at all, purely from the roster having a gap. Recommend this becomes its own computed figure once Calendar data is real, likely by making Quick Stats data-driven rather than four fixed tiles (which also happens to be exactly what FR-DASH-7 — "user shall be able to choose which summary items appear" — will need anyway). |
| "What important information needs my attention?" | ⚠️ **Not addressed yet, and shouldn't be forced now.** There's currently no "attention" concept on the Dashboard (a low leave balance, a shift starting soon, an unconfirmed swap). Recommend reserving a slot — a single optional banner above TodayShiftCard — rather than building it today with nothing real to show. An always-empty or fabricated alert would violate VISION.md's "honest visual language" principle faster than not having one at all. |

**Net assessment:** the existing Dashboard answers 3 of 5 questions well today (limited
only by mock data, not design), has one real conceptual gap ("next day off" ≠ "next
leave") worth fixing when Calendar data lands, and correctly leaves the fifth
(attention/alerts) unbuilt rather than faked.

---

## 8. Design System — Extending What's Already There

The codebase already has real tokens (`AppSpacing`, `AppColors`, `AppTypography`,
`AppTheme`, `AppConstants`) built on Material 3's tonal `ColorScheme.fromSeed`. This
section extends that system for the Calendar's needs rather than proposing a parallel
one.

### 8.1 Spacing & corner radius
No changes needed — `AppSpacing`'s xs(4)–xxl(48) scale and radiusSm/Md/Lg(8/16/24)
already cover a calendar grid, day-cell padding, and a bottom sheet's rounded top
corners (which should use `radiusLg`, matching the existing convention that larger
radii mark "prominent, full-width surfaces").

### 8.2 Shift-type color coding — a deliberate, bounded exception

*Note: this section scopes the exception and its risks. Final hex values (now expanded
to nine states — Holiday and Training were added after this section was written, plus
Overtime as a non-fill indicator) live in
[Design_System.md §3.4](Design_System.md#34-shift-type-colors--a-deliberate-bounded-exception),
which supersedes the color choices implied below.*

UI_UX_Principles §5 commits the app to "a calm neutral base with one confident accent."
Six shift-state colors is a real exception to that rule — and it should be treated as
one explicitly, not slipped in quietly:

- **Scope the exception narrowly.** These six colors mean exactly one thing — shift/day
  state on the Calendar and anywhere a day is referenced elsewhere (Dashboard, Leave) —
  and are never reused decoratively, consistent with §5's "consistent status colors
  app-wide, no exceptions."
- **Don't hand-pick six arbitrary hues.** Derive them from the same seed-based tonal
  system already in use (`ColorScheme.fromSeed`), supplemented by 2–3 additional
  deliberately chosen accent hues, so all six stay visually related as "one family of
  six," not six unrelated brand colors, and so light/dark parity (§16) comes for free
  rather than needing six manual dark-mode overrides.
- **Flag a real accessibility problem in the brief's own example.** 🟢 Morning and 🔴
  Leave is a red/green pairing — the single hardest color pair for the most common form
  of color blindness (deuteranopia/protanopia, ~8% of men) to tell apart. This isn't
  hypothetical: it's the two colors literally offered as the example. Two mitigations,
  both already implied by existing principles (§15: "color is never the only signal"):
  - Every day cell pairs its color with a **shape or glyph**, not color alone (e.g., a
    small filled circle vs. outlined ring vs. half-and-half mark for Split Shift —
    see §9), so the color-blind path to understanding never depends on hue alone.
  - When the final six hues are chosen, run them through a color-blindness simulation
    before locking them in — prefer blue/orange/purple-leaning combinations over
    red/green ones wherever the mapping is arbitrary (i.e., not already fixed by
    convention like "red = leave").
- **Reserve, don't assign, a 7th visual state.** "No data yet" (a date beyond the
  roster's generated horizon) must look different from "confirmed day off" — one is an
  absence of information, the other is a deliberate fact about the user's day. Treat
  this as neutral/undyed, closer to the scaffold background than to Day Off's white/grey
  dot, so it doesn't read as a seventh color competing with the other six.

### 8.3 Typography
Reuse the existing `AppTypography.glanceableNumeral` style — currently only used on the
Dashboard's shift times — for the Calendar's monthly summary figures and the Earnings
hero number too. The doc comment on that style already names "hours worked" and
"earnings figures" as intended future consumers; this plan is where that intention gets
followed through, so numerals stay visually consistent everywhere they're the most
important thing on the screen, not just on the Dashboard.

### 8.4 Icon style
The codebase currently mixes outlined and rounded-filled Material icons somewhat
informally. Recommend formalizing one rule now, before Calendar/Leave/Earnings triple
the number of icons in the app: **outlined for status/informational icons (department,
location, time), rounded-filled for primary actions and the active bottom-nav tab.**
This mirrors Material 3's own convention and prevents icon-language drift as more
screens get built by different sessions/contributors over time (UI_UX_Principles §7:
"one consistent icon language").

### 8.5 Elevation
Continue the existing commitment to **tonal elevation over drop shadows**
(`CardThemeData(elevation: 0)`, colored surfaces instead) — including for the Calendar's
bottom sheet (Material 3's `surfaceContainerHigh` scrim convention) and the "today"
indicator on the month grid. No new elevation system needed.

### 8.6 Animation
Reuse `AppConstants.animationFast/Standard/Slow` (150/250/350ms) rather than inventing
Calendar-specific durations: **animationFast** for day-selection highlight,
**animationStandard** for the bottom sheet's open/close and month-swipe transitions,
**animationSlow** reserved for full-screen transitions (e.g., entering the Pattern
Generator). Keep the Dashboard's existing pattern of one-shot entrance animations that
honor `MediaQuery.disableAnimations` — apply the same reduced-motion check to Calendar's
month-swipe and sheet transitions rather than treating it as Dashboard-only.

---

## 9. UX Improvements Beyond the Initial Concept

- **Split Shift as a visual composite, not a 7th arbitrary color.** Render it as a
  half-and-half mark (e.g., top half in the morning hue, bottom half in the
  evening/night hue) so the cell *shows* why it's split rather than asking the user to
  remember what yellow means.
- **A "Today" re-center action** whenever the Calendar is scrolled away from the current
  month/week — small, persistent, and exactly analogous to a maps app's recenter button.
- **Week view as a first-class toggle, not an afterthought** — FR-CAL-1 already requires
  daily/weekly/monthly views; a segmented control at the top of Calendar (Month/Week)
  satisfies this without adding a navigation destination.
- **Two-way Calendar↔Leave↔Earnings linking** (§2.4) — the single highest-leverage
  connective-tissue investment in this plan, because it's what makes five tabs feel like
  one coherent app instead of five separate ones.
- **A dashboard-first-run state** distinct from an ordinary quiet day — a brand-new user
  with no shifts entered yet shouldn't see an empty version of the same hero card;
  they should see an explicit "let's set up your first shift or pattern" prompt (ties
  directly to UI_UX_Principles §12, Empty States).
- **Resumable long forms**, applied specifically to the Pattern Generator wizard and the
  Leave Request flow — both are named in UI_UX_Principles §10 as needing this, and both
  are new surface area this plan introduces, so it's worth stating again at the point
  where it actually gets built.

---

## 10. Potential Usability Problems and How to Avoid Them

| Risk | Mitigation |
|---|---|
| Bottom sheet slowly accumulates fields (§6.1) until it stops feeling "quick" | Cap primary content to what fits without scrolling on a small phone; anything beyond that goes behind a "More details" expand, not onto the main sheet. |
| Color-only shift coding fails color-blind users | Shape/glyph pairing + pre-launch color-blindness simulation (§8.2) — non-negotiable, not a nice-to-have. |
| Sheet-vs-full-screen usage drifts inconsistent as features accumulate | Fix the rule now: **sheets for viewing + single-step quick actions; full screens for anything multi-step or needing its own back-stack** (editing, Pattern Generator, Leave Request). Apply retroactively if anything violates it later. |
| Reports feels empty/useless in a new user's first weeks | A real empty state ("come back after your first week of shifts") rather than a chart rendering with one data point looking broken; consider gating Reports' promotion out of "More" on there being enough data to be useful at all. |
| Leave and Calendar feel like two disconnected places for the same information | Enforced by the cross-linking rule (§2.4) — treat any future PR that adds a leave-related UI without a calendar link (or vice versa) as incomplete. |
| Settings buried in "More" is hard to find during first-run setup | Secondary shortcut icon on the Dashboard (§3) — deliberate dual entry point, not redundant clutter. |
| "Estimated" earnings get mistaken for confirmed pay | The *estimate* label (BR-5) must be a first-class, permanent visual element on every earnings figure — never fine print, never a tooltip-only disclosure. |
| Multi-job / multi-rate complexity leaks into the single-job majority's UI | Keep Earnings' default view single-job-shaped; multi-job users opt into a breakdown, they don't force one on everyone (see §11). |

---

## 11. Features to Delay to Later Phases

Cross-checked against Feature_List.md's existing version tiers — this plan doesn't
invent a competing roadmap, it recommends where in the *build order* each already-listed
feature lands, and flags two places worth deliberately going slower than the version
tier alone would suggest:

| Feature | Feature_List tier | Recommendation |
|---|---|---|
| Multiple concurrent jobs (FR-PROF-2) | Implied 1.0-capable | **Defer the UI to 1.1** even though the data model can support it from the start. Validate the single-job flow first — most users have one job, and multi-job UI (rate switching, per-job filtering) adds real complexity to Calendar/Earnings that shouldn't gate a first ship. |
| Notifications (Core) | High, 1.0 | Treat as a **fast-follow within 1.0**, not a launch blocker. Schedule/leave/earnings clarity all work without push notifications on day one; shipping Calendar → Leave → Earnings first and notifications shortly after reduces what has to be right simultaneously at launch. |
| Full Reports suite (all "possible reports" listed in the brief) | Medium, 1.0 | Ship **3–4 reports first** (Monthly Hours, Income trend, Shift distribution, Leave taken — the ones directly backed by data the app will already have from Calendar/Leave/Earnings). Add Overtime, Longest Streak, Average Weekly Hours once the first set is validated — see §9's empty-state note for why this also isn't just a scope cut. |
| Custom, savable shift-pattern templates (beyond one active pattern) | Not explicit in Feature_List | Ship one pattern per job first (already core, FR-PAT-1/6 allow multiple patterns concurrently); a named/saved template *library* is a 1.1-shaped refinement. |
| Roster Import, Export Reports, Work Streak Tracker, Widgets | 1.1 | Correctly later — no change. The Dashboard's already-modular card widgets are a good foundation for a future widget surface (same visual language, smaller canvas) — worth noting now so nothing in Phase 1–6 accidentally makes that harder later. |
| Country Rules Engine, Shift Insights, Work-Life Balance Insights | 1.2 | Correctly later — depends on having a real base of Reports and Public Holiday data first. |
| Payroll Verification, Tax Estimates, AI Assistant | 2.0 | Correctly later — no change; these depend on Earnings being trustworthy first, which is the whole point of sequencing them last. |
| Cloud Backup, Multi-device Sync | TBD (already undecided per ARCHITECTURE.md) | No change — correctly deferred until a feature forces the decision. |

---

## 12. Phased Implementation Roadmap

Each phase lists its goal, what ships, and a concrete testing checkpoint — not just
"test it," but the specific question that phase's testing needs to answer.

| Phase | Goal | Ships | Testing checkpoint |
|---|---|---|---|
| **0 — done** | Foundation | Dashboard v1 (read-only, mock data), Material 3 theme, spacing/typography/color tokens. | *(complete)* |
| **1** | Calendar core | Month grid with color-coded day states, monthly summary bar, month navigation, day bottom sheet (**view-only** — no editing yet, deliberately mirroring how Dashboard shipped read-only first). | Can a new user find today's shift and next week's schedule in under 10 seconds, unprompted? |
| **2** | Calendar becomes writable | Add/Edit/Delete shift, Shift Pattern Generator wizard. First phase where the app stops being read-only anywhere. | No overlapping shifts created (BR-2); pattern-generated shifts remain independently editable without altering the pattern (BR-9); one-handed usability of the edit form. |
| **3** | Leave | Leave tab, three balances, request/record flow, Public Holiday list, Calendar↔Leave cross-linking (§2.4) live for the first time. | Balance math correct under BR-1/BR-3/BR-4/BR-6 (never silently negative); tapping a leave day on Calendar correctly opens the matching Leave record. |
| **4** | Earnings | Pay rate setup, Earnings tab goes from placeholder to real, per-shift breakdown, Calendar day sheet gains "estimated pay" row. | Earnings estimate matches a manual calculation for a known set of shifts/rates; the *estimate* label (BR-5) is visually present on every figure, not just some. |
| **5** | Reports (in More) | First 3–4 reports (§11), Reports promoted to top of the More tab. | Charts don't look broken with only 1–2 weeks of real data (the actual state most launch users will be in). |
| **6** | Notifications & Settings | Shift reminders, break alerts, public holiday notices; Settings becomes fully real (theme, region/currency, first day of week, notification preferences, accessibility). | Notifications respect quiet hours (BR-8) and OS-level permission state without appearing to have failed silently. |
| **7 (1.1)** | Depth | Roster Import, Export Reports, Work Streak Tracker, first Widget exploration. | Widget surface reuses existing card visual language without a second design pass. |
| **8 (1.2)** | Regional depth | Country Rules Engine, Shift Insights, Work-Life Balance Insights. | Insights degrade gracefully (or hide) for regions/users without enough history yet. |
| **9 (2.0)** | Trust layer | Payroll Verification, Tax Estimates, AI Assistant. | Payroll Verification's discrepancy flags are conservative — false "you were underpaid" alerts are far worse than a missed one, per VISION.md's "accuracy is non-negotiable." |

---

## Out of Scope, By Design

Per the brief's own constraints: no Flutter code, no database/schema design, no
Firebase/Supabase/API/backend discussion. This document stops at the boundary of
*what the product does and how it's organized* — ARCHITECTURE.md and future decision
records own everything below that line.
