# Contract: Admin Client Alias Management

## Purpose

Define the admin-facing HTTP and UI contract for creating, viewing, and updating client aliases.

## Routes

### GET /admin/clients

- Authentication: Required admin session
- Purpose: Render the client management index.
- Success behavior:
  - HTTP 200 OK
  - HTML responsibilities:
    - Show each client's generated identifier
    - Show each client's alias when present
    - Show the exact fallback text `No alias defined` when alias is absent
    - Keep the existing progression summary and action links available for each row

### GET /admin/clients/new

- Authentication: Required admin session
- Purpose: Render the new client form with optional alias entry.
- Success behavior:
  - HTTP 200 OK
  - HTML responsibilities:
    - Explain that the client identifier is generated automatically
    - Provide an optional alias input
    - Preserve the existing create and cancel affordances

### POST /admin/clients

- Authentication: Required admin session
- Request parameters:
  - `client[alias]`: optional string
- Purpose: Create a new client with an optional informational alias.
- Success behavior:
  - Alias input is normalized by trimming leading and trailing whitespace
  - Whitespace-only alias input is treated as empty
  - Client identifier is generated exactly as before
  - Redirect to `GET /admin/clients/:id`
  - Preserve the existing success flash notice for client creation unless product copy is intentionally updated
- Failure behavior:
  - Alias values whose trimmed length exceeds 100 characters under standard Rails length validation return `422 Unprocessable Entity`
  - Re-render the new client form with validation feedback and preserved alias input

### GET /admin/clients/:id

- Authentication: Required admin session
- Purpose: Render the client detail page.
- Success behavior:
  - HTTP 200 OK
  - HTML responsibilities:
    - Show the generated client identifier
    - Show the alias when present or the exact fallback text `No alias defined` when absent
    - Provide a dedicated alias form on the page
    - Preserve the existing progression, reset, and delete sections

### PATCH /admin/clients/:id

- Authentication: Required admin session
- Request parameters:
  - `client[alias]`: optional string
- Purpose: Add, change, or clear the alias from the dedicated form on the client detail page.
- Success behavior:
  - Alias input is normalized by trimming leading and trailing whitespace
  - Whitespace-only input clears the alias value
  - Redirect back to `GET /admin/clients/:id`
  - The saved alias state is immediately visible on the detail page and the clients index
  - Preserve existing flash-message conventions for successful admin mutations
- Failure behavior:
  - Alias values whose trimmed length exceeds 100 characters under standard Rails length validation return `422 Unprocessable Entity`
  - Re-render the detail page with validation feedback while preserving current progression information

## UI Behavior Contract

- The clients index must continue to display the opaque client identifier for every row.
- The alias must never replace or hide the client identifier in admin management views.
- The exact string `No alias defined` must be used consistently when alias is absent.
- The new-client screen must allow creation both with and without an alias.
- The detail page must allow alias add, change, and clear operations from a dedicated on-page form.
- Alias updates must become visible immediately after a successful save on both show and index screens.

## Data Contract

- Alias is optional and non-unique.
- Alias must not affect client progression state or API-facing identifiers.
- Alias normalization preserves internal whitespace while trimming only the edges of the submitted value.

## Out of Scope

- Public API changes
- Alias-based search, sorting, or filtering
- Alias history or audit tracking beyond existing record timestamps
