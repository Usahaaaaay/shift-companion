# Shift Companion — Master Feature List

*This document is the master roadmap of every feature planned for Shift Companion —
what exists, what's next, and what's speculative. It does not describe implementation,
Flutter code, or data storage. New features should be added here as they're identified,
in the section that matches their maturity and priority, using the same format as the
entries already in place.*

*Related documents: [VISION.md](VISION.md) (why these features matter),
[Software_Requirements.md](Software_Requirements.md) (what each feature must do, module
by module), [UI_UX_Principles.md](UI_UX_Principles.md) (how every feature should feel).*

---

## How to Read This Document

Each feature entry includes:

- **Description** — what the feature does, in plain language.
- **Why It Matters** — the user problem or product goal it serves.
- **Priority** — how essential it is *within its section*, not to the whole product.
- **Planned Version** — the earliest release it's expected to appear in.

### Priority Legend

| Priority | Meaning |
|---|---|
| **Critical** | The product is not viable at its intended release stage without this. |
| **High** | Core to the product's value proposition; most users will expect it. |
| **Medium** | Adds real value but the product is complete and coherent without it initially. |
| **Low** | A worthwhile enhancement that can wait indefinitely without harming the core experience. |

### Version Legend

| Version | Meaning |
|---|---|
| **1.0** | Initial public release. |
| **1.x** | Near-term post-launch iterations, refining and extending 1.0. |
| **2.0** | Major second-phase release — introduces payroll verification and AI assistance, per the long-term goals in [VISION.md](VISION.md). |
| **TBD** | Planned in principle; version depends on user feedback and product priorities post-launch. |
| **Exploratory** | An idea under genuine consideration, not yet a committed roadmap item. |

---

## 1. Core Features (Version 1.0)

The essential experience. Every feature in this section is required for Shift Companion
to deliver on its core promise: a shift worker can see their schedule, understand their
leave, and estimate their earnings, entirely on one device, without an account.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| Dashboard | Critical | 1.0 |
| Shift Calendar | Critical | 1.0 |
| Shift Pattern Generator | Critical | 1.0 |
| Countdown Until Finish | High | 1.0 |
| Break Timer | High | 1.0 |
| Weekly Earnings | High | 1.0 |
| Monthly Earnings | High | 1.0 |
| Annual Leave Tracker | High | 1.0 |
| Sick Leave Tracker | High | 1.0 |
| Alternative Holiday Tracker | High | 1.0 |
| Public Holiday Calculator | High | 1.0 |
| Statistics (Core) | Medium | 1.0 |
| Notifications (Core) | High | 1.0 |

### Dashboard
- **Description**: The user's landing screen — a single-glance summary of their next
  shift, current status, leave balances, and estimated earnings for the period.
- **Why It Matters**: This is the first thing a tired user sees when they open the app.
  If it doesn't answer "what do I need to know right now" instantly, the app has failed
  its core purpose.
- **Priority**: Critical
- **Planned Version**: 1.0

### Shift Calendar
- **Description**: A calendar view of scheduled, past, and leave-related entries, with
  the ability to add, edit, and review individual shifts.
- **Why It Matters**: The system of record for the user's working life; nearly every
  other feature reads from or writes to it.
- **Priority**: Critical
- **Planned Version**: 1.0

### Shift Pattern Generator
- **Description**: Lets a user define a recurring roster pattern once and have future
  shifts populate automatically.
- **Why It Matters**: Most shift workers repeat a pattern (e.g., 4-on-4-off, a fixed
  weekly rota). Manual entry of every shift is exactly the tedious burden this app exists
  to remove.
- **Priority**: Critical
- **Planned Version**: 1.0

### Countdown Until Finish
- **Description**: A live countdown to the end of the user's current shift (and to the
  start of their next one when not currently working).
- **Why It Matters**: One of the most emotionally resonant, small moments of relief this
  app can offer — "how much longer" is a question shift workers ask constantly.
- **Priority**: High
- **Planned Version**: 1.0

### Break Timer
- **Description**: Start, pause, and track breaks taken during a shift, with alerts as
  break time runs down.
- **Why It Matters**: Protects the user's short, valuable rest time during a shift and
  helps them return on time without watching the clock themselves.
- **Priority**: High
- **Planned Version**: 1.0

### Weekly Earnings
- **Description**: An estimated earnings total for the current week, based on scheduled
  or worked hours and the user's pay rate(s).
- **Why It Matters**: Gives users near-term financial visibility — "what am I on track to
  make this week" — which is often more actionable than a monthly view alone.
- **Priority**: High
- **Planned Version**: 1.0

### Monthly Earnings
- **Description**: An estimated earnings total across a full month or pay period.
- **Why It Matters**: Supports budgeting and financial planning at the cadence most
  bills and expenses actually operate on.
- **Priority**: High
- **Planned Version**: 1.0

### Annual Leave Tracker
- **Description**: Tracks annual leave entitlement, leave taken, and remaining balance.
- **Why It Matters**: Removes the common anxiety of not knowing how much leave is left,
  or accidentally over-booking it.
- **Priority**: High
- **Planned Version**: 1.0

### Sick Leave Tracker
- **Description**: Logs sick leave taken and, where applicable, tracks it against a
  balance and paid/unpaid status.
- **Why It Matters**: Gives users a clear personal record independent of their employer's
  paperwork — useful both for planning and for their own peace of mind.
- **Priority**: High
- **Planned Version**: 1.0

### Alternative Holiday Tracker
- **Description**: Tracks alternative holidays (time off in lieu) earned — typically for
  working a public holiday — and lets the user redeem them as a day off.
- **Why It Matters**: This form of leave is uniquely easy to lose track of and uniquely
  common in shift-based industries; making it visible protects time the user has already
  earned.
- **Priority**: High
- **Planned Version**: 1.0

### Public Holiday Calculator
- **Description**: Shows relevant public holidays for the user's country/region and
  indicates when a scheduled shift falls on one.
- **Why It Matters**: Public holidays often affect pay and entitlement; surfacing them
  automatically saves the user from tracking a second calendar themselves.
- **Priority**: High
- **Planned Version**: 1.0

### Statistics (Core)
- **Description**: Basic visual summaries of hours worked, earnings, and leave usage over
  time.
- **Why It Matters**: Turns scattered shift history into a clear picture the user can
  actually reflect on, supporting the app's work-life-balance goals from day one.
- **Priority**: Medium
- **Planned Version**: 1.0

### Notifications (Core)
- **Description**: Shift reminders, break alerts, and public holiday notices, with basic
  user control over which are enabled.
- **Why It Matters**: Keeps the app useful without requiring the user to remember to open
  it — the app comes to them at the moments that matter.
- **Priority**: High
- **Planned Version**: 1.0

---

## 2. Advanced Features

Meaningful extensions of the core experience, planned for shortly after launch. These
deepen what the app already does rather than introducing new categories of value.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| Roster Import | Medium | 1.1 |
| Country Rules Engine | Medium | 1.2 |
| Work Streak Tracker | Low | 1.1 |
| Shift Insights | Medium | 1.2 |
| Work-Life Balance Insights | Medium | 1.2 |
| Export Reports | Medium | 1.1 |
| Widgets | Medium | 1.1 |

### Roster Import
- **Description**: Lets a user bring an existing employer-provided roster into Shift
  Companion instead of building a pattern or entering shifts manually.
- **Why It Matters**: Removes the single biggest piece of setup friction for a new user
  whose schedule is already defined elsewhere.
- **Priority**: Medium
- **Planned Version**: 1.1

### Country Rules Engine
- **Description**: A configurable system of region-specific rules governing public
  holidays, leave entitlement conventions, and holiday-pay treatment, beyond the basic
  country selection shipped in 1.0.
- **Why It Matters**: Shift Companion is built for a global audience; getting these rules
  right per region is what makes the app trustworthy rather than merely usable outside
  its home market.
- **Priority**: Medium
- **Planned Version**: 1.2

### Work Streak Tracker
- **Description**: Tracks consecutive shifts worked and highlights unusually long
  working streaks.
- **Why It Matters**: A light, motivating way to recognize consistency, and a gentle,
  early signal of a workload that might be trending toward burnout.
- **Priority**: Low
- **Planned Version**: 1.1

### Shift Insights
- **Description**: Rule-based observations drawn from a user's shift history (e.g.,
  typical shift length, most common shift type, changes in schedule over time).
- **Why It Matters**: Helps users notice patterns in their own working life that are
  otherwise hard to see day to day.
- **Priority**: Medium
- **Planned Version**: 1.2

### Work-Life Balance Insights
- **Description**: Summarizes the balance between working time and personal time — e.g.,
  rest days versus worked days, or how often planned time off is actually taken.
- **Why It Matters**: Directly serves the app's mission of protecting personal time, not
  just tracking work.
- **Priority**: Medium
- **Planned Version**: 1.2

### Export Reports
- **Description**: Lets users export a summary of shifts, earnings, or leave for a given
  period, for their own records.
- **Why It Matters**: Gives users an independent record they control, useful for personal
  finance, disputes, or simply peace of mind.
- **Priority**: Medium
- **Planned Version**: 1.1

### Widgets
- **Description**: Home-screen widgets surfacing the next shift, countdown, or today's
  earnings without opening the app.
- **Why It Matters**: A near-zero-tap way to get the app's most glanceable information —
  directly in line with the product's "minimal taps" principle.
- **Priority**: Medium
- **Planned Version**: 1.1

---

## 3. Premium Features (Potential Future)

Features that represent significant additional value and are natural candidates for a
paid tier, pending a future decision on monetization strategy. Their inclusion here
reflects product potential, not a commitment to a specific business model yet.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| Payslip Verification | High | 2.0 |
| Tax Estimates | Medium | 2.0 |
| Cloud Backup | Medium | TBD |
| Multi-device Sync | Medium | TBD |
| Custom Themes | Low | TBD |

### Payslip Verification
- **Description**: Compares a user's tracked hours and expected earnings against an
  uploaded or entered payslip to confirm they were paid correctly.
- **Why It Matters**: This is one of Shift Companion's long-term differentiators (see
  [VISION.md](VISION.md)) — moving from "here's what you probably earned" to "here's
  confirmation you were paid right," which directly protects users' income.
- **Priority**: High
- **Planned Version**: 2.0

### Tax Estimates
- **Description**: Provides an estimate of tax owed or withheld based on tracked
  earnings, for the user's relevant region.
- **Why It Matters**: Extends earnings visibility from gross pay to a realistic picture
  of take-home pay, which matters more to most users' actual budgeting.
- **Priority**: Medium
- **Planned Version**: 2.0

### Cloud Backup
- **Description**: Securely backs up a Registered User's data so it can be restored if a
  device is lost, damaged, or replaced.
- **Why It Matters**: For a long-term companion app, losing years of shift and earnings
  history to a lost phone would be a serious breach of the trust the app depends on.
- **Priority**: Medium
- **Planned Version**: TBD

### Multi-device Sync
- **Description**: Keeps a Registered User's data consistent and up to date across more
  than one device.
- **Why It Matters**: Many users move between a phone and a tablet, or replace devices
  over the years this app is meant to serve them; continuity matters for a "long-term
  companion."
- **Priority**: Medium
- **Planned Version**: TBD

### Custom Themes
- **Description**: Additional visual themes beyond the default light/dark experience,
  letting users personalize the app's appearance.
- **Why It Matters**: A low-cost, high-delight way to let users make the app feel like
  their own, without compromising the core design system defined in
  [UI_UX_Principles.md](UI_UX_Principles.md).
- **Priority**: Low
- **Planned Version**: TBD

---

## 4. AI Features

Features that use AI to move Shift Companion from a passive tracker to an active
assistant — the second pillar of the app's long-term vision, alongside payroll
verification.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| AI Assistant | High | 2.0 |
| AI Shift & Earnings Insights | Medium | 2.0 |
| AI Payslip Discrepancy Detection | Medium | 2.0 |

### AI Assistant
- **Description**: A conversational assistant that can answer natural-language questions
  about a user's schedule, leave, and earnings (e.g., "how many hours have I worked this
  week?") and proactively surface relevant information.
- **Why It Matters**: This is the feature that turns Shift Companion from something a
  user checks into something that helps them, unprompted — central to the "assistant,
  not just a tracker" ambition in [VISION.md](VISION.md).
- **Priority**: High
- **Planned Version**: 2.0

### AI Shift & Earnings Insights
- **Description**: AI-generated, plain-language observations about a user's schedule and
  earnings trends, going beyond the rule-based statistics in Shift Insights to surface
  less obvious patterns.
- **Why It Matters**: Helps users understand their own working life without having to
  interpret charts themselves.
- **Priority**: Medium
- **Planned Version**: 2.0

### AI Payslip Discrepancy Detection
- **Description**: An intelligent layer on top of Payslip Verification that flags likely
  pay discrepancies and explains, in plain language, what looks off and why.
- **Why It Matters**: Most workers wouldn't know how to spot a pay error even with the
  right numbers in front of them; this closes that gap.
- **Priority**: Medium
- **Planned Version**: 2.0

---

## 5. Nice-to-Have Features

Small, worthwhile enhancements that improve the experience without being essential to
it. These can be picked up opportunistically and don't block any other roadmap item.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| Additional Language Packs | Low | TBD |
| Streak Milestones & Celebrations | Low | TBD |

### Additional Language Packs
- **Description**: Expands language support beyond the initial set shipped at launch.
- **Why It Matters**: Shift Companion is built for a global audience; broader language
  support widens who the app can genuinely serve.
- **Priority**: Low
- **Planned Version**: TBD

### Streak Milestones & Celebrations
- **Description**: Light, positive acknowledgment when a user reaches a meaningful
  milestone (e.g., a full year of consistent tracking).
- **Why It Matters**: A small, low-effort touch of warmth that reinforces the app as a
  companion rather than a purely utilitarian tool — used sparingly, in keeping with the
  app's calm design philosophy.
- **Priority**: Low
- **Planned Version**: TBD

---

## 6. Future Expansion Ideas

Longer-horizon, more speculative directions. These are not committed roadmap items —
they're recorded here so good ideas aren't lost, and so future planning has context on
what's already been considered.

### Quick Reference

| Feature | Priority | Version |
|---|---|---|
| Wearables | Low | Exploratory |
| Shift Swapping Between Users | Low | Exploratory |
| Team / Manager View | Low | Exploratory |
| External Calendar Integration | Low | Exploratory |
| Multi-Platform Gig Income Tracking | Low | Exploratory |

### Wearables
- **Description**: Surfacing countdowns, break alerts, and shift reminders on wearable
  devices.
- **Why It Matters**: Extends the app's most glanceable, time-sensitive information to
  the most glanceable device a user owns.
- **Priority**: Low
- **Planned Version**: Exploratory

### Shift Swapping Between Users
- **Description**: Letting two Shift Companion users propose and confirm a shift swap
  directly within the app.
- **Why It Matters**: Shift swapping is a real, frequent need in shift-based work; solving
  it natively would remove a common off-app, informal workaround.
- **Priority**: Low
- **Planned Version**: Exploratory

### Team / Manager View
- **Description**: An optional, consent-based view for a manager or team lead, distinct
  from the single-user model the app is built around today.
- **Why It Matters**: Could open the product to organizational adoption, though it
  represents a meaningful shift from the individual-first model the app is designed
  around — see [Software_Requirements.md](Software_Requirements.md) Section 16 (Out of
  Scope).
- **Priority**: Low
- **Planned Version**: Exploratory

### External Calendar Integration
- **Description**: Two-way synchronization between Shift Companion and third-party
  calendar apps.
- **Why It Matters**: Many users already manage personal commitments in another
  calendar; keeping both in sync avoids double-entry.
- **Priority**: Low
- **Planned Version**: Exploratory

### Multi-Platform Gig Income Tracking
- **Description**: Extending earnings tracking to cover gig-economy and multiple-platform
  income, alongside traditional shift employment.
- **Why It Matters**: Broadens the app's relevance to workers whose income doesn't come
  from a single, traditional employer — a growing part of the shift-work landscape.
- **Priority**: Low
- **Planned Version**: Exploratory
