# core/utils

Small, stateless helper functions and extensions shared across features, per
[ARCHITECTURE.md](../../../ARCHITECTURE.md).

- `app_date_format.dart` — weekday/month names and date formatting, promoted
  here once the Calendar feature needed the same names the Dashboard's
  `GreetingHeader` already had privately (see that file's own comment).

Further helpers (e.g. currency formatting) get added the same way: once a
second feature genuinely needs one, not written speculatively ahead of need.
