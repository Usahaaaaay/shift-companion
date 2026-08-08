# Shift Companion — Design System

*This document is the single source of truth for how every screen looks, spaces itself,
moves, and speaks. Where [UI_UX_Principles.md](UI_UX_Principles.md) says **why** the app
should feel calm, fast, and trustworthy, and [UX_Design_Plan.md](UX_Design_Plan.md) says
**where** that shows up (which screen, which tab), this document says **exactly what to
use** — token values, component specs, states, and copy rules — so two different screens
built months apart still look like the same product.*

*This document doesn't invent a system from scratch. Shift Companion already has a real,
working token set — `AppSpacing`, `AppColors`, `AppTypography`, `AppTheme`,
`AppConstants` — and a shipped Dashboard that already embodies most of the patterns
below. This document names those patterns, extends them for screens that don't exist
yet (Calendar, Leave, Earnings, Settings), and flags the few places where the existing
code has a gap worth closing. Where it recommends a new token, that's called out
explicitly as a recommendation for the next code change — this document specifies the
system; it doesn't implement it.*

*Related documents: [VISION.md](VISION.md) (the product principles this system serves),
[UI_UX_Principles.md](UI_UX_Principles.md) (the philosophy this system makes concrete),
[UX_Design_Plan.md](UX_Design_Plan.md) (navigation, screens, and the Calendar flow this
system's components will be built into), [Feature_List.md](Feature_List.md) (priority
and timing for the features referenced under §17).*

---

## 1. Design Philosophy

Shift Companion should feel like a **calm professional tool a shift worker trusts with
their income and their time off** — closer in spirit to a well-made banking app than a
lifestyle app. Concretely, that means:

| Feel like | Don't feel like |
|---|---|
| Professional, reliable, quietly confident | Playful, gamified, novelty-driven |
| Calm — one thing emphasized at a time | Busy — everything competing for attention |
| Fast — answers before the user finishes asking | Fast to *look* modern, slow to actually use |
| Friendly in copy, restrained in decoration | Cute in copy, decorated for its own sake |
| Consistent, so it fades into the background over years of daily use | Novel every release, forcing users to relearn it |

**The test for every visual decision in this document: does it help the user answer
"what does my day look like" faster, or does it just look nice?** If a gradient, an
extra color, or a flourish doesn't clarify information, it doesn't ship — this is
UI_UX_Principles §3's "every element earns its place," applied at the token level, not
just the screen level.

---

## 2. Design Principles

These are the lens every component spec in this document was designed through — and the
lens every *future* component should be designed through too.

- **One glance, one tap, one purpose.** Every screen has one primary thing it's for.
  Every card has one purpose (UI_UX_Principles §8). Every primary action is unambiguous
  (§9). If a screen needs a second glance to know what it's for, split it.
- **Information before decoration.** Typography weight, size, and color communicate
  hierarchy. Ornamentation (icons, dividers, shadows) supports that hierarchy or it
  doesn't appear. This is why Shift Companion uses **tonal elevation, not drop shadows**
  (§7) — color already carries the elevation meaning.
- **Consistency over creativity.** A new screen's first move is to find the closest
  existing pattern in this document and reuse it — not invent a fresh one. Novelty is a
  cost here, not a feature (UI_UX_Principles §17: "shared patterns are reused, not
  reinvented").
- **Reduce cognitive load.** Fewer colors, fewer type sizes, fewer button styles — not
  because variety is wrong in principle, but because every additional pattern is
  something the user (and every future contributor) has to learn and remember.
- **Make frequent actions effortless.** The actions a user does daily (glance at today's
  shift, check hours this week) get zero-tap or one-tap paths. Rare actions (editing a
  pay rate, exporting data) can cost more taps — effort should be proportional to
  frequency, not evenly distributed.
- **Design for one-handed use.** Primary content and primary actions sit in the
  comfortable thumb zone (roughly the lower two-thirds of the screen). This is why
  navigation is bottom-anchored and why forms should never require reaching the top of a
  tall screen to submit.
- **Accessibility by default, not as a retrofit.** Every component spec below already
  bakes in contrast, touch-target size, and screen-reader labeling — see §12. There is no
  separate "accessible version" of a component.
- **Progressive disclosure for advanced features.** Multi-job support, pay-rate
  breakdowns, detailed statistics — all real, all eventually needed, none shown by
  default. See §17 for how this system already has room for them.

---

## 3. Color System

### 3.1 How color is generated

The app already builds its entire palette from one seed color via Material 3's
`ColorScheme.fromSeed` (`AppColors.seed = #2E5AAC`, a calm, trustworthy blue — see
`core/theme/app_theme.dart`). This is the correct mechanism and should stay the
mechanism for everything **except** shift-type colors (§3.4) — one seed, one algorithm,
light and dark mode both derived automatically, full contrast guarantees built in. Never
hand-pick a `Color` for primary/secondary/surface roles; always reach for
`Theme.of(context).colorScheme`.

### 3.2 Semantic roles

| Requested role | Maps to | Notes |
|---|---|---|
| **Primary** | `colorScheme.primary` | The app's one confident accent (UI_UX_Principles §5). Used for the single primary action per screen, active nav state, links. |
| **Secondary** | `colorScheme.secondary` / `secondaryContainer` | Lower-emphasis accent — used today for MotivationCard's tint. Reserve for quiet, non-primary emphasis. |
| **Accent** | *Not a separate token.* Accent **is** Primary. | Introducing a fourth "accent" color would directly break the "one confident accent" rule already established. If a design seems to need a second accent, that's a sign the layout needs restructuring, not a new color. |
| **Success** | `AppColors.success` (`#2E7D4F`) | Positive confirmation — a shift confirmed, a save completed. |
| **Warning** | `AppColors.warning` (`#B07A15`) | Needs attention but isn't broken — a leave balance running low. |
| **Error** | `colorScheme.error` (M3-generated) | System/validation errors only — a failed form field, an exception surfaced to the user. |
| **"Critical"** *(app-domain, distinct from Error)* | `AppColors.critical` (`#B3261E`) | Already deliberately separated from `colorScheme.error` in the existing code (`app_colors.dart`'s own doc comment: "distinct from Material's `error` role, which is reserved for validation/system errors"). Use for domain-level critical states — e.g. a shift conflict — never for form validation, which stays on `colorScheme.error`. Keep this distinction; collapsing it back into one color would lose real meaning. |
| **Information** | `AppColors.info` (`#3A6EA5`) | Neutral, non-urgent informational messaging. |
| **Surface** | `colorScheme.surface` and the tonal ladder (`surfaceContainerLowest` → `surfaceContainerHighest`) | See §3.3. |
| **Background** | *Not a separate role.* | Material 3 deprecated a distinct `background`/`onBackground` pair in favor of `surface` — the app already reflects this (`scaffoldBackgroundColor: colorScheme.surface`). Don't reintroduce a separate background color. |
| **Divider / Outline** | `colorScheme.outlineVariant` (hairline/quiet) and `colorScheme.outline` (stronger, rare) | Prefer spacing over dividers wherever possible (§8's "quiet separation" — the current Dashboard has zero dividers by design). Reach for `outlineVariant` first. |
| **Disabled** | `onSurface` at 38% opacity (content), 12% opacity (container fill) | Standard M3 convention — Flutter's theme-driven widgets apply this automatically when disabled via `onPressed: null`; never hand-code a separate "grey" for disabled state. |
| **Text — Primary** | `colorScheme.onSurface` | Default body/heading text. |
| **Text — Secondary** | `colorScheme.onSurfaceVariant` | Muted text — dates, captions, helper text. Already used throughout the Dashboard (e.g. `GreetingHeader`'s date line, `QuickStatTile`'s caption). |
| **Text — Tertiary** | `colorScheme.onSurfaceVariant` at ~70% opacity | The least-emphasized tier — inline icons, disabled-adjacent hints. Deliberately an opacity step of Secondary rather than a fourth hardcoded color, so it inherits contrast-correctness automatically instead of needing separate light/dark tuning. Already the pattern used for icon tinting across the current Dashboard (`.withValues(alpha: 0.5–0.7)`). |

### 3.3 The surface ladder (already in use, now named explicitly)

M3's tonal surface steps are what the shipped Dashboard already uses to express
hierarchy without shadows. Naming them here so future screens use the same three tiers
deliberately, not by trial and error:

| Tier | Token | Current use | Use for |
|---|---|---|---|
| **Hero** | `colorScheme.primaryContainer` | `TodayShiftCard` | The one most-important surface per screen. Maximum one per screen. |
| **Standard** | `colorScheme.surfaceContainerHighest` (the app's default `CardThemeData` color) | Default `Card` | Ordinary cards — most content. |
| **Light** | `colorScheme.surfaceContainerLow` | `QuickStatTile` | Secondary, lower-emphasis groupings — content that should visually recede next to a Hero or Standard card on the same screen. |
| **Plain** | No fill — page background shows through | `UpcomingShiftCard` | Content that should feel like part of the page, not a boxed unit. Use when a section is explicitly "secondary" to a Hero card above it. |

### 3.4 Shift-type colors — a deliberate, bounded exception

UI_UX_Principles §5 commits the app to a neutral base with **one** accent. Nine
shift/day states is a real exception, scoped narrowly on purpose: **these colors mean
exactly one thing — the state of a day — and appear only on the Calendar, and anywhere
else a specific day is referenced (Dashboard, Leave). They are never reused
decoratively.**

**Two things worth pushing back on in the brief's own example set, before locking in
values:**

1. Using **red for Leave** sends the wrong signal on its own terms, independent of
   accessibility — red means "problem" everywhere else in this system (`error`,
   `critical`). Leave is *good news*. Reusing red for it would teach users the color
   means two contradictory things depending on context.
2. **Green for Morning next to red for Leave** is the single hardest color pairing for
   the most common form of color blindness (deuteranopia/protanopia, ~8% of men) to
   tell apart — already flagged in UX_Design_Plan.md §8.2, resolved for real below by
   not using that pairing at all.

**Mitigation used throughout:** every hue below is chosen to differ in **lightness and
saturation**, not hue alone — the actual technique that keeps a palette usable under
color-vision deficiency, since CVD primarily degrades hue discrimination while
lightness perception stays largely intact. And per UI_UX_Principles §15 (already
established, reinforced here): **every calendar indicator pairs its color with a shape,
icon, or label — color is never the only signal**, covered fully in §9.

| State | Light | Dark | Why this color |
|---|---|---|---|
| **Morning** | `#D9A441` | `#F0C36B` | Muted gold — sunrise association, warm without colliding with Warning's more olive amber (`#B07A15`) when the two ever appear near each other. |
| **Afternoon** | `#C46B2E` | `#E38A4F` | Burnt orange — clearly warmer/deeper than Morning, distinct hue angle from both Morning and Critical's red. |
| **Night** | `#3F3D74` | `#8482C4` | Deep indigo — night-sky association, deliberately darker/more violet than the app's own primary/info blues so it doesn't get mistaken for "brand blue." |
| **Split Shift** | *No dedicated fill* | | Rendered as a two-color composite of the actual segments involved (e.g. a diagonal half-Morning/half-Afternoon fill) — see §9.4. A cell literally shows *why* it's split instead of asking the user to memorize a seventh arbitrary color. |
| **Leave** | `#9C4F7A` | `#D08FB4` | Muted plum — positive and calm, nowhere near red, nowhere near green. |
| **Day Off** | Neutral: `colorScheme.surfaceContainerHighest` fill + `colorScheme.outline` dot | | Deliberately the quietest mark on the calendar — a day off is an absence of a working state, not a category competing with the six colored ones. See §9.5 for why this must look different from "no data yet." |
| **Holiday** *(public holiday)* | `#2F8E82` | `#5FC2B5` | Teal — calm and distinct from Leave's plum, so "the calendar marked this day" (Holiday, a fact) reads differently from "I booked this day" (Leave, a choice). |
| **Training** | `#8A6D3B` | `#C7A968` | Muted bronze — work-related but visually distinct from both Success-green and the Morning/Afternoon warm family, so it doesn't get misread as a normal shift. |
| **Overtime** *(future)* | Reuses `AppColors.warning` | | **Not a fill color at all.** Overtime is additive information about an existing shift (a Morning shift that ran long is still a Morning shift), not a mutually exclusive state — see §9.6. Rendered as a small corner badge, reusing Warning's existing meaning ("worth your attention"). |

**Implementation note (Phase 2.2):** the table above was written ahead of any shift-color
code existing. What actually shipped in Phase 2.2 is a deliberately smaller, six-state
model — Morning/Afternoon/Night/Off/Leave/Public Holiday, no Split Shift, Holiday
(renamed to match the shipped `ShiftType.publicHoliday`), Training, or Overtime yet —
using a different, simpler palette chosen directly for that phase (Green/Blue/Purple/
Grey/Amber/Orange) rather than the gold/orange/indigo/plum/teal/bronze set above. Both
choices avoid a red/green pairing and the specific Leave-shouldn't-be-red critique this
section raised, so the accessibility reasoning above still holds; the exact hues just
differ from what's documented here. See `lib/features/calendar/presentation/shift_colors.dart`
for the real, current values and their rationale. This table is left as-is (rather than
rewritten to match) so the original reasoning — including where Split Shift, Training,
and Overtime should eventually go — isn't lost; treat the code as the source of truth for
"what color is Morning today," and this table as the source of truth for "what's still
unbuilt and why."

**Recommended token addition** (superseded by the above for now): a `ShiftColors` set
alongside `AppColors`, holding the six light/dark pairs above, plus a `radiusFull`
addition to `AppSpacing` for true pill shapes (§6). Phase 2.2 implemented `ShiftColors`
as a Calendar-feature-scoped file instead of a `core/constants/` addition — see that
file's own header comment for why (it depends on the Calendar-scoped `ShiftType`
entity, and `core/` can't import from `features/`) — promote it to `core/constants/`
once a second feature needs the same colors, per this document's own "promote on a real
second use" rule (§ applied already to `core/utils/` and `core/widgets/`).

**Known gap worth closing, unrelated to the new colors above:** `AppColors.success`,
`warning`, `critical`, and `info` are currently flat hex values reused identically in
light and dark mode (confirmed by reading `today_shift_card.dart`'s `AppColors.success`
usage) — this is a small, pre-existing gap against UI_UX_Principles §16 ("every status
color is verified in both modes"). Not addressed here since it's outside this task's
scope, but it should be closed the same way the new shift colors were designed above
(light/dark pair per semantic color) as a near-term follow-up, before those colors get
much more reuse across new screens.

---

## 4. Typography

### 4.1 Font family

**Roboto**, via `Typography.material2021(platform: TargetPlatform.android)` — already
the case in `AppTypography.textTheme`. This is a deliberate choice, not a default left
unexamined: forcing Android's type metrics on every platform gives the app **one
consistent typographic identity** across iOS and Android, rather than iOS getting San
Francisco and Android getting Roboto and the two feeling like different apps. Roboto is
also simply very legible at small sizes, which matters directly for "legible at a
glance" (VISION.md §9). No custom font asset is bundled — keep it that way unless a
real branding decision forces it (per ARCHITECTURE.md's "decide when forced" rule); this
would be a decision record, not a quiet addition.

### 4.2 Type scale

The Material 3 default scale, already provided free by `AppTypography.textTheme`. What's
new here is mapping each role to where it's actually used in this app:

| Style | Size / line height | Weight | Use in Shift Companion |
|---|---|---|---|
| `displaySmall` | 36/44 | Regular | Reserved — not yet used; a candidate for a future watch-face or widget surface (§17), not phone screens. |
| `headlineMedium` | 28/36 | **700** (bolded on top of default) | Screen-defining headline text — `GreetingHeader`'s greeting line is the current example. Use once per screen, at most. |
| `headlineSmall` | 24/32 | 700–800 | Secondary hero numbers — `UpcomingShiftCard`'s time range, `QuickStatTile`'s hero figure. |
| `titleLarge` | 22/28 | 700 | Reserved for full-screen dialog/sheet titles once those exist (Leave Request, Pattern Generator). |
| `titleMedium` | 16/24 | 600 | Section headers within a screen — "Quick Actions," "Upcoming Shift" card titles, card-level titles generally. |
| `titleSmall` | 14/20 | 600 | Card subtitles, list-item titles. |
| `bodyLarge` | 16/24 | 400–500 | Primary reading text — `MotivationCard`'s message. |
| `bodyMedium` | 14/20 | 400 | Default body text, secondary descriptive lines. |
| `bodySmall` | 12/16 | 400 | Captions — `QuickStatTile`'s caption line, notes. |
| `labelLarge` | 14/20 | 600 | Button labels, tile labels (`QuickActionsSection`). |
| `labelMedium` | 12/16 | 600–700 | Status badges, small tags. |
| `labelSmall` | 11/16 | 700, `letterSpacing: 1.5–2` | Eyebrow labels — "TODAY," "UPCOMING SHIFT." Always uppercase, always letter-spaced, never used for anything else — keep this pairing exclusive so it stays recognizable as "this is a section eyebrow" wherever it appears. |
| **Glanceable numeral** | 40, weight 700, tabular figures | — | `AppTypography.glanceableNumeral` — the app's dedicated style for the single most time-pressured figure on a screen: shift times, and going forward, Calendar's monthly-summary hours and Earnings' hero figure (see UX_Design_Plan.md §8.3 — this is where that intention gets followed through, not just Dashboard). Never use for anything that isn't the literal answer to "what do I need to know right now." |

**Rule:** every screen picks **at most one** `headlineMedium`/`headlineSmall` moment and
**at most one** `glanceableNumeral` moment. Both exist to draw the eye immediately —
using either twice on one screen cancels the effect for both.

---

## 5. Spacing System

### 5.1 The scale

Already defined in `AppSpacing` and correct as-is — a 4/8pt hybrid grid, which is
standard practice for 8dp systems generally (Material's own spacing guidance uses 4dp as
the "half step" within an 8dp rhythm, not a departure from it):

| Token | Value | Use |
|---|---|---|
| `xs` | 4 | Tight gaps — icon to its adjacent label. |
| `sm` | 8 | Default gap between related items within a group. |
| `md` | 16 | Default card padding; the app's most common spacing value. |
| `lg` | 24 | Separation between major sections on a screen. |
| `xl` | 32 | Screen-level outer padding; generous breathing room around the most important content. |
| `xxl` | 48 | Rare, deliberate emphasis — e.g. extra space under the Dashboard's greeting. |

### 5.2 Applied

| Context | Spacing |
|---|---|
| Screen margins (outer padding) | `xl` (32) |
| Card internal padding — Hero tier | `xl` (32) |
| Card internal padding — Standard/Light tier | `md` (16) |
| Inter-section spacing (screen body) | `xl` (32) |
| List item vertical spacing | `sm`–`md` (8–16), spacing-only, no dividers by default (§3.2) |
| Grid spacing (Quick Stats, Quick Actions, Calendar) | `md` (16) between cells/tiles |
| Bottom sheet content padding | `lg` (24), with `md` between individual fields |
| Dialog content padding | `lg` (24) |

**Why this matters more than it looks like it should:** a spacing system's entire value
is that a contributor never has to *decide* what padding to use — they look up what kind
of gap it is (tight/related/grouped/sectioned/screen-level) and the number is already
chosen. The moment one screen uses `20` because it "looked better," every future screen
built next to it has silently lost that guarantee.

---

## 6. Corner Radius

| Category | Token | Value | Use |
|---|---|---|---|
| **Small** | `radiusSm` | 8 | Compact elements — small tags, input field corners, calendar cell corners. |
| **Medium** | `radiusMd` | 16 | Default — most cards, buttons, dialogs, Quick Action tiles. |
| **Large** | `radiusLg` | 24 | Prominent, full-width surfaces — the Hero card, bottom sheet top corners. |
| **Full / Pill** *(recommended addition)* | `radiusFull` | Stadium (radius = height ÷ 2) | Status badges, filter chips, the search bar, an extended FAB. |

**Why "Full" needs its own token, not a reuse of `radiusLg`:** `StatusBadge` currently
achieves a pill shape by coincidence — its fixed padding happens to produce a container
short enough that `radiusLg` (24) exceeds half its height. That's fragile: if the
badge's padding ever changes, it silently stops being a true pill. A `radiusFull` token
(Flutter's `StadiumBorder`, or `BorderRadius.circular(999)`) guarantees a pill at any
height and should replace the coincidental `radiusLg` usage on `StatusBadge` the next
time that file is touched.

---

## 7. Elevation

Shift Companion is already committed to **tonal elevation over drop shadows**
(`CardThemeData(elevation: 0)`, `AppBarTheme(elevation: 0)` — confirmed in
`core/theme/app_theme.dart`) — this is correct and should stay the default for anything
that sits flat on the page. Elevation, in this system, is primarily a **color** decision
(§3.3's surface ladder), not a shadow decision.

Real elevation (actual Material shadow/z-depth) is reserved for surfaces that genuinely
float *above* unrelated content, not surfaces that sit *within* the page flow:

| Level | Mechanism | Use |
|---|---|---|
| **Flat** | `elevation: 0`, surface-tier color only | Default page content — everything on Dashboard today, Calendar's grid. |
| **Card** | `elevation: 0`, tonal fill (§3.3) | Any `Card` — the existing default. |
| **Floating** *(FAB)* | Real M3 elevation (small) | The Calendar's Pattern-Generator entry point, if implemented as a FAB — the one control that should visually detach from the page. |
| **Bottom Sheet** | Real elevation + scrim | Genuinely overlays unrelated content below it and dims it — matches M3's own convention of giving sheets real elevation even in an otherwise-flat system. |
| **Dialog** | Real elevation + scrim | Same reasoning as Bottom Sheet — modal, blocking, dims the page behind it. |

**Rule of thumb:** if dismissing it returns you to exactly where you were with nothing
changed underneath, it's a Bottom Sheet or Dialog and gets real elevation. If it's just
part of scrolling the page, it's Flat/Card and gets a tonal fill.

---

## 8. Component Library

Each entry: purpose, visual style, states, when to use, when not to.

### 8.1 Buttons

Four tiers, one destructive variant:

| Tier | Style | Use | Don't use for |
|---|---|---|---|
| **Primary** | `FilledButton` | The one primary action on a screen — "Save," "Confirm Leave Request." Maximum one visible at a time (UI_UX_Principles §9). | A second action on the same screen — demote it to Secondary instead. |
| **Secondary** | `FilledButton.tonal` or `OutlinedButton` | A real but non-primary action — "Cancel" next to a Primary "Save." | Anything that should draw the eye first. |
| **Tertiary / Text** | `TextButton` | Low-emphasis actions — "Skip," "Not now." | Anything destructive or anything that's actually the main point of the screen. |
| **Destructive** | `FilledButton`/`TextButton` styled with `colorScheme.error` | Delete actions, always behind a confirmation Dialog (§8.9), never positioned where an accidental tap is likely (UI_UX_Principles §9). | Anything reversible — use Secondary instead and let an undo/snackbar handle it if one exists. |
| **Icon Button** | `IconButton`, 24dp icon, ≥48dp tap target | App-bar actions, list-item trailing actions. | A primary action — icon-only primary actions are hard to discover; pair with a label. |

**Navigation tile** *(a distinct, non-button component)*: the icon-in-a-soft-circle +
label pattern already built for `QuickActionsSection`. This is specifically for
peer-level navigation shortcuts, not a general button style — don't reach for it as a
substitute for Primary/Secondary buttons inside a form.

### 8.2 Cards

Covered fully in §3.3 (the four-tier surface ladder). One rule worth restating here:
**a screen has at most one Hero card.** Two Hero-tier cards on the same screen cancel
each other's purpose.

### 8.3 Chips

Distinct from Status Badges (§8.4): chips are **interactive** — filters, selections,
tags. Material 3's `FilterChip`/`ChoiceChip`, `radiusSm` or `radiusFull` depending on
density. Use for: Calendar's shift-type filter row, future multi-job tagging. States:
default / selected (filled, `primaryContainer`) / disabled.

### 8.4 Badges (Status Badge)

The existing `StatusBadge` component — pill-shaped (moving to `radiusFull`, §6), tinted
background at 16% color alpha, icon + label, a one-shot pop-in animation
(`easeOutBack`, 300ms). **Read-only, never tappable.** Use for: shift status
("Working Now," "Upcoming"), and going forward, leave-request status ("Pending,"
"Approved"). Don't use for anything the user can interact with — that's a Chip.

### 8.5 Text Fields

Not yet built anywhere in the app (fully read-only so far) — specifying the standard
now, ahead of Leave Request and Shift editing: **M3 outlined text fields**, `radiusSm`
corners, floating label, inline validation shown next to the field as the user types,
never only after submission (UI_UX_Principles §10). Error state uses `colorScheme.error`
for the border and helper text — never color alone; the helper text itself must state
the problem in plain language (§13).

### 8.6 Search Bar

M3's pill-shaped `SearchBar`/`SearchAnchor` pattern, `radiusFull`. Use for Calendar's
search/filter entry point (FR-CAL-7) — a single global search bar, not a per-tab one,
so the user never has to remember which screen search "lives on."

### 8.7 Bottom Navigation

M3 `NavigationBar` (not the older `BottomNavigationBar`) with the five destinations from
UX_Design_Plan.md §2.2. Active tab: rounded-filled icon + always-visible label.
Inactive tabs: outlined icon + always-visible label (labels stay visible on inactive
tabs too — hiding them on tap would violate "always know where you are,"
UI_UX_Principles §4).

### 8.8 App Bar

Used on every screen **except** Dashboard, which deliberately has none (see
`greeting_header.dart`'s own doc comment: the landing tab needs no back-navigation
chrome). Elsewhere: `elevation: 0`, `surface`-colored, screen title in `titleLarge`,
contextual actions (search, filter, add) as trailing icon buttons — never more than two,
per "respect the user's attention" (VISION.md §8).

### 8.9 Bottom Sheet

The Calendar day-detail flow's core component (UX_Design_Plan.md §6). Spec: `radiusLg`
top corners only, a small drag handle, scrim behind, content padding `lg`, primary
action row pinned to the bottom. Dismiss via swipe-down or scrim tap — no separate close
button needed for a view-only sheet.

### 8.10 Dialogs

Reserved for genuinely blocking, hard-to-reverse confirmations only (UI_UX_Principles
§2: "confirmation prompts reserved for genuinely destructive actions") — deleting a
shift, deleting a leave request. `radiusMd`, real elevation + scrim (§7). The
confirm button is always the Destructive button style (§8.1) when the action is
destructive — never a Primary-styled button for a delete action, so the two never look
interchangeable.

### 8.11 Calendar Cell

Spec'd fully in §9 — the deepest component in this system.

### 8.12 Statistics Card

The existing `QuickStatTile` pattern, generalized: subtle icon, large bold hero figure,
small muted caption underneath. Use anywhere a single number is the point — Reports
screen, Earnings summary tiles. Don't use for anything that isn't fundamentally "one
number, glanceable."

### 8.13 Progress Indicator

Not yet built. Two distinct uses:
- **Loading** — M3 linear/circular indeterminate indicator, reserved for short,
  layout-unknown waits (rare — prefer a Skeleton, §8.16, wherever the eventual layout is
  known).
- **Balance/entitlement progress** — a determinate linear bar (e.g., "8 of 25 annual
  leave days used") on the Leave screen. Fill color: `colorScheme.primary` under 80%
  used, `AppColors.warning` above that threshold, paired with the actual numbers as text
  (never a bar alone — the number is the real information; the bar is the glance).

### 8.14 List Items

Not yet built — needed for Leave history, Reports lists, future Notification history.
Standard pattern: leading icon, title (`titleSmall`), optional subtitle
(`bodySmall`, muted), trailing value or chevron, minimum 56dp row height. Separation by
spacing, not dividers, consistent with the rest of the app (§3.2) — reach for
`outlineVariant` dividers only if a list gets dense enough that spacing alone stops
reading as separate rows.

### 8.15 Empty States

Per UI_UX_Principles §12. Spec: centered content, generous padding (`xl` all sides), a
muted icon (not an illustration library — stay consistent with the app's existing icon
language, §11), a primary message (`titleMedium`), an optional secondary explanatory
line (`bodyMedium`, muted), and — wherever there's a real next step — a Secondary button
pointing at it. Tone: encouraging, never clinical ("No shifts yet — add your first one
to get started," not "No data").

### 8.16 Loading States

Per UI_UX_Principles §13. **Skeletons are the default** for anything with a known
eventual layout (a card that will contain a shift, a list that will contain history
entries) — a spinner is the fallback only when the layout genuinely isn't known yet
(rare; roughly limited to first app launch). Near-instant loads (well under a second)
show nothing at all — a flash of a loading state is worse than no loading state.

### 8.17 Error States

Per UI_UX_Principles §14. Icon + plain-language message + a concrete next step (retry,
go back, contact support) — never a raw exception string, never a bare "Something went
wrong." Calm visual treatment matching the rest of the app; reserve any stronger
visual weight for genuinely urgent errors (a data conflict) versus routine,
auto-retrying ones (a failed sync).

### 8.18 Skeleton Loaders

Subtle, **not** a generic grey shimmer — use the app's own tonal surface steps
(`surfaceContainerHighest` pulsing toward `surfaceContainerHigh`), so a skeleton reads as
"this app, loading" rather than a borrowed off-the-shelf effect, and stays correct in
dark mode without a separate skin. Shape the placeholder blocks to match the eventual
content's actual layout (a rounded rectangle where the Hero card's times will render),
not generic bars.

---

## 9. Calendar Component Standards

The Calendar is where color-coding *is* the interface — this section exists to make
sure "understand your month in under three seconds" (per the brief) survives contact
with real edge cases: today, selection, multiple flags on one day, small phones, and
screen readers.

### 9.1 Cell sizing

A 7-column grid means each cell has limited width on any phone (~360dp screen ÷ 7 ≈
48–50dp before margins). This is **narrower than `AppConstants.minTouchTarget` (48dp)**
once grid spacing is subtracted — a deliberate, documented exception, common across
essentially every calendar UI for this exact reason. Mitigation: the **effective tap
target extends into the cell's surrounding gutter** via a full-bleed `InkWell`/gesture
region covering the whole grid square including inter-cell spacing, not just the visible
dot/number — so the *reliable* hit area stays close to the 48dp guideline even though
the *visible* cell is smaller. The result of a tap is a forgiving bottom sheet, not a
precise inline edit, which also reduces the cost of an imprecise tap.

### 9.2 Today state

A **2dp `colorScheme.primary` ring**, drawn slightly outside the cell's normal bounds —
never a fill. This is deliberate: a fill would compete with and override the day's
actual shift-state color, and Today needs to be able to coexist with every other state
(a Morning shift that's also today still needs to read as "Morning" first).

### 9.3 Selected state

A `primaryContainer`-tinted fill behind the cell, with a subtle scale-up
(`animationFast`, §10). Must remain visually distinguishable from Today's ring-only
treatment when both apply to the same cell simultaneously (a very common case — opening
the app and tapping today's own cell) — ring and fill are different enough mechanisms
that this combination was designed to not be confused for a single, unclear state.

### 9.4 Shift indicators & Split Shift

One **primary fill color** per cell (§3.4's six/nine states), mutually exclusive. Split
Shift is the one exception, rendered as a **diagonal or half/half composite** of the two
actual segment colors involved (e.g., Morning + Afternoon) — see §3.4's reasoning for
why this beats a seventh arbitrary color.

### 9.5 Multiple events & flags — the extensibility mechanism

A day can carry facts beyond its primary state — worked on a public holiday, ran into
overtime, a shift swap pending confirmation. Rather than trying to blend or stack fill
colors (which would muddy the color and break the accessibility reasoning in §3.4), this
system uses **one primary fill + up to two small corner/edge indicator marks** for
everything else:

- Worked on a Holiday → small teal corner mark (Holiday's color, §3.4) layered on the
  shift's own primary fill.
- Overtime → small Warning-colored corner badge (§3.4's Overtime entry).
- Future flags (swap pending, multi-job) → the same mechanism, new corner marks, **no
  redesign of the cell itself required** — this is the concrete answer to "future
  features should naturally extend from the Calendar rather than replacing it."

For a day with genuinely two separate shift entries (future multi-job support): thin
stacked color bars along the cell's bottom edge, not a blended fill — kept out of v1
scope but designed for now so it doesn't force a rework later.

### 9.6 Day Off vs. "no data yet"

Two different facts that must look different: **Day Off** (a deliberate, known rest day)
uses a neutral solid fill + outline dot (§3.4). **No data yet** (a future date beyond
the roster's generated horizon) stays fully undyed — closer to the plain background than
to Day Off's neutral fill — so it reads as "nothing here yet," not "confirmed day off."

### 9.7 Weekend styling

**Not** color-coded. Weekend columns get a subtly muted header treatment (day-of-week
label in `onSurfaceVariant` instead of full `onSurface`) — the day-number and shift fill
underneath stay identical in treatment to a weekday. Coloring weekends themselves would
give the color channel a second, competing meaning (day-of-week vs. shift-state),
undermining the "color means exactly one thing" rule in §3.4.

### 9.8 Holiday styling

A public holiday is indicated the same way as any other flag (§9.5) — a small teal
corner mark — **not** a full-cell fill, since the day's *actual* shift state (working,
day off, on leave) is still the more important fact for "what does my day look like."

### 9.9 Accessibility

- **Full semantic label per cell**, combining date + primary state + any flags in one
  sentence (e.g., "Saturday, August 8th, Morning shift, 7 AM to 3 PM" or "Saturday,
  August 8th, day off") — never relying on a screen reader trying to parse a colored
  dot on its own.
- **Text scaling is capped inside the grid specifically.** Full dynamic type support
  (§12) applies everywhere else in the app, but 42 cells' worth of text scaling to 200%
  would overlap and become unreadable regardless of intent — a deliberate, documented
  exception. The bottom sheet (§8.9), which *does* scale freely, is where full detail
  and full text size live; the grid stays a stable, glanceable overview.
- Every corner/edge flag (§9.5) must be paired with its own accessible description in
  the cell's semantic label, not conveyed by shape alone.

### 9.10 Animation behavior

- **Cell tap:** quick scale-down (~0.95, `animationFast`, 150ms) + ripple — matches the
  press feedback already established elsewhere (§10).
- **Month swipe:** horizontal slide, `animationStandard` (250ms), `easeOutCubic` — the
  same curve already used for the Dashboard's entrance animation, kept consistent.
- **Initial data load:** the **whole grid** fades in once (reusing the Dashboard's
  established one-shot fade pattern) — never cell-by-cell. A 42-cell staggered entrance
  would read as chaotic "confetti," directly against "NO flashy animations."

---

## 10. Motion System

### 10.1 Philosophy

Motion in Shift Companion **explains a state change; it never decorates.** Every
animation in this system answers "what just happened" (a section appeared, a value
changed, a sheet opened) — if an animation doesn't answer that question, it's cut. This
is already the standard the Dashboard's entrance animation was held to
(`_FadeSlideIn`'s doc comment: "purely a one-shot visual entrance... doesn't repeat")
and it applies everywhere motion gets added from here on.

### 10.2 Duration tokens (already defined, now mapped to every use)

| Token | Value | Use |
|---|---|---|
| `AppConstants.animationFast` | 150ms | Local, small transitions — button/tile press, calendar cell selection, badge state changes. |
| `AppConstants.animationStandard` | 250ms | The default — card entrances, bottom sheet open/close, month-swipe transitions, dialog appearance. |
| `AppConstants.animationSlow` | 350ms | Full-screen transitions only — entering a multi-step flow like the Pattern Generator. |

### 10.3 Curves

- **Entrances** (cards, sections appearing): `Curves.easeOutCubic` — already established
  by the Dashboard's `_FadeSlideIn`. Keep this as the one entrance curve app-wide.
- **Playful, attention-earning pop** (Status Badge only): `Curves.easeOutBack` — reserved
  specifically for this one component so it doesn't dilute into a second "default" feel.
- **Navigation transitions**: Flutter/Material's standard `fastOutSlowIn` — don't
  override the platform default here; consistency with the OS's own navigation feel
  matters more than a custom signature.

### 10.4 The one hard rule: honor reduced motion

Every animated component — not just entrances — must check
`MediaQuery.of(context).disableAnimations` and skip straight to the settled state when
it's set. The Dashboard already does this correctly for its entrance animation; every
new animated component (Calendar's month-swipe, sheet transitions, the balance progress
bar filling) must do the same. This isn't optional polish — it's UI_UX_Principles §15's
accessibility requirement made concrete.

### 10.5 No continuous/looping animation without a specific reason

`StatusBadge`'s one-shot pop-in (not a continuous pulse) is the model: a perpetual
animation keeps repainting for as long as it's on screen, which costs battery
(VISION.md's "reliable under real conditions" / NFR-6) for a purely decorative gain.
Any future request for a "live," continuously animating indicator should be weighed
against this cost explicitly, not added by default.

---

## 11. Iconography

**Material Icons** (already the app's icon source via `uses-material-design: true`, no
additional icon package). Keep it that way — introducing a second icon family is exactly
the kind of dependency ARCHITECTURE.md's "decide when forced" rule exists to prevent.

| Rule | Detail |
|---|---|
| **Outlined vs. rounded-filled** | Outlined for status/informational icons (department, location, time, calendar flags). Rounded-filled for primary actions and the active bottom-nav tab. This formalizes a rule already implicit in the shipped code and prevents drift as more screens get built by different contributors over time. |
| **Sizes** | 16 — inline with small labels/badges. 20 — default, body-adjacent (list items, detail rows). 24 — standard M3 default (app bar, nav icons). 28–32 — header/hero accents only (e.g. `GreetingHeader`'s time-of-day icon). |
| **Never mix families** | No custom SVG icon sets, no emoji-as-icon (the Dashboard redesign already replaced its emoji greeting icon with a Material icon for exactly this reason — see `greeting_header.dart`). Emoji remain acceptable only inside genuinely conversational copy (e.g. a motivational message), never as a UI icon standing in for meaning. |

---

## 12. Accessibility

Treated as a floor, not a stretch goal — every item below is a requirement, not a
suggestion, per VISION.md §9 ("accessible to everyone... not just the digitally
fluent") and Software_Requirements.md §10 (ACC-1 through ACC-6).

| Area | Standard |
|---|---|
| **Contrast** | WCAG AA minimum — 4.5:1 for normal text, 3:1 for large text and meaningful UI components. M3's tonal role pairs (`onPrimaryContainer` on `primaryContainer`, etc.) satisfy this automatically when used correctly; the six new shift colors (§3.4) need a manual check once implemented, specifically for their small corner-indicator marks against whatever fill they sit on. |
| **Color blindness** | Never the sole signal (§3.4, §9.9) — every colored state pairs with shape, icon, or text. |
| **Dynamic text sizing** | Full support everywhere via `Theme.of(context).textTheme`, with the one deliberate, documented exception at §9.9 (calendar grid text is capped; full detail lives in the bottom sheet instead). |
| **Screen readers** | Every non-decorative element gets a complete `Semantics` label — already the pattern in `StatusBadge`; extend it to every new component, especially Calendar cells (§9.9). |
| **Touch targets** | `AppConstants.minTouchTarget` (48dp) everywhere, with the calendar-grid exception at §9.1 (mitigated via extended gutter tap area, not a lowered standard). |
| **Focus indicators** | Keep Flutter's default Material focus highlight — don't strip it via custom theming, even though touch is the primary input; external keyboards and switch-access users depend on it. |
| **Keyboard navigation** | Mobile-first app, but text fields and dialogs must support standard OS tab/next-field behavior for external keyboards and accessibility switches — this comes for free from not overriding Flutter's defaults, so the main risk is a future custom widget accidentally breaking it. |
| **Motion sensitivity** | `MediaQuery.disableAnimations` honored by every animated component, not just entrances (§10.4). |

---

## 13. Responsive Behaviour

| Class | Approach |
|---|---|
| **Small phones** (~360×640 logical) | The baseline this system is designed against — every spacing/sizing value above already assumes this as the tightest case (see §9.1's calendar-cell math). |
| **Large phones** (~430×930 logical) | Layouts use flexible/fractional sizing already (grids with aspect ratios, not fixed pixel widths) — extra space is absorbed as more breathing room, not more columns or a different layout. |
| **Tablets** *(future, not built against yet)* | Not actively designed for now, but shouldn't be actively broken either: recommend a **max content width** (~600–680dp), centered, so text lines don't stretch edge-to-edge illegibly if the app is ever opened on a tablet before real tablet layouts exist. Bottom sheets becoming side sheets/dialogs on wide screens is a real future adaptation — flagged here as a known future decision, not designed now. |

---

## 14. Dark Mode

The mechanism is already correct and already in place: `ColorScheme.fromSeed(brightness:
...)` derives both modes from one seed, and `AppTheme.dark`/`AppTheme.light` share one
construction path (`_buildTheme`) so they can't structurally drift apart. Two rules for
everything new added under this system:

- **Never invert — always re-derive.** Every new color addition (the six shift colors,
  §3.4) gets its own considered light *and* dark value, following M3's own dark-mode
  convention (lighter, moderately desaturated tones against dark surfaces) — not a
  simple brightness flip of the light value.
- **Hierarchy survives the mode switch.** Whatever reads as most important in light mode
  (the Hero card, a badge's color) must still read as most important in dark mode —
  verified by eye, not assumed from the algorithm alone, since the six hand-picked shift
  colors in particular aren't algorithmically derived and need a real side-by-side check
  once implemented.

---

## 15. Microcopy

Friendly, clear, brief, human. No technical jargon, no manufactured urgency
(VISION.md §9: "no dark patterns, no manufactured urgency"). Concretely:

| Context | Avoid | Prefer |
|---|---|---|
| Empty state | "No data available." | "No shifts yet — add your first one to get started." |
| Confirmation dialog | "Are you sure you want to proceed with this destructive action?" | "Delete this shift? This can't be undone." |
| Error | "Error: null pointer exception" / "Something went wrong (Error 500)" | "We couldn't save that shift. Check your details and try again." |
| Success | "Operation completed successfully." | "Shift added." — brief, not over-celebratory (§1: calm, not cluttered). |
| Notification | "REMINDER: SHIFT STARTING SOON!!!" | "Your shift starts in 30 minutes." |

**One explicit voice rule:** exclamation marks are reserved for genuinely warm,
low-stakes moments (the existing motivational messages — "Have a great shift!" is
correct as-is). Errors, reminders, and confirmations stay calm and declarative — no
exclamation urgency, ever, per VISION.md's explicit rejection of manufactured urgency.

---

## 16. Haptics

Reserved for **meaningful state changes**, mirroring §10.1's motion philosophy exactly —
haptics communicate that something happened, they don't decorate a tap.

| Action | Feedback |
|---|---|
| Save / confirm (add a shift, confirm a leave request) | Light impact |
| Delete / destructive confirm | Medium impact — deliberately distinct from Save, so the two never feel the same under the thumb |
| Calendar day selection | Selection click (`HapticFeedback.selectionClick()`) — subtle, standard M3 pattern |
| Completing a multi-step flow (Pattern Generator finished) | Light–medium impact |
| Passive/navigational taps (switching bottom-nav tabs, opening a sheet) | **None** — haptics on every tap devalues them; reserve for the moments above only |

Always respect the OS-level haptics setting — if a user has disabled system haptics, the
app must not force them, the same principle already applied to reduced motion (§10.4).

---

## 17. Future Expansion

How this system already accommodates each item the brief names, and where it honestly
doesn't yet:

| Future feature | How this system supports it | Gap, if any |
|---|---|---|
| **Payroll / pay calculation** | The Hero-card pattern and the "estimate" labeling convention (already required by BR-5) extend directly — a confirmed-vs-estimated state is just Success vs. neutral tinting on an existing component. | None — this is close to a data change, not a design change. |
| **Multiple jobs** | The List Item component (§8.14) plus the corner-indicator mechanism already designed for Calendar (§9.5) extends naturally to "which job" tagging. | None structural — recommend deferring the *UI* to post-MVP regardless (see UX_Design_Plan.md §11), even though the system could support it sooner. |
| **AI assistant** | The microcopy voice (§15) already defines how it should *sound*. | **Real gap.** A conversational/chat UI is a genuinely new component category this system doesn't cover yet — honest limit, not pretended-away. Design it when 2.0 work starts, not speculatively now. |
| **Widgets (home screen)** | The Dashboard's modular card tiers (§3.3) are directly reusable — same visual language, smaller canvas. | None. |
| **Smartwatch (Wear OS / Apple Watch)** | `glanceableNumeral` + single-Hero-card pattern is inherently watch-compatible — "one glance, one purpose" (§2) *is* what a watch face needs. | None structural — would need a stripped-down single-card renderer, not a new design language. |
| **Cloud sync** | A small status indicator (icon + microcopy, e.g. "Synced just now") reuses the List Item trailing-icon pattern and the Information color. | None. |
| **Team scheduling / shared calendars** | Partial — the corner-indicator mechanism could carry a per-person color/avatar edge. | **Real gap.** This introduces a genuinely new dimension (whose shift, not just what type) and a person/avatar component this system doesn't have yet. Flagged honestly rather than claimed as already solved — real design work needed if this is ever prioritized. |

---

## Out of Scope, By Design

Per the brief: no Flutter code, no database/schema. Every token value and hex above is a
design specification for whoever implements it next, not an implementation — where a new
token is recommended (`radiusFull`, the `ShiftColors` set), that's flagged explicitly as
a change for the next code-touching task, not made here.
