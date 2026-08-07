# 0001: State management & navigation — Riverpod + go_router

**Status:** Accepted (2026-08-07)

## Context

Shift Companion is starting from an empty repo, and clean architecture (per
[ARCHITECTURE.md](../ARCHITECTURE.md)) requires a state-management approach that can:
- Live in the `presentation/providers/` layer without leaking into `domain/`.
- Be unit-testable without a widget tree.
- Support dependency injection for repositories/use cases without relying on
  `BuildContext` lookups, so domain and data layers stay decoupled from widgets.

Navigation needs to support standard app-like flows (deep links, nested routes, and
later, auth-gated redirects) without hand-rolled `Navigator` push/pop chains scattered
across widgets.

This was decided upfront, before any feature work, so every future feature builds on the
same foundation rather than each one improvising its own state approach.

## Decision

Use **Riverpod** for state management and dependency injection, and **go_router** for
navigation.

## Alternatives considered

- **Bloc/Cubit** — Strong separation of concerns via explicit event → state streams, and
  a large ecosystem, but more ceremony per feature (events, states, bloc classes) than
  this project's scale currently justifies. Revisit if the team grows or the "explicit
  audit trail of every state transition" becomes a hard requirement — Bloc's
  event-sourcing style is genuinely better for that.
- **Provider (without Riverpod)** — Simpler, but depends on `BuildContext` for reads,
  which pulls Flutter into places clean architecture wants to keep pure-Dart-only, and
  lacks compile-time provider-not-found safety.
- **GetX** — Fast to write, but bundles state/DI/navigation/routing into one
  opinionated package in a way that fights the explicit layering this project wants;
  also weaker compile-time safety.
- **Navigator 2.0 hand-rolled** (instead of go_router) — More control, but significantly
  more boilerplate for deep linking and nested navigation, for no benefit this project
  needs yet.

## Consequences

- Every feature's `presentation/providers/` uses Riverpod `Provider`/`Notifier` classes;
  business logic lives there or in `domain/usecases/`, never inline in widgets.
- Repositories and use cases are provided via Riverpod providers, making them trivially
  overridable in tests (`ProviderScope(overrides: [...])`).
- Routes are declared centrally in `routing/` using go_router, not scattered
  `Navigator.push` calls in widgets — a screen doesn't need to know how it was reached.
- Adds two external dependencies (`flutter_riverpod`, `go_router`) that the whole app
  will be built around; replacing either later would touch every feature's presentation
  layer, so this is treated as a foundational, hard-to-reverse choice.
