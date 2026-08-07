# Architectural Decision Records

This folder is the paper trail behind [ARCHITECTURE.md](../ARCHITECTURE.md). CLAUDE.md's
"explain every architectural decision" rule is enforced *here*: any decision significant
enough to affect how future features are built gets one file, so the reasoning survives
even after the chat that produced it is gone.

## When to add one

Add a decision record when a choice would be expensive or disruptive to reverse later,
or when a future contributor would reasonably ask "why is it done this way?" — e.g.
picking a state-management library, a persistence approach, an auth strategy, or
deviating from the folder structure in ARCHITECTURE.md. Small, easily-reversible
implementation choices don't need one.

## Format

One file per decision, numbered sequentially: `NNNN-short-title.md`. Each file covers:

- **Status** — proposed / accepted / superseded (with a link to what superseded it)
- **Context** — what problem or question prompted the decision
- **Decision** — what was chosen
- **Alternatives considered** — what else was on the table, and why it lost
- **Consequences** — what this makes easier, harder, or forecloses

## Index

| # | Title | Status |
|---|---|---|
| [0001](0001-state-management-and-navigation.md) | State management & navigation: Riverpod + go_router | Accepted |
