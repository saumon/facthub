# Data Model: Facts Pagination

## Fact

- Purpose: Existing persisted fun fact shown in the admin management table and editable through CRUD actions.
- Fields:
  - id: integer, primary key
  - body: string, required, unique
  - created_at / updated_at: timestamps
- Validation rules:
  - body must be present
  - body must be unique according to the existing model behavior
  - body length constraints remain unchanged from the current application
- Relationships:
  - Rendered as one row inside a paginated facts listing page

## PaginationState

- Purpose: Derived request-scoped state used to determine which subset of facts is shown and which navigation controls are active.
- Fields:
  - requested_page: integer derived from the incoming params value
  - current_page: integer, always within the valid range after clamping or redirect
  - per_page: integer, fixed at 10 for this feature
  - total_count: integer, total number of persisted facts available to the listing
  - total_pages: integer, derived from total_count and per_page with a minimum logical floor for valid navigation decisions
  - previous_page: integer or nil when the current page is the first valid page
  - next_page: integer or nil when the current page is the last valid page
  - first_page: integer constant representing the first valid page
  - last_page: integer representing the final valid page for the current total_count
- Validation rules:
  - current_page must never be below first_page
  - current_page must never exceed last_page when facts exist
  - previous_page and next_page are only present when navigation to those pages is valid
- Relationships:
  - Determines the query window used to fetch the Facts Slice
  - Drives the active or inactive state of pagination controls in the UI

## FactsSlice

- Purpose: The ordered subset of facts rendered for one page of the admin listing.
- Fields:
  - facts: ordered collection of up to 10 Fact records
  - count: integer between 0 and 10
  - offset: derived integer indicating where the slice starts in the overall ordered listing
- Validation rules:
  - count must never exceed 10
  - facts must preserve the global listing order defined by the controller query
- Relationships:
  - Belongs to one PaginationState
  - Supplies the rows and action links displayed on the facts index page

## RedirectOutcome

- Purpose: Derived navigation result used when the requested page is invalid or a CRUD action changes which pages are valid.
- Fields:
  - source_action: one of direct_index_request, create_success, update_success, destroy_success
  - target_page: integer resolved from the current valid page range
  - reason: one of below_range, above_range, current_page_still_valid, current_page_removed_after_delete
- Validation rules:
  - target_page must always point to a valid page for the current total_count
- Relationships:
  - Computed from PaginationState and the post-action total facts count

## Derived Metrics

- Total pages: `(total_count / 10.0).ceil`, with invalid request handling still resolving to a valid page outcome
- Page range label: current page over total pages for the rendered view
- Last-page remainder: `total_count % 10`, where zero indicates a full final page when facts exist
