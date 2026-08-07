# Shift Companion — Software Requirements Specification

*This document is the master specification for Shift Companion. It defines **what** the
application must do. It intentionally does not describe how any requirement will be
implemented, what the underlying architecture will be, or how data will be stored — those
are separate, later decisions. Where a term is used with a specific meaning, see the
[Glossary](#17-glossary).*

*Related documents: [docs/VISION.md](VISION.md) (why the product exists),
[ARCHITECTURE.md](../ARCHITECTURE.md) (how it is built).*

---

## 1. Introduction

Shift Companion is a mobile application for shift-based workers — in retail,
hospitality, healthcare, warehousing, security, manufacturing, and other shift-driven
industries — that helps them manage their schedule, leave, earnings, and personal time.

This Software Requirements Specification (SRS) describes the complete set of functional
and non-functional requirements for the application. It is written to be understood by
product, design, and engineering stakeholders alike, and to remain stable as the
implementation evolves underneath it.

## 2. Purpose

The purpose of this document is to serve as the single, authoritative source of truth
for **what** Shift Companion must do — for use in planning, design, development, and
quality assurance. Any feature work, design decision, or test plan should be traceable
back to a requirement in this document. Where a desired behavior is not covered here, the
document should be updated before the behavior is built, not after.

This SRS complements, but is distinct from, [docs/VISION.md](VISION.md): the Vision
document explains *why* Shift Companion exists and what it stands for; this document
translates that vision into concrete, verifiable requirements.

## 3. Project Goals

- Give shift workers a single, reliable place to view their current and upcoming
  schedule.
- Make leave (annual, sick, and alternative holiday) easy to track and understand at a
  glance.
- Give users clear visibility into what they are earning and have earned.
- Reduce the mental effort of managing an irregular schedule.
- Support protected personal time by making work commitments easy to see and plan
  around.
- Work reliably regardless of connectivity, since shift workers are frequently on the
  move or in low-signal workplaces (warehouses, hospitals, back-of-house areas).
- Be usable by a global, industry-diverse audience without requiring technical
  sophistication.
- Lay a requirements foundation that supports payroll verification and AI-powered
  assistance as later additions, without requiring a rebuild of the core experience.

## 4. Target Users

Shift Companion is designed for individual shift workers who need to track and plan
around irregular or rotating work schedules, including workers in retail, hospitality,
healthcare, warehousing, security, and manufacturing, as well as any other worker whose
hours are organized as shifts rather than a fixed daily schedule.

Users may:
- Work for a single employer or hold multiple concurrent shift-based jobs.
- Work fixed rotations, fully variable rosters, or a mix of both.
- Be paid a flat hourly rate, or a rate that varies by time of day, day of week, or
  holiday status.
- Have varying degrees of comfort with technology — the application must be usable by
  a non-technical user without guidance.

## 5. Functional Requirements

Functional requirements are grouped by module. Each module describes what the user must
be able to do; it does not prescribe how the capability is technically delivered.

### 5.1 Dashboard

The Dashboard is the user's landing view, giving an at-a-glance summary of their current
status and the information they need most often.

- **FR-DASH-1**: The system shall display the user's next upcoming shift, including its
  date, start time, and end time.
- **FR-DASH-2**: The system shall display a live countdown to the next upcoming shift or,
  if the user is currently on shift, a countdown to the end of the current shift.
- **FR-DASH-3**: The system shall display the user's current status (e.g., off shift, on
  shift, on break, on leave).
- **FR-DASH-4**: The system shall display a summary of current leave balances (annual,
  sick, alternative holiday).
- **FR-DASH-5**: The system shall display an estimate of earnings for the current pay
  period.
- **FR-DASH-6**: The system shall provide quick access to key actions, including viewing
  the calendar, starting a break timer, and viewing recent notifications.
- **FR-DASH-7**: The user shall be able to choose which summary items appear on the
  Dashboard.

### 5.2 Shift Calendar

The Shift Calendar is the primary record of the user's scheduled and past shifts.

- **FR-CAL-1**: The user shall be able to view their shifts in daily, weekly, and monthly
  views.
- **FR-CAL-2**: The user shall be able to manually add, edit, and delete individual
  shifts.
- **FR-CAL-3**: A shift entry shall include, at minimum: date, start time, end time, and
  break duration, with optional fields for role/position, location, and notes.
- **FR-CAL-4**: The system shall visually distinguish between shift types (e.g., regular,
  overtime, on-call) and non-working entries (e.g., leave, public holiday) on the
  calendar.
- **FR-CAL-5**: The user shall be able to view the details of any individual shift.
- **FR-CAL-6**: The user shall be able to mark a shift as changed (e.g., swapped, covered,
  cancelled) and record who it was changed with, where relevant.
- **FR-CAL-7**: The user shall be able to search and filter shifts by date range and
  shift type.
- **FR-CAL-8**: The user shall be able to export or share a view of their schedule for a
  given period.
- **FR-CAL-9**: The calendar shall reflect shifts generated by the Shift Pattern
  Generator alongside manually added shifts.

### 5.3 Shift Pattern Generator

The Shift Pattern Generator allows users with a recurring roster to define it once and
have future shifts populate automatically.

- **FR-PAT-1**: The user shall be able to define a recurring shift pattern (e.g., a
  fixed weekly schedule, a rotating cycle such as 4-on-4-off, or a custom repeating
  sequence).
- **FR-PAT-2**: The user shall be able to preview the shifts a pattern will generate
  before applying it to their calendar.
- **FR-PAT-3**: The system shall generate future shifts on the calendar based on an
  active pattern.
- **FR-PAT-4**: The user shall be able to edit or regenerate an existing pattern, with
  the option to apply changes only to future shifts.
- **FR-PAT-5**: The user shall be able to pause or resume a pattern without deleting it.
- **FR-PAT-6**: The user shall be able to maintain more than one active pattern
  concurrently (e.g., for users with multiple jobs).
- **FR-PAT-7**: The system shall warn the user if applying a pattern would create
  overlapping shifts.

### 5.4 Countdown Timer

The Countdown Timer keeps the user oriented in time relative to their work.

- **FR-CD-1**: The system shall display a live countdown to the start of the user's next
  shift.
- **FR-CD-2**: While the user is on shift, the system shall display a live countdown to
  the end of that shift.
- **FR-CD-3**: The system shall display a countdown to the user's next full day off.
- **FR-CD-4**: The user shall be able to configure alerts at specific countdown
  thresholds (e.g., "1 hour before shift start").

### 5.5 Break Timer

The Break Timer helps users track and manage breaks during an active shift.

- **FR-BRK-1**: The user shall be able to start, pause, and end a break during an active
  shift.
- **FR-BRK-2**: The system shall track elapsed break time against the break duration
  associated with the current shift.
- **FR-BRK-3**: The system shall alert the user when a break is approaching its end and
  when it has ended.
- **FR-BRK-4**: The user shall be able to record more than one break within a single
  shift.
- **FR-BRK-5**: The system shall retain a history of breaks taken per shift.

### 5.6 Earnings

The Earnings module gives users visibility into what their work is worth.

- **FR-EARN-1**: The system shall estimate earnings for a shift based on its duration
  and the applicable pay rate.
- **FR-EARN-2**: The user shall be able to define one or more pay rates (e.g., base rate,
  overtime rate, night/weekend differential).
- **FR-EARN-3**: The user shall be able to view earnings summaries by day, week, month,
  pay period, and year.
- **FR-EARN-4**: The system shall separate earnings by job for users with multiple
  concurrent jobs.
- **FR-EARN-5**: The system shall clearly label earnings figures as estimates unless
  confirmed through payroll verification (see [Future Features](#15-future-features)).
- **FR-EARN-6**: The user shall be able to manually adjust or override an earnings entry.
- **FR-EARN-7**: The system shall display earnings in the user's selected currency.

### 5.7 Annual Leave

- **FR-AL-1**: The user shall be able to set and edit their annual leave entitlement.
- **FR-AL-2**: The user shall be able to record annual leave taken, as a date or date
  range.
- **FR-AL-3**: The system shall display the user's current annual leave balance.
- **FR-AL-4**: The user shall be able to view a history of annual leave taken.
- **FR-AL-5**: The system shall indicate annual leave visually on the Shift Calendar.
- **FR-AL-6**: The system shall warn the user, without blocking the action, if recording
  leave would take their balance below zero.

### 5.8 Sick Leave

- **FR-SL-1**: The user shall be able to record sick leave taken, including date, and
  optional duration and note.
- **FR-SL-2**: The system shall display the user's sick leave balance where the user has
  defined an entitlement.
- **FR-SL-3**: The user shall be able to view a history of sick leave taken.
- **FR-SL-4**: The user shall be able to indicate whether an instance of sick leave was
  paid or unpaid.
- **FR-SL-5**: The system shall indicate sick leave visually on the Shift Calendar.

### 5.9 Alternative Holidays

Alternative holidays (also known as "time off in lieu") represent days off owed to a
worker, typically for having worked a public holiday or other exceptional shift.

- **FR-AH-1**: The user shall be able to record an alternative holiday earned, including
  the reason and date earned.
- **FR-AH-2**: The system shall display the user's current alternative holiday balance.
- **FR-AH-3**: The user shall be able to redeem an alternative holiday as a day off on
  their calendar.
- **FR-AH-4**: The system shall prevent the alternative holiday balance from going
  negative through redemption.
- **FR-AH-5**: The user shall be able to view a history of alternative holidays earned
  and redeemed.
- **FR-AH-6**: The system shall indicate alternative holidays visually on the Shift
  Calendar.

### 5.10 Public Holidays

- **FR-PH-1**: The system shall display public holidays relevant to the user's selected
  country or region.
- **FR-PH-2**: The user shall be able to select their country or region to determine
  which public holidays apply.
- **FR-PH-3**: The system shall indicate when a scheduled shift falls on a public
  holiday.
- **FR-PH-4**: The user shall be able to manually add employer-specific or custom
  holidays not covered by the regional calendar.
- **FR-PH-5**: The user shall be able to specify whether public holidays affect their
  pay rate, for use in earnings calculations.

### 5.11 Statistics

- **FR-STAT-1**: The system shall display trends in hours worked over selectable time
  periods (week, month, year).
- **FR-STAT-2**: The system shall display earnings trends and allow comparison across
  time periods.
- **FR-STAT-3**: The system shall summarize leave usage (annual, sick, alternative
  holiday) over a selectable period.
- **FR-STAT-4**: The system shall provide an indicator of work-life balance, such as the
  ratio of worked days to rest days over time.
- **FR-STAT-5**: The user shall be able to export a statistics summary for personal
  record-keeping.

### 5.12 Notifications

*(In-application module surface; system-wide notification requirements are defined in
[Section 9](#9-notifications).)*

- **FR-NOTIF-1**: The user shall be able to view a history of past notifications within
  the application.
- **FR-NOTIF-2**: The user shall be able to configure which categories of notification
  are enabled.
- **FR-NOTIF-3**: The user shall be able to set custom, one-off reminders not tied to a
  predefined category.
- **FR-NOTIF-4**: The user shall be able to clear or dismiss notifications individually
  or in bulk.

### 5.13 Settings

- **FR-SET-1**: The user shall be able to select their preferred display theme (e.g.,
  light, dark, or system default).
- **FR-SET-2**: The user shall be able to select their preferred language.
- **FR-SET-3**: The user shall be able to select their region and currency.
- **FR-SET-4**: The user shall be able to set their preferred first day of the week for
  calendar views.
- **FR-SET-5**: The user shall be able to manage all notification preferences from a
  central location.
- **FR-SET-6**: The user shall be able to export their data for personal backup.
- **FR-SET-7**: The user shall be able to import previously exported data.
- **FR-SET-8**: The user shall be able to access accessibility preferences from Settings.

### 5.14 User Profile

- **FR-PROF-1**: The user shall be able to view and edit their personal details (e.g.,
  name, preferred display name).
- **FR-PROF-2**: The user shall be able to add and manage details for more than one job
  or employer.
- **FR-PROF-3**: The user shall be able to associate pay rate and leave entitlement
  details with a specific job.
- **FR-PROF-4**: The user shall be able to set a profile picture or avatar.
- **FR-PROF-5**: The user shall be able to view their account status (e.g., guest or
  registered — see [Section 7](#7-user-roles)).

## 6. Non-Functional Requirements

- **NFR-1 (Performance)**: The application shall launch and become interactive within a
  time frame that feels immediate to the user, and shall render calendar and dashboard
  views without perceptible delay under normal use.
- **NFR-2 (Usability)**: A first-time user shall be able to view their upcoming shift and
  record a new shift without external instructions.
- **NFR-3 (Reliability)**: The application shall not lose user-entered data due to
  interruptions such as an incoming call, app backgrounding, or low battery.
- **NFR-4 (Compatibility)**: The application shall support current and recent versions of
  major mobile operating systems, and shall function correctly across a range of common
  screen sizes.
- **NFR-5 (Localization)**: The application shall support multiple languages and regional
  date, time, and currency formats.
- **NFR-6 (Efficiency)**: The application shall be considerate of battery life and
  mobile data usage, given that users may rely on the app throughout an extended shift.
- **NFR-7 (Consistency)**: Interaction patterns shall be consistent across modules, so
  that a skill learned in one part of the app transfers to others.
- **NFR-8 (Maintainability)**: Requirements shall be specified clearly enough that new
  features can be added without conflicting with existing, documented behavior.

## 7. User Roles

Shift Companion is a single-user-per-account product: it does not include manager,
administrator, or team roles in its current scope (see [Out of Scope](#16-out-of-scope)
and [Future Features](#15-future-features)). The roles defined here describe differences
in account status, not differences in job function.

- **Guest User**: A user who has not created an account. A Guest User has full access to
  core scheduling, leave, and earnings features, with data kept only on their device. A
  Guest User cannot use cross-device synchronization.
- **Registered User**: A user who has created an account. A Registered User has all Guest
  User capabilities, plus data synchronization across devices, backup, and eligibility
  for future account-linked features such as payroll verification.

## 8. Business Rules

- **BR-1**: A leave balance (annual, sick, or alternative holiday) shall not be reduced
  below zero without an explicit warning to the user.
- **BR-2**: A single date and time range shall not be simultaneously recorded as both a
  worked shift and a leave entry.
- **BR-3**: An alternative holiday may only be redeemed if a positive balance exists.
- **BR-4**: A break shall not be recorded with a duration exceeding the duration of its
  associated shift.
- **BR-5**: Earnings figures shall always be presented as estimates unless derived from a
  payroll-verification result.
- **BR-6**: Public holiday status shall only affect an earnings calculation if the user
  has explicitly linked their pay rate to public holiday status.
- **BR-7**: All monetary values within the application shall be displayed in a single,
  user-selected currency at any given time.
- **BR-8**: Notifications shall respect any quiet hours configured by the user, except
  where the user has designated a notification category as high-priority.
- **BR-9**: A shift generated by a Shift Pattern shall remain independently editable
  after generation, without altering the underlying pattern definition.

## 9. Notifications

- **NOTIF-REQ-1**: The system shall be able to notify the user in advance of an upcoming
  shift, at a user-configurable interval.
- **NOTIF-REQ-2**: The system shall be able to notify the user when a break is ending or
  has ended.
- **NOTIF-REQ-3**: The system shall be able to notify the user of relevant upcoming
  public holidays.
- **NOTIF-REQ-4**: The system shall be able to notify the user of changes to their
  recorded schedule.
- **NOTIF-REQ-5**: The user shall be able to define quiet hours during which non-critical
  notifications are suppressed.
- **NOTIF-REQ-6**: The user shall be able to enable or disable each category of
  notification independently.
- **NOTIF-REQ-7**: Notifications shall respect the permissions granted by the user at the
  operating-system level.

## 10. Accessibility Requirements

- **ACC-1**: The application shall be usable with a screen reader.
- **ACC-2**: The application shall support user-adjustable text size without breaking
  layout or hiding information.
- **ACC-3**: The application shall maintain sufficient color contrast for text and
  meaningful interface elements.
- **ACC-4**: The application shall not rely on color alone to convey status or meaning
  (e.g., shift type, leave type); a secondary indicator such as text or icon shall also
  be present.
- **ACC-5**: Interactive elements shall be large enough to be reliably operated by touch.
- **ACC-6**: The application shall honor relevant operating-system accessibility
  settings where available (e.g., reduced motion, bold text).

## 11. Offline Requirements

- **OFF-1**: The user shall be able to view their existing shift calendar, leave
  balances, and earnings estimates without an active network connection.
- **OFF-2**: The user shall be able to add, edit, or delete shifts, breaks, and leave
  entries while offline.
- **OFF-3**: The application shall clearly indicate when it is operating in offline mode.
- **OFF-4**: No user-entered data shall be lost as a result of the device being offline.
- **OFF-5**: Countdown and break timers shall continue to function accurately without
  network connectivity.

## 12. Synchronization Requirements

- **SYNC-1**: For a Registered User, data entered on one device shall be reflected on
  other devices associated with the same account once connectivity is available.
- **SYNC-2**: The system shall indicate to the user when data is out of sync and when
  synchronization is complete.
- **SYNC-3**: The user shall be able to manually trigger synchronization.
- **SYNC-4**: Where the same data has been changed differently on two devices, the
  system shall inform the user of the conflict and allow them to choose which change to
  keep, rather than silently discarding either.
- **SYNC-5**: Synchronization shall occur automatically in the background when
  connectivity allows, without requiring the user's active attention.

## 13. Security Requirements

- **SEC-1**: Access to a Registered User's account shall require authentication.
- **SEC-2**: The user shall be able to sign out of their account on a given device.
- **SEC-3**: Personal and earnings data shall be protected against unauthorized access,
  both on-device and in transit between the application and any remote service.
- **SEC-4**: The system shall support the user recovering access to their account if
  their authentication credentials are lost, through a secure process.
- **SEC-5**: The application shall not expose sensitive data (e.g., earnings, personal
  details) in a way visible to other applications or users of a shared device by
  default.

## 14. Privacy Requirements

- **PRIV-1**: The application shall collect only the data necessary to provide its
  features.
- **PRIV-2**: The user shall be informed, in clear language, what data is collected and
  why, before it is collected.
- **PRIV-3**: The user shall be able to export a copy of their personal data.
- **PRIV-4**: The user shall be able to request deletion of their account and associated
  personal data.
- **PRIV-5**: Personal data shall not be shared with third parties without the user's
  explicit consent.
- **PRIV-6**: The application's privacy policy shall be accessible from within the
  application at all times.

## 15. Future Features

The following are intended future directions for the product and are noted here to
provide context for current requirements, but are not required for the current
specification:

- **Payroll verification**: comparing tracked hours and expected earnings against an
  employer's payslip to confirm correct pay.
- **AI-powered assistance**: a conversational assistant able to answer questions about
  the user's schedule, leave, and earnings, and proactively surface relevant
  information.
- **Shift swapping between users**: allowing two Shift Companion users to propose and
  confirm a shift swap directly within the app.
- **Team or manager visibility**: an optional view for a manager or team lead, subject to
  worker consent, distinct from the single-user model in the current scope.
- **External calendar integration**: two-way synchronization with third-party calendar
  applications.
- **Wearable device support**: surfacing countdowns, break alerts, and shift reminders on
  wearable devices.
- **Expanded multi-platform income tracking**: supporting gig-economy and
  multiple-platform earners alongside traditional shift employment.

## 16. Out of Scope

The following are explicitly not part of Shift Companion's requirements at this stage:

- Processing or disbursing payroll payments on behalf of an employer.
- Administrative or management tooling for employers (rostering staff, approving leave
  as a manager, etc.).
- Direct system integration with specific employers' HR or payroll platforms.
- Tax filing, tax advice, or other financial/legal advisory functionality.
- Legal advice regarding employment rights or disputes.
- Automated, location-based shift clock-in/clock-out.
- General-purpose accounting or bookkeeping functionality beyond personal earnings
  tracking.

## 17. Glossary

| Term | Definition |
|---|---|
| **Shift** | A single, discrete period of scheduled or worked time, with a start and end time. |
| **Shift Pattern** | A user-defined, repeating sequence of shifts and/or days off, used to automatically generate shifts on the calendar. |
| **Countdown Timer** | A live, running display of the time remaining until a defined point, such as the start or end of a shift. |
| **Break Timer** | A timer used to track the duration of a break taken during a shift. |
| **Annual Leave** | Paid time off accrued and taken by agreement with an employer, tracked as a balance. |
| **Sick Leave** | Time off taken due to illness, which may be tracked against a balance and may be paid or unpaid. |
| **Alternative Holiday** | A day off owed to a worker in exchange for having worked a public holiday or other exceptional shift; also known as "time off in lieu" (TOIL). |
| **Public Holiday** | A nationally or regionally recognized non-working day, which may affect scheduling or pay rate. |
| **Pay Rate** | A defined rate of pay (e.g., base, overtime, differential) used to estimate earnings for a shift. |
| **Earnings Estimate** | A calculated approximation of what a shift or period is worth, pending confirmation against actual pay. |
| **Payroll Verification** | (Future) The process of comparing tracked hours/earnings against an employer's payslip to confirm accuracy. |
| **Entitlement** | The total amount of a given leave type a user is due over a defined period. |
| **Balance** | The remaining, unused amount of a given leave type at a point in time. |
| **Guest User** | A user of the application who has not created an account; data remains local to their device. |
| **Registered User** | A user with an account, enabling cross-device synchronization and account-linked features. |
| **Sync (Synchronization)** | The process of reconciling data for a Registered User across multiple devices. |
| **Offline Mode** | The state in which the application operates without an active network connection. |
| **Quiet Hours** | A user-defined period during which non-critical notifications are suppressed. |
| **Roster** | An employer-provided schedule of shifts, which a user may replicate or reference within the application. |
