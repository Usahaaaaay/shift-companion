# Shift Companion — Project Rules

This file is read automatically at the start of every session in this repo. It is the
source of truth for how work gets done here. If a rule here conflicts with a general
instinct toward "just fix it," this file wins.

Related docs:
- [ARCHITECTURE.md](ARCHITECTURE.md) — clean architecture layout, folder structure, chosen tech stack.
- [decisions/](decisions/) — one file per significant architectural decision, with rationale.

## Project Overview

Shift Companion is a Flutter app (no code written yet — this repo currently holds only
project rules and architecture docs, established deliberately before implementation
begins). Update this section once the app's purpose/domain is fleshed out.

## Working Rules

These apply to every task, not just the first one.

**Code quality**
- Always prioritize readability over cleverness.
- Always comment your code.
- Never remove existing comments.
- Keep widgets under 300 lines where possible — split into smaller widgets rather than
  growing a single file.
- Keep business logic out of UI widgets (widgets render state and dispatch events; they
  don't compute it — see [ARCHITECTURE.md](ARCHITECTURE.md)).
- Use reusable components instead of copy-pasting UI.
- Prefer composition over duplication.
- Follow clean architecture principles (see [ARCHITECTURE.md](ARCHITECTURE.md)).
- Follow SOLID principles where appropriate — don't force them where they add ceremony
  without benefit.
- Write code as if another developer will maintain it in five years.

**Change discipline**
- Never rewrite working code unless requested.
- Never change unrelated files.
- Do not refactor unrelated code while implementing a feature.
- Do not rename existing files unless requested.
- Do not change project architecture without asking first.
- Preserve backward compatibility whenever possible.
- Only modify files that are necessary for the task at hand.
- If a change affects multiple files, explain why before/while making it.
- If a feature requires modifying more than 5 files, explain why before generating code.
- If you notice a better design than what's currently in place, explain it *before*
  changing anything — don't silently substitute your judgment for the existing design.

**Communication**
- Explain every architectural decision (what, and why over the alternatives). Record
  significant ones in [decisions/](decisions/), not just in chat.
- After every task, provide a summary containing:
  - Files created
  - Files modified
  - What changed
  - Why it changed
  - How to test it
  - Any future considerations

## Tech Stack (see decisions/ for full rationale)

- **Framework:** Flutter
- **State management / DI:** Riverpod
- **Navigation:** go_router
- **Architecture:** Clean architecture, feature-first folder structure

Anything not listed here (local storage, backend/API layer, auth, etc.) is undecided —
it gets decided (and recorded as a decision) when the first feature that needs it comes
up, not speculatively now.
