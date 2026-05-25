# Quickstart: Facts Pagination

## Goal

Verify that the admin facts listing is paginated to 10 facts per page, preserves clear navigation at list boundaries, keeps CRUD return context on the same page when possible, and documents the feature in the English README changelog for version 1.2.0.

## Prerequisites

- Dependencies installed with bundle install
- Databases prepared with bin/setup or bin/rails db:prepare
- Seeded admin account available
- Development server running via bin/dev
- Enough facts in the database to cover at least three pages of results

## Prepare Test Data

Create at least 21 facts so the index spans three pages.

## Manual Verification Flow

1. Start the app with bin/dev.
2. Sign in at /admins/sign_in with the seeded admin account.
3. Open the admin facts index at /admin/facts.
4. Confirm that only 10 facts are visible on the first page and that the current page indicator is visible.
5. Use the next-page control and confirm that the second page shows the next group of facts.
6. Use the last-page control and confirm that the final page shows only the remaining facts.
7. Use the first-page control and confirm that the listing returns to the first page.

## Boundary Verification

1. Request /admin/facts?page=0 and confirm the response redirects and lands on page 1.
2. Request a page number above the valid range and confirm the response redirects and lands on the last valid page.
3. Confirm that first and previous controls are rendered as inactive spans (not links) on the first page.
4. Confirm that next and last controls are rendered as inactive spans (not links) on the last page.
5. Confirm that the UI shows an unambiguous "Page X of Y" indicator on a multi-page listing.
6. Reduce the total number of facts until only one page remains and confirm that no pagination controls are shown.

## CRUD Context Verification

1. Navigate to page 2 of the facts index.
2. Click Edit on a row — the back link should point to /admin/facts?page=2.
3. Save the edit and confirm the success flow returns to page 2.
4. Create a new fact from page 2 context and confirm the success flow returns to page 2 when that page is still valid.
5. Delete facts from the last page until that page becomes invalid and confirm the app redirects to the nearest valid page rather than showing an empty or broken state.

## Performance Verification

1. Run the focused admin facts controller test suite with the performance regression test.
2. Confirm that the dedicated performance regression coverage for GET /admin/facts passes under the documented 2-second budget.
3. Observed result: the paginated index consistently responds well under 2 seconds in the local SQLite-backed test environment using server-side limit/offset queries.

## Validation Commands

```bash
bundle exec rails test test/controllers/admin/facts_controller_test.rb
bundle exec rails test:system test/system/facts_management_test.rb
bundle exec rails test test/controllers/admin/facts_controller_test.rb -n "/performance/"
bundle exec rubocop app/controllers/admin/facts_controller.rb test/controllers/admin/facts_controller_test.rb test/system/facts_management_test.rb
```

- Use the controller test command to validate page slicing, redirects, and CRUD return behavior.
- Use the system test command to validate visible pagination controls, current-page and total-page indicators, and boundary behavior.
- Use the focused controller command to capture the paginated index performance regression coverage under the 2-second budget.
- Use the RuboCop command to validate the touched Ruby files before review.

## Automated Validation Targets

- Targeted controller tests for authentication, page clamping, and redirect behavior after create, update, and destroy — all implemented in test/controllers/admin/facts_controller_test.rb
- Targeted system tests for first or last navigation, page counts, visible current-page and total-page indicators, and invalid-page fallback behavior — all implemented in test/system/facts_management_test.rb
- Targeted controller-level performance regression coverage for the paginated admin facts index under the 2-second budget — test named "index performance is under 2 seconds"
- Lint validation with bundle exec rubocop passing on all touched files
- README v1.2.0 changelog entry for facts pagination — added to README.md under the new v1.2.0 section
