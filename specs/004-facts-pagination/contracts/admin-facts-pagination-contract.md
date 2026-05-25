# Contract: Admin Facts Pagination

## Purpose

Define the admin-facing HTTP and UI contract for the paginated facts index and its CRUD return behavior.

## Routes

### GET /admin/facts

- Authentication: Required admin session
- Query parameters:
  - page: optional positive integer identifying the requested listing page
- Purpose: Render the facts management index with a maximum of 10 facts on the current page and expose valid navigation controls.
- Success behavior:
  - HTTP 200 OK when the request already targets a valid page
  - HTML responsibilities:
    - Show the existing facts table for the current page slice
    - Show the total count or page-position summary needed to understand navigation state
    - Show previous and next controls only when those pages exist
    - Show direct first and last controls only when more than one page exists
    - Preserve the current empty state when there are no facts
- Redirect behavior:
  - If `page` is below the valid range, redirect to `/admin/facts?page=1`
  - If `page` is above the valid range, redirect to the last valid page

### POST /admin/facts

- Authentication: Required admin session
- Purpose: Create a new fact from the admin form
- Success behavior:
  - Redirect back to the same paginated facts index page when that page remains valid
  - Preserve the success flash notice already used by the admin flow
- Failure behavior:
  - Re-render the form with validation errors and `422 Unprocessable Entity`

### PATCH /admin/facts/:id

- Authentication: Required admin session
- Purpose: Update an existing fact from the admin form
- Success behavior:
  - Redirect back to the same paginated facts index page when that page remains valid
  - Preserve the success flash notice already used by the admin flow
- Failure behavior:
  - Re-render the edit form with validation errors and `422 Unprocessable Entity`

### DELETE /admin/facts/:id

- Authentication: Required admin session
- Purpose: Delete a fact from the paginated admin index
- Success behavior:
  - Redirect back to the current page when it is still valid after deletion
  - If deletion removes the current page from the valid range, redirect to the nearest valid page, which becomes the last valid page in the reduced data set
  - Preserve the success flash notice already used by the admin flow

## UI Behavior Contract

- The facts index must render at most 10 rows per page.
- Pagination controls must indicate the current page and total number of pages when more than one page exists.
- First and previous controls must not appear active on the first page.
- Next and last controls must not appear active on the last page.
- The empty state must remain the existing "No fun facts yet" presentation when there are no facts.
- Edit and delete actions must remain available for each visible row on the current page.

## Documentation Contract

- README must include an English changelog entry under version 1.2.0 for facts pagination.
- The changelog entry should follow the existing README release format with a linked spec reference and concise English bullet points describing the admin pagination behavior.
