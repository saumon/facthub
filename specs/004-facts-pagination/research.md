# Research: Facts Pagination

## Decision 1: Use custom server-side pagination rather than adding a gem

- Decision: Implement pagination directly in the admin facts controller using a fixed page size of 10, total-count calculation, and `limit` plus `offset` queries.
- Rationale: The repository does not currently use a pagination library, the feature scope is limited to one admin index page, and the required behavior includes custom redirect rules for invalid page requests and CRUD return context that are simpler to express directly than through an extra dependency.
- Alternatives considered:
  - Add Pagy, Kaminari, or WillPaginate: rejected because the repository currently has no pagination gem and the behavior needed here is small, deterministic, and easy to test without increasing dependency surface.
  - Fetch all facts and paginate in memory: rejected because it scales worse and does unnecessary work on the render path.

## Decision 2: Clamp invalid page requests by redirecting to the nearest valid page

- Decision: Treat page numbers below range as requests for the first page and page numbers above range as requests for the last page, expressed as redirects to the nearest valid page URL.
- Rationale: This matches the approved clarification, preserves understandable navigation, and prevents broken or empty states when users manipulate the page parameter directly or when the data set changes between requests.
- Alternatives considered:
  - Render an explicit invalid-page error state: rejected because it adds friction to a routine list navigation flow.
  - Always redirect invalid pages to the first page: rejected because it loses context when the user was near the end of the list.

## Decision 3: Preserve pagination context across CRUD flows through page-aware redirects

- Decision: Carry the current page through create and edit success flows when that page still exists, and fall back to the nearest valid page after deletion shrinks the listing.
- Rationale: The clarification requires administrators to keep their place in the list whenever possible. This reduces unnecessary navigation after common maintenance actions and keeps the feature aligned with the admin workflow.
- Alternatives considered:
  - Always redirect back to the unpaginated index root: rejected because it discards context and becomes more disruptive as the list grows.
  - Always redirect to the page containing the affected fact: rejected because it creates more unpredictable post-action navigation and is not required by the clarified behavior.

## Decision 4: Extend the existing admin table design with lightweight pagination controls

- Decision: Add pagination controls directly within the current facts index view, reusing the existing Tailwind-based visual language, table layout, flash flow, and empty-state presentation.
- Rationale: The constitution requires user experience consistency. The admin facts page already has a clear header, table, and empty state, so pagination should appear as a focused extension rather than a new navigation pattern.
- Alternatives considered:
  - Build a standalone component system for pagination: rejected as disproportionate to a single-page feature.
  - Hide page position and rely only on arrows: rejected because the spec requires clear page position and total-page visibility.

## Decision 5: Cover pagination with controller and system tests, plus documentation validation

- Decision: Add controller-level tests for page boundary handling and redirect behavior, add system tests for user-visible navigation and CRUD context preservation, and verify the README changelog update in English for version 1.2.0.
- Rationale: The feature changes both request routing behavior and visible admin interaction, so a single test layer is not sufficient. The README change is explicitly requested and should ship as part of release-ready work.
- Alternatives considered:
  - Controller tests only: rejected because they would not prove the navigation controls and boundary states in the rendered UI.
  - System tests only: rejected because boundary redirects and parameter handling are faster and clearer to assert at controller level.
