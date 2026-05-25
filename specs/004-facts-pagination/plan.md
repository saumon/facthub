# Implementation Plan: Facts Pagination

**Branch**: `[004-facts-pagination]` | **Date**: 2026-05-25 | **Spec**: [spec.md](/Users/robu/work/projects/facthub/specs/004-facts-pagination/spec.md)
**Input**: Feature specification from `/specs/004-facts-pagination/spec.md`

## Summary

Add pagination to the admin facts listing so authenticated administrators see at most 10 facts per page, can move to the previous and next pages, and can jump directly to the first and last pages. The implementation will use custom controller-level pagination and explicit page-boundary redirects within the existing Rails admin stack, preserve CRUD return context on the same page when valid, and include an English README changelog entry for version 1.2.0.

## Technical Context

**Language/Version**: Ruby 3.2+ on Ruby on Rails 8.1.3  
**Primary Dependencies**: Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3  
**Storage**: SQLite 3 application database with existing facts table; no new persisted entities expected  
**Testing**: Minitest controller/integration tests and Capybara system tests  
**Target Platform**: Server-rendered web application for macOS/Linux development and Rails-supported deployment targets
**Project Type**: Monolithic Rails web application with admin UI and public API  
**Performance Goals**: Facts index page loads stay under 2 seconds in normal admin usage and render pagination state immediately without client-side waiting  
**Constraints**: Must preserve existing admin UX patterns, keep redirects understandable at pagination boundaries, avoid adding a pagination gem for a simple 10-item page size, and update the README changelog in English for version 1.2.0  
**Scale/Scope**: One existing admin index page, one pagination control set, one README changelog entry, admin-only usage with datasets large enough to span multiple pages

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Check

- Code quality: Changes stay scoped to the existing admin facts controller, facts index view, helper/private pagination methods if needed, route-preserving redirects, focused tests, and README documentation. Validation gates are `bundle exec rubocop`, targeted Rails tests for admin facts, and review of touched slices only.
- Testing: Required automated coverage includes controller tests for page clamping and redirect behavior, plus system tests for multi-page navigation, boundary controls, and CRUD return-to-page behavior. Validation commands will include focused `bundle exec rails test` and targeted `bundle exec rails test:system` runs.
- UX consistency: The paginated facts index must preserve the current admin layout, table styling, flash messaging, empty state, and action affordances. New controls must match existing Tailwind-based patterns and remain understandable without introducing a new interaction model.
- Performance: The critical path is the admin facts index render. Explicit budget is page load under 2 seconds during normal usage, with pagination computed server-side using bounded queries and simple count math. Validation will combine automated tests for boundary logic and manual/system verification of navigation responsiveness.

### Post-Design Check

- Code quality: Pass. The design keeps pagination logic in the owning controller/view slice and avoids introducing a dependency for trivial page math.
- Testing: Pass. The design names controller and system coverage for the precise user-visible behaviors and redirect edge cases.
- UX consistency: Pass. The pagination controls extend the existing admin table view and preserve empty, success, and boundary states already used in the admin interface.
- Performance: Pass. Custom `limit`/`offset` pagination with a total-count calculation is sufficient for the expected admin-only scale and keeps the response path measurable against the stated budget.

## Project Structure

### Documentation (this feature)

```text
specs/004-facts-pagination/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── admin-facts-pagination-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── admin/
├── views/
│   └── admin/
└── helpers/

config/
└── routes.rb

test/
├── controllers/
└── system/

README.md
```

**Structure Decision**: Use the existing monolithic Rails application structure. Pagination logic belongs in `app/controllers/admin/facts_controller.rb` and the existing facts index template under `app/views/admin/facts`, with optional helper extraction only if the view needs it for readability. Focused regression coverage stays in the current Minitest controller and system test suites, and release-facing documentation is updated in `README.md` under the English changelog for v1.2.0.

## Implementation Outline

### Phase 0 Output

- Research captured in [research.md](/Users/robu/work/projects/facthub/specs/004-facts-pagination/research.md)

### Phase 1 Design Output

- Data model captured in [data-model.md](/Users/robu/work/projects/facthub/specs/004-facts-pagination/data-model.md)
- Admin flow contract captured in [contracts/admin-facts-pagination-contract.md](/Users/robu/work/projects/facthub/specs/004-facts-pagination/contracts/admin-facts-pagination-contract.md)
- Verification guide captured in [quickstart.md](/Users/robu/work/projects/facthub/specs/004-facts-pagination/quickstart.md)

### Planned Implementation Slices

1. Add controller-side pagination state calculation for the admin facts index with a fixed page size of 10 and explicit clamping or redirect behavior for out-of-range page requests.
2. Update the facts index UI to show page position, previous or next controls, and direct first or last navigation while preserving the existing empty state and row actions.
3. Preserve CRUD navigation context by returning create and edit flows to the same page when valid and falling back to the nearest valid page after deletions.
4. Add controller tests for authentication, pagination boundaries, redirect rules, and CRUD redirect behavior with page context.
5. Add system tests for multi-page browsing, first or last navigation, boundary control visibility, and deletion from the last page.
6. Update the English README changelog with a v1.2.0 entry for facts pagination.

## Complexity Tracking

No constitution exceptions are currently required.
