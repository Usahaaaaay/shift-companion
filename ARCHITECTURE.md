# Architecture

This document describes *how* Shift Companion is structured and *why*. It's a living
document — update it whenever an architectural decision is made or changed, and add a
matching entry in [decisions/](decisions/) for anything significant.

See also: [CLAUDE.md](CLAUDE.md) for the working rules this architecture exists to support.

## Guiding principle: Clean Architecture

Each feature is split into three layers, each with a single, narrow responsibility.
Dependencies only point inward (presentation → domain ← data); the domain layer never
depends on Flutter, a database, or an HTTP client. This is what makes "keep business
logic out of UI widgets" and "prefer composition over duplication" enforceable rather
than aspirational.

```
presentation  →  depends on →  domain  ←  depends on  ←  data
   (UI, Riverpod)              (pure Dart)              (implementations)
```

- **`domain/`** — Entities (plain Dart classes describing the business concepts, e.g.
  `Shift`), repository *interfaces* (abstract contracts, e.g. `ShiftRepository`), and use
  cases (single-purpose classes encapsulating one business operation, e.g.
  `ClockInUseCase`). No Flutter imports here. This layer is what makes the app's rules
  testable without a widget tree or a real backend.
- **`data/`** — Concrete implementations of the domain's repository interfaces, plus data
  sources (local DB, HTTP client, etc.) and DTOs/models for (de)serialization. This is
  where the Dependency Inversion Principle earns its keep: domain defines the contract,
  data fulfills it, so swapping a data source later doesn't touch business logic or UI.
- **`presentation/`** — Screens, widgets, and Riverpod providers/notifiers. Widgets read
  state from providers and dispatch events to them; they do not contain business logic
  themselves. This is the practical mechanism behind the "business logic out of UI
  widgets" and "widgets under 300 lines" rules — logic that would bloat a widget belongs
  in a notifier or use case instead.

## Folder structure

Feature-first: each feature owns its full stack (domain/data/presentation), rather than
grouping by technical layer across the whole app. This keeps related code together and
makes a feature deletable/movable as a unit.

```
lib/
  core/                     # cross-cutting concerns shared by every feature
    constants/              # app-wide constant values
    errors/                 # shared failure/exception types
    theme/                  # ThemeData, colors, text styles
    utils/                  # small stateless helpers, extensions
    widgets/                # generic reusable UI components (buttons, cards, etc.)
                             # — feature-specific widgets live in their own feature instead
  features/
    <feature_name>/
      data/
        datasources/        # local (e.g. Drift/SharedPreferences) or remote (HTTP) sources
        models/              # DTOs — how data looks on the wire/in storage
        repositories/        # implementations of the domain repository interfaces
      domain/
        entities/            # plain business objects
        repositories/        # abstract repository contracts
        usecases/            # one class per business operation
      presentation/
        providers/           # Riverpod providers/notifiers — the feature's state layer
        screens/              # full-page widgets, wired to a route
        widgets/              # widgets private to this feature
  routing/                  # go_router route definitions, wired to screens
  app.dart                  # root widget: MaterialApp.router + ProviderScope wiring
  main.dart                 # entry point only — no logic beyond bootstrapping
```

A new feature is added by creating `features/<name>/{data,domain,presentation}` and
wiring its routes into `routing/`. Nothing outside `core/` and `routing/` should need to
change — which is also why the "5+ files touched" rule in CLAUDE.md is a useful smell
test: crossing that threshold for what looks like a single-feature change usually means
something is coupled that shouldn't be.

## Chosen stack

| Concern | Choice | Rationale (full writeup in decisions/) |
|---|---|---|
| State management / DI | Riverpod | Compile-safe DI, testable providers, no `BuildContext` needed to read state, scales well feature-by-feature. |
| Navigation | go_router | Declarative, deep-link friendly, official Flutter-team-recommended router, integrates cleanly with Riverpod for auth-gated redirects. |

Not yet decided (deferred until a feature needs it — see CLAUDE.md's "decide when
forced" rule): local persistence, backend/API integration, authentication.

## Testing implications

Because domain logic has no Flutter dependency, use cases and entities are unit-testable
in plain Dart with no widget pump needed. Repositories are tested against fakes of their
data sources. Widgets are tested with Riverpod's `ProviderScope` overrides to inject fake
notifiers, so widget tests don't need a real data/domain layer wired up.
