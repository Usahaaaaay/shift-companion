# core/errors

Reserved for shared failure/exception types, per [ARCHITECTURE.md](../../../ARCHITECTURE.md).

This folder is intentionally empty for now. It will hold the app-wide failure
types (e.g. a base `Failure` class and its variants) that the `data/` layer of
each feature maps its exceptions to, and that the `presentation/` layer
displays as user-facing error states (see
[docs/UI_UX_Principles.md](../../../docs/UI_UX_Principles.md) Section 14,
"Error States"). It's created now, empty, so the folder structure matches the
architecture from the start — real content will be added once the first
feature that needs error handling is implemented, per this project's rule
against speculative code.
