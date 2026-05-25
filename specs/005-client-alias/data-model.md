# Data Model: Client Alias Management

## Client

- Purpose: Existing persisted client record managed by authenticated administrators and identified by a generated `client_identifier`.
- Fields:
  - id: integer, primary key
  - client_identifier: string, required, unique, generated on create
  - alias: string, optional, maximum 100 characters after trimming as counted by standard Rails length validation, not unique
  - last_fact_id: integer, optional, existing progression pointer
  - created_at / updated_at: timestamps
- Validation rules:
  - `client_identifier` must be present
  - `client_identifier` must be unique
  - `alias` must be trimmed before validation and persistence
  - `alias` may be blank or `nil`
  - `alias` values whose trimmed length exceeds 100 characters are rejected
  - duplicate alias values across clients are allowed
- Relationships:
  - No new relationships are introduced
  - Existing relationship to the served fact progression remains unchanged
- State transitions:
  - Create without alias: client persists with `alias = nil`
  - Create with alias: client persists with trimmed alias text
  - Update alias: alias changes from one trimmed value to another
  - Clear alias: alias transitions from a saved value to blank and persists as empty or `nil` according to implementation choice, while presentation still uses the same fallback text

## ClientAliasInput

- Purpose: Request-scoped alias input received from the admin create form and the dedicated alias form on the client detail page.
- Fields:
  - raw_value: original submitted string or `nil`
  - normalized_value: trimmed alias string or blank result after normalization
  - source_action: one of `create` or `update`
- Validation rules:
  - leading and trailing whitespace are removed
  - internal whitespace is preserved as entered
  - whitespace-only input is treated as empty input
  - normalized non-empty input must not exceed 100 characters as counted by standard Rails length validation
- Relationships:
  - Maps to the `Client.alias` persisted field
  - Drives validation feedback on the admin form that submitted it

## ClientAliasPresentation

- Purpose: Derived presentation state for admin views that need to show alias and identifier together.
- Fields:
  - alias_text: saved alias when present
  - fallback_text: exact string `No alias defined` when alias is absent
  - client_identifier: generated opaque identifier that remains visible in management views
  - editable: boolean indicating whether the current view renders the alias form
- Validation rules:
  - management views must always render either `alias_text` or the fallback string
  - management views must continue to display `client_identifier` regardless of alias presence
- Relationships:
  - Rendered on the admin clients index for every row
  - Rendered on the admin client detail page alongside the dedicated alias form

## Derived Constraints

- Alias is informational only and must not affect `client_identifier`, routing, or client progression behavior.
- Alias presence or absence must not change how `Client#reset_progression!` works.
- Existing clients with no alias remain valid records and must render correctly with the fallback presentation.
