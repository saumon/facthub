# Tasks: Next Fact by Client

**Input**: Design documents from `/specs/002-next-fact-client/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Automated tests are required by the project constitution for the API contract, sequencing logic, admin flows, and concurrency-sensitive progression behavior.

**Organization**: Tasks are grouped by user story so each story can be implemented, tested, and demonstrated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the shared persistence and test scaffolding needed by all stories.

- [X] T001 Create the eligible clients table migration in db/migrate/*_create_clients.rb
- [X] T002 [P] Add the Client model scaffold with generated identifier and cursor fields in app/models/client.rb
- [X] T003 [P] Add shared eligible-client fixture data in test/fixtures/clients.yml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared routing and service skeletons required before any story work begins.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [X] T004 Wire the shared API and admin client route skeletons in config/routes.rb
- [X] T005 [P] Create the transactional next-fact service scaffold in app/services/client_next_fact_resolver.rb
- [X] T006 [P] Add the next-fact action scaffold to the public controller in app/controllers/api/facts_controller.rb
- [X] T007 [P] Add the authenticated admin client controller scaffold in app/controllers/admin/clients_controller.rb

**Checkpoint**: Shared model, service, routes, and controller entry points are ready for story implementation.

---

## Phase 3: User Story 1 - Retrieve the next fact for a known client (Priority: P1) 🎯 MVP

**Goal**: Serve facts in canonical order for a known client, persist per-client progression, wrap at the end of the catalog, and preserve correctness under same-client concurrency.

**Independent Test**: Create an eligible client, call `GET /api/facts/next?client_id=...` repeatedly, verify ascending fact order, wrap-around after the final fact, and distinct consecutive results for concurrent requests when enough facts exist.

### Tests for User Story 1 ⚠️

- [X] T008 [P] [US1] Add sequencing and wrap-around tests in test/models/client_next_fact_resolver_test.rb
- [X] T009 [P] [US1] Add successful ordered retrieval and empty-catalog request tests in test/controllers/api/facts_controller_test.rb
- [X] T010 [P] [US1] Add same-client concurrency regression coverage in test/integration/client_progression_concurrency_test.rb

### Implementation for User Story 1

- [X] T011 [US1] Implement canonical ordering, wrap-around, deleted-fact skip, and atomic cursor updates in app/services/client_next_fact_resolver.rb
- [X] T012 [US1] Implement successful `GET /api/facts/next` and no-facts responses in app/controllers/api/facts_controller.rb
- [X] T013 [US1] Finalize client cursor persistence helpers and reset baseline semantics in app/models/client.rb
- [X] T014 [US1] Document the successful and no-facts next-fact responses in docs/openapi.yml

### UX and Performance Validation for User Story 1

- [X] T015 [US1] Validate ordered retrieval, wrap-around, and empty-catalog behavior in specs/002-next-fact-client/quickstart.md
- [X] T016 [US1] Add a reproducible latency-budget verification for `GET /api/facts/next` in test/controllers/api/facts_controller_test.rb or test/integration/client_progression_concurrency_test.rb and document the execution command in specs/002-next-fact-client/quickstart.md

**Checkpoint**: User Story 1 should now be independently functional and demonstrable.

---

## Phase 4: User Story 2 - Reject unknown clients (Priority: P2)

**Goal**: Reject calls made without a valid eligible client identifier and return explicit error responses without serving any fact.

**Independent Test**: Call `GET /api/facts/next` with a missing identifier, an unknown identifier, and a previously deleted client identifier; verify clear non-success responses and no fact payload.

### Tests for User Story 2 ⚠️

- [X] T017 [P] [US2] Add missing, unknown, and deleted-client request tests in test/controllers/api/facts_controller_test.rb
- [X] T018 [P] [US2] Add deleted-client invalidation coverage in test/models/client_test.rb

### Implementation for User Story 2

- [X] T019 [US2] Implement missing-client and unknown-client error handling in app/controllers/api/facts_controller.rb
- [X] T020 [US2] Ensure deleted clients are no longer resolvable by identifier in app/models/client.rb
- [X] T021 [US2] Document missing-client and unknown-client error responses in docs/openapi.yml

### UX and Performance Validation for User Story 2

- [X] T022 [US2] Validate missing-client and unknown-client quickstart flows in specs/002-next-fact-client/quickstart.md
- [X] T023 [US2] Validate missing-client and unknown-client error-path latency using the documented verification command and record the result in specs/002-next-fact-client/quickstart.md

**Checkpoint**: User Stories 1 and 2 should both work independently, with the endpoint serving only known clients.

---

## Phase 5: User Story 3 - Administer eligible clients and their progress (Priority: P3)

**Goal**: Allow authenticated admins to create eligible clients, inspect/copy identifiers, view progression, reset progression, and delete clients without exposing management actions publicly.

**Independent Test**: Sign in as admin, create a client, copy its identifier, verify its progression after API calls, reset it, and delete it from the admin interface; confirm all client management remains inaccessible without authentication.

### Tests for User Story 3 ⚠️

- [X] T024 [P] [US3] Add authenticated admin client controller coverage in test/controllers/admin/clients_controller_test.rb
- [X] T025 [P] [US3] Add system coverage for client creation, identifier visibility, reset, and delete in test/system/clients_management_test.rb

### Implementation for User Story 3

- [X] T026 [US3] Implement authenticated admin client management actions in app/controllers/admin/clients_controller.rb
- [X] T027 [P] [US3] Build the admin client list with empty-state UI, visible client identifier, and current progression state in app/views/admin/clients/index.html.erb
- [X] T028 [P] [US3] Build the authenticated client creation form in app/views/admin/clients/new.html.erb
- [X] T029 [P] [US3] Build the client detail view with identifier copy and progression display in app/views/admin/clients/show.html.erb
- [X] T030 [US3] Add reset, destroy, and admin navigation affordances in app/views/admin/clients/index.html.erb and app/views/layouts/admin.html.erb
- [X] T031 [US3] Finalize authenticated client management routing and controller inheritance in config/routes.rb and app/controllers/admin/clients_controller.rb

### UX and Performance Validation for User Story 3

- [X] T032 [US3] Validate authenticated-only access, list-level progression visibility, empty states, and success feedback in specs/002-next-fact-client/quickstart.md
- [X] T033 [US3] Validate admin workflow timing and progression walkthrough notes in specs/002-next-fact-client/quickstart.md

**Checkpoint**: All three user stories should now be independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final documentation, regression hardening, and feature-wide validation.

- [X] T034 [P] Update the English feature description and changelog entry in README.md
- [X] T035 [P] Add integrated regression assertions across API and admin flows in test/controllers/api/facts_controller_test.rb and test/system/clients_management_test.rb
- [X] T036 [P] Reconcile end-to-end verification notes with the final implementation in specs/002-next-fact-client/quickstart.md
- [X] T037 Run the full validation workflow and record final readiness notes in specs/002-next-fact-client/quickstart.md
- [X] T038 [P] Measure `GET /api/facts/next` against SC-001 with the documented validation command and record the observed result in specs/002-next-fact-client/quickstart.md
- [X] T039 [P] Verify the implemented `GET /api/facts/next` behavior against specs/002-next-fact-client/contracts/GET_api_facts_next.md during final validation

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) starts immediately.
- Foundational (Phase 2) depends on Setup completion and blocks all user stories.
- User Stories 1, 2, and 3 all depend on Foundational completion.
- Polish (Phase 6) depends on completion of the desired user stories.

### User Story Dependencies

- User Story 1 (P1) starts after Phase 2 and delivers the MVP.
- User Story 2 (P2) starts after Phase 2 and extends the same endpoint with rejection behavior; it should remain testable without the admin UI.
- User Story 3 (P3) starts after Phase 2 and depends on the shared client model but not on public random-fact behavior.

### Within Each User Story

- Write tests first and verify they fail before implementation.
- Complete service and model behavior before controller and view wiring.
- Finish validation tasks before considering the story complete.

### Parallel Opportunities

- T002 and T003 can run in parallel after T001.
- T005, T006, and T007 can run in parallel after T004.
- T008, T009, and T010 can run in parallel within US1.
- T017 and T018 can run in parallel within US2.
- T024 and T025 can run in parallel within US3.
- T027, T028, and T029 can run in parallel after T026.
- T034, T035, T036, T038, and T039 can run in parallel in the polish phase.

---

## Parallel Example: User Story 1

```bash
# Launch User Story 1 test work together:
Task: "Add sequencing and wrap-around tests in test/models/client_next_fact_resolver_test.rb"
Task: "Add successful ordered retrieval and empty-catalog request tests in test/controllers/api/facts_controller_test.rb"
Task: "Add same-client concurrency regression coverage in test/integration/client_progression_concurrency_test.rb"

# Launch parallel UI-free implementation work after the tests exist:
Task: "Implement canonical ordering, wrap-around, deleted-fact skip, and atomic cursor updates in app/services/client_next_fact_resolver.rb"
Task: "Finalize client cursor persistence helpers and reset baseline semantics in app/models/client.rb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate ordered retrieval, wrap-around, concurrency handling, and no-facts behavior.
5. Demo the MVP endpoint before expanding scope.

### Incremental Delivery

1. Deliver User Story 1 for the new public sequential endpoint.
2. Add User Story 2 to tighten endpoint access rules and error handling.
3. Add User Story 3 to expose authenticated admin client management.
4. Finish with README/changelog updates and full regression validation.

### Parallel Team Strategy

1. One developer completes Setup and Foundational tasks.
2. After Phase 2, one developer can focus on US1 while another prepares US3 tests and views.
3. US2 can be completed in parallel with late-stage US1 work because it mainly extends the same API contract and tests.

---

## Notes

- `[P]` tasks target different files and can be executed in parallel.
- `[US1]`, `[US2]`, and `[US3]` labels map each task to a specific user story.
- README and changelog work is intentionally explicit because the feature must be described in English.
- Client management must remain authenticated throughout implementation; no public admin shortcuts are acceptable.
