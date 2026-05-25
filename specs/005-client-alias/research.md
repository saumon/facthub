# Research: Client Alias Management

## Decision 1: Persist alias directly on the existing clients table

- Decision: Add one nullable string column on `clients` to store the alias as optional informational data on the existing `Client` record.
- Rationale: The spec defines alias as descriptive metadata attached to a client, not as a separate lifecycle or collection. A dedicated table would add joins and complexity without adding value for a single optional attribute.
- Alternatives considered:
  - Separate `client_aliases` table: rejected because the feature has no history, ownership, or search requirements that justify another persisted entity.
  - Virtual or computed alias only in the UI: rejected because the alias must be editable over time and persist across sessions.

## Decision 2: Normalize alias input in the model before validation

- Decision: Trim leading and trailing whitespace in the `Client` model before validation, treat whitespace-only input as blank, and validate a maximum length of 100 characters with `allow_blank: true`.
- Rationale: Model-level normalization guarantees consistent behavior across create and update flows and keeps the controller thin. It also ensures that whitespace-only values are not persisted as meaningless labels.
- Alternatives considered:
  - Trim in the controller only: rejected because the same normalization would need to be repeated across multiple entry points.
  - Database-level trimming only: rejected because the UI still needs validation feedback before save and Rails model validations are the existing pattern.

## Decision 3: Use the existing admin client detail page as the alias editing surface

- Decision: Keep the current `show` page and add a dedicated alias form there, backed by a standard Rails update route that permits alias changes without introducing a separate edit page.
- Rationale: The spec explicitly calls for a dedicated form on the detail page. Reusing the current detail view keeps the interaction aligned with the existing admin client flow and avoids unnecessary navigation.
- Alternatives considered:
  - Create a separate edit screen: rejected because it adds a new page and breaks the requested in-place management workflow.
  - Introduce a custom member action such as `update_alias`: rejected because a normal `PATCH /admin/clients/:id` route is simpler and better matches Rails conventions.

## Decision 4: Show alias and identifier together in management views with a fixed fallback string

- Decision: Display the alias on the admin clients list and detail page while keeping the generated client identifier visible, and render the exact fallback text "No alias defined" whenever no alias exists.
- Rationale: The clarifications require alias visibility without replacing the identifier, and they require one exact fallback string across management views. Keeping both visible preserves the client identifier as the authoritative reference.
- Alternatives considered:
  - Replace the identifier with alias when present: rejected because the identifier must remain visible in management views.
  - Show a blank field instead of fallback text: rejected because the spec explicitly defines the fallback copy.

## Decision 5: Validate the feature through model, controller, and system coverage plus a representative performance walkthrough

- Decision: Add model tests for normalization and length constraints, controller tests for authenticated create and update behavior, and system tests for visible admin journeys. Verify the performance budget with a representative 500-client walkthrough in the admin UI.
- Rationale: The feature changes both persistence rules and user-visible flows. Multiple test layers are needed to prove normalization, controller wiring, and rendered UI behavior.
- Alternatives considered:
  - Model tests only: rejected because they do not prove visibility and admin workflow behavior.
  - System tests only: rejected because they are slower and less precise for validation and normalization edge cases.
