# Tasks: Facts Pagination

**Input**: Design documents from `/specs/004-facts-pagination/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/admin-facts-pagination-contract.md, quickstart.md

**Tests**: Automated tests are required by the constitution for admin listing behavior, pagination boundaries, CRUD redirect context, and the user-visible navigation flow.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently after the shared setup is in place.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (e.g. [US1], [US2], [US3])
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare representative data and test scaffolding for a multi-page admin facts index.

- [X] T001 Expand multi-page fact fixtures in test/fixtures/facts.yml
- [X] T002 [P] Add helper methods or fixture setup support for paginated facts assertions in test/controllers/admin/facts_controller_test.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared pagination state and page-parameter plumbing used by all user stories.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [X] T003 Implement shared page parsing, per-page sizing, and valid-page redirect helpers in app/controllers/admin/facts_controller.rb
- [X] T004 [P] Thread the current page parameter through facts index action links in app/views/admin/facts/index.html.erb
- [X] T005 [P] Preserve the current page parameter in the facts create and edit forms in app/views/admin/facts/new.html.erb and app/views/admin/facts/edit.html.erb

**Checkpoint**: Shared pagination state and page propagation are ready for story implementation.

---

## Phase 3: User Story 1 - Browse facts in manageable pages (Priority: P1) 🎯 MVP

**Goal**: Show the admin facts list in groups of 10 with reliable previous and next navigation while preserving the existing ordering and table actions.

**Independent Test**: Open the admin facts index with more than 10 facts, confirm that only 10 rows are shown on a page, then move forward and backward between adjacent pages without losing row actions or ordering.

### Tests for User Story 1 ⚠️

- [X] T006 [P] [US1] Add controller tests for 10-item page slices and adjacent page navigation in test/controllers/admin/facts_controller_test.rb
- [X] T007 [P] [US1] Add system coverage for previous and next navigation on the facts index in test/system/facts_management_test.rb

### Implementation for User Story 1

- [X] T008 [US1] Implement paginated facts queries and page summary assignment in app/controllers/admin/facts_controller.rb
- [X] T009 [US1] Render the paginated table with current-page, previous-page, and next-page controls in app/views/admin/facts/index.html.erb

### UX and Performance Validation for User Story 1

- [X] T010 [US1] Validate 10-row pagination, row action availability, and basic navigation responsiveness in test/system/facts_management_test.rb

**Checkpoint**: User Story 1 should now be independently functional and demonstrable.

---

## Phase 4: User Story 2 - Jump to the first or last page (Priority: P2)

**Goal**: Let administrators jump directly to the beginning or end of a multi-page facts list without stepping through each intermediate page.

**Independent Test**: Open a facts list spanning at least three pages, jump directly to the last page, verify the final remainder is shown, then jump directly back to the first page.

### Tests for User Story 2 ⚠️

- [X] T011 [P] [US2] Add controller tests for first-page and last-page navigation targets in test/controllers/admin/facts_controller_test.rb
- [X] T012 [P] [US2] Add system coverage for first-page and last-page controls plus the current-page and total-page indicator in test/system/facts_management_test.rb

### Implementation for User Story 2

- [X] T013 [US2] Expose first-page and last-page navigation state in app/controllers/admin/facts_controller.rb
- [X] T014 [US2] Render first-page and last-page controls with total-page context in app/views/admin/facts/index.html.erb

### UX and Performance Validation for User Story 2

- [X] T015 [US2] Validate first or last navigation visibility, final-page remainder behavior, and unambiguous current-page indicator text in test/system/facts_management_test.rb

**Checkpoint**: User Stories 1 and 2 should both work independently, with direct navigation to list boundaries.

---

## Phase 5: User Story 3 - Keep navigation coherent at boundaries (Priority: P3)

**Goal**: Keep pagination predictable on single-page lists, invalid page requests, and create, edit, or delete flows that must preserve or recover page context.

**Independent Test**: Verify that one-page lists do not expose invalid navigation, invalid page requests redirect to the nearest valid page, create and edit return to the same page, and deleting the last item on the last page falls back to the nearest valid page.

### Tests for User Story 3 ⚠️

- [X] T016 [P] [US3] Add controller tests for invalid page redirects and page-aware create, update, and destroy redirects in test/controllers/admin/facts_controller_test.rb
- [X] T017 [P] [US3] Add system coverage for single-page boundary states and delete fallback behavior in test/system/facts_management_test.rb

### Implementation for User Story 3

- [X] T018 [US3] Implement single-page boundary handling and page-aware create, update, and destroy redirects in app/controllers/admin/facts_controller.rb
- [X] T019 [P] [US3] Hide or disable boundary controls for first-page, last-page, and single-page states in app/views/admin/facts/index.html.erb
- [X] T020 [P] [US3] Preserve page-aware back navigation and form submission targets in app/views/admin/facts/new.html.erb and app/views/admin/facts/edit.html.erb

### UX and Performance Validation for User Story 3

- [X] T021 [US3] Validate empty-state, single-page, invalid-page, and post-delete fallback behavior in test/system/facts_management_test.rb

**Checkpoint**: All three user stories should now be independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize documentation and run release-oriented validation across the full feature.

- [X] T022 [P] Update the English README changelog entry for version 1.2.0 in README.md
- [X] T023 [P] Reconcile the final manual verification notes and explicit performance verification steps with the implemented pagination behavior in specs/004-facts-pagination/quickstart.md
- [X] T024 [P] Add controller-level performance regression coverage for GET /admin/facts against the under-2-second budget in test/controllers/admin/facts_controller_test.rb
- [X] T025 Run the explicit controller, system, and performance validation commands documented in specs/004-facts-pagination/quickstart.md
- [X] T026 Run linting for touched Ruby files with bundle exec rubocop

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** starts immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks all user stories.
- **Phase 3: User Story 1** depends on Phase 2 and delivers the MVP.
- **Phase 4: User Story 2** depends on Phase 2 and extends navigation on top of the paginated index.
- **Phase 5: User Story 3** depends on Phase 2 and finalizes boundary handling plus CRUD return behavior.
- **Phase 6: Polish** depends on completion of the user stories required for release.

### User Story Dependencies

- **US1 (P1)**: No dependency on other user stories once the shared pagination plumbing is ready.
- **US2 (P2)**: Depends on the paginated index from US1 but remains independently testable through first or last navigation behavior.
- **US3 (P3)**: Depends on the shared pagination state from Phase 2 and the visible controls from US1, then extends redirect and boundary behavior.

### Within Each User Story

- Tests MUST be written and fail before implementation is considered complete.
- Controller pagination state should be completed before the corresponding view wiring for the same story.
- Story-specific UX and performance validation follows implementation before the story is considered done.

### Parallel Opportunities

- T002 can run in parallel with T001.
- T004 and T005 can run in parallel after T003.
- T006 and T007 can run in parallel within US1.
- T011 and T012 can run in parallel within US2.
- T016 and T017 can run in parallel within US3.
- T019 and T020 can run in parallel after T018.
- T022, T023, and T024 can run in parallel in the polish phase.

---

## Parallel Example: User Story 1

```bash
# Launch US1 test work together
Task: "Add controller tests for 10-item page slices and adjacent page navigation in test/controllers/admin/facts_controller_test.rb"
Task: "Add system coverage for previous and next navigation on the facts index in test/system/facts_management_test.rb"
```

---

## Parallel Example: User Story 3

```bash
# Launch US3 test work together
Task: "Add controller tests for invalid page redirects and page-aware create, update, and destroy redirects in test/controllers/admin/facts_controller_test.rb"
Task: "Add system coverage for single-page boundary states and delete fallback behavior in test/system/facts_management_test.rb"

# Launch independent UI follow-up together after redirect logic exists
Task: "Hide or disable boundary controls for first-page, last-page, and single-page states in app/views/admin/facts/index.html.erb"
Task: "Preserve page-aware back navigation and form submission targets in app/views/admin/facts/new.html.erb and app/views/admin/facts/edit.html.erb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate 10-row paging and previous or next navigation independently.
5. Demo the MVP paginated facts index before expanding scope.

### Incremental Delivery

1. Build the shared pagination plumbing.
2. Deliver US1 for basic paginated browsing.
3. Deliver US2 for direct first or last jumps.
4. Deliver US3 for boundary safety and CRUD return context.
5. Finish with README v1.2.0 changelog work, explicit performance verification, and focused validation.

### Parallel Team Strategy

1. One developer can handle controller pagination logic while another prepares regression tests.
2. After Phase 2, one developer can complete US1 UI rendering while another prepares US2 navigation assertions.
3. US3 view work can proceed in parallel with README and quickstart updates once redirect logic is in place.

---

## Notes

- `[P]` tasks target different files or independent verification work.
- `[US1]`, `[US2]`, and `[US3]` map each task to an independently testable user story.
- README changelog work is explicit release scope for version 1.2.0 and not optional cleanup.
- Final validation must cover both behavior and an explicit under-2-second measurement for the admin listing path documented in the plan.
