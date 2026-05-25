# Tasks: Client Alias Management

**Input**: Design documents from `/specs/005-client-alias/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/admin-client-alias-contract.md, quickstart.md

**Tests**: Automated tests are required by the constitution for alias normalization, admin create and update flows, and user-visible alias rendering in the client management UI.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently after the shared alias plumbing is in place.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (e.g. [US1], [US2], [US3])
- Every task includes an exact file path; timestamped Rails migrations may use the concrete filename convention `db/migrate/YYYYMMDDHHMMSS_add_alias_to_clients.rb`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared test data and regression scaffolding for aliased and unaliased client records.

- [X] T001 [P] Extend representative aliased and unaliased client fixture coverage in test/fixtures/clients.yml
- [X] T002 [P] Add shared alias-oriented setup and assertions for admin client flows in test/controllers/admin/clients_controller_test.rb and test/system/clients_management_test.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the persisted alias field and shared request plumbing used by every user story.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [X] T003 Add the nullable client alias column migration in db/migrate/YYYYMMDDHHMMSS_add_alias_to_clients.rb
- [X] T004 Implement alias normalization and maximum-length validation on the trimmed alias value in app/models/client.rb
- [X] T005 Enable alias parameter handling and the PATCH update route in config/routes.rb and app/controllers/admin/clients_controller.rb

**Checkpoint**: Alias persistence and request plumbing are ready for story implementation.

---

## Phase 3: User Story 1 - Create a client with an alias (Priority: P1) 🎯 MVP

**Goal**: Let administrators optionally enter an alias during client creation and see the saved alias or fallback text immediately on the resulting detail page.

**Independent Test**: Create one client with a valid alias and one client without an alias, then confirm both saves succeed and the detail page shows either the saved alias or the exact fallback text.

### Tests for User Story 1 ⚠️

- [X] T006 [P] [US1] Add model coverage for alias trimming, whitespace-only input, trimmed-length overflow rejection, and duplicate alias allowance in test/models/client_test.rb
- [X] T007 [P] [US1] Add controller coverage for create with alias, blank alias, and invalid alias input in test/controllers/admin/clients_controller_test.rb
- [X] T008 [P] [US1] Add system coverage for creating clients with and without aliases from the new-client form in test/system/clients_management_test.rb

### Implementation for User Story 1

- [X] T009 [US1] Capture optional alias input and preserve validation feedback on create in app/controllers/admin/clients_controller.rb and app/views/admin/clients/new.html.erb
- [X] T010 [US1] Render the saved alias or the exact fallback text on the client detail page in app/views/admin/clients/show.html.erb

### UX and Performance Validation for User Story 1

- [X] T011 [US1] Validate new-form copy, fallback messaging, create success flash, validation error rendering, and create-to-detail responsiveness in test/system/clients_management_test.rb
- [X] T012 [US1] Capture and document the 20-run manual timing evidence for creation confirmation under 2 seconds, measured from create-form submission to visible confirmation, in specs/005-client-alias/verification-evidence.md

**Checkpoint**: User Story 1 should now be independently functional and demonstrable as the MVP.

---

## Phase 4: User Story 2 - Update an existing client alias (Priority: P2)

**Goal**: Let administrators add, change, or clear an alias from a dedicated form on the client detail page without affecting the client identifier or progression state.

**Independent Test**: Open an existing client detail page, update the alias, save it, then clear it and confirm the detail page reflects the new alias and later the fallback text.

### Tests for User Story 2 ⚠️

- [X] T013 [P] [US2] Add controller coverage for alias update, trimming, clearing, and invalid update attempts in test/controllers/admin/clients_controller_test.rb
- [X] T014 [P] [US2] Add system coverage for add, change, clear, success flash, and validation-error states from the detail-page alias form in test/system/clients_management_test.rb

### Implementation for User Story 2

- [X] T015 [US2] Implement alias update persistence and invalid-state re-rendering in app/controllers/admin/clients_controller.rb
- [X] T016 [US2] Add the dedicated alias edit form and update feedback states on the detail page in app/views/admin/clients/show.html.erb

### UX and Performance Validation for User Story 2

- [X] T017 [US2] Validate immediate alias refresh, preserved destructive-action confirmations, and under-2-second update responsiveness in test/system/clients_management_test.rb

**Checkpoint**: User Stories 1 and 2 should both work independently, including alias edits over time.

---

## Phase 5: User Story 3 - Identify clients by alias in management views (Priority: P3)

**Goal**: Show aliases consistently in the client list and detail page while keeping the client identifier visible and using one fallback string for unlabeled clients.

**Independent Test**: Visit the client list and detail page for clients with and without aliases and confirm the alias display, fallback copy, and client identifier visibility match the saved state.

### Tests for User Story 3 ⚠️

- [X] T018 [P] [US3] Add controller assertions for alias and fallback visibility on index and show responses in test/controllers/admin/clients_controller_test.rb
- [X] T019 [P] [US3] Add system coverage for identifier-preserving alias visibility, empty-state continuity, and list/detail fallback rendering in test/system/clients_management_test.rb

### Implementation for User Story 3

- [X] T020 [US3] Render alias and fallback text alongside client identifiers in the clients table in app/views/admin/clients/index.html.erb
- [X] T021 [US3] Keep alias presentation consistent between detail and list views in app/views/admin/clients/show.html.erb and app/views/admin/clients/index.html.erb

### UX and Performance Validation for User Story 3

- [X] T022 [US3] Validate list and detail fallback states plus representative 500-client responsiveness guidance in test/system/clients_management_test.rb and specs/005-client-alias/quickstart.md

**Checkpoint**: All three user stories should now be independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize release-facing verification guidance and run the documented validation set.

- [X] T023 [P] Reconcile the final manual verification and performance notes with the implemented alias behavior in specs/005-client-alias/quickstart.md
- [X] T024 [P] Record the retained timing evidence for SC-004 and SC-005 in specs/005-client-alias/verification-evidence.md
- [X] T025 Run the targeted model, controller, and system validation commands documented in specs/005-client-alias/quickstart.md
- [X] T026 Run linting for the touched Ruby files using the command documented in specs/005-client-alias/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** starts immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks all user stories.
- **Phase 3: User Story 1** depends on Phase 2 and delivers the MVP.
- **Phase 4: User Story 2** depends on Phase 2 and extends the detail workflow with alias editing.
- **Phase 5: User Story 3** depends on Phase 2 and completes the management-view visibility requirements.
- **Phase 6: Polish** depends on the user stories required for release.

### User Story Dependencies

- **US1 (P1)**: No dependency on other user stories once alias persistence and routing are in place.
- **US2 (P2)**: Depends on the shared alias plumbing from Phase 2 and reuses the detail-page presentation introduced in US1, but remains independently testable through the update and clear flow.
- **US3 (P3)**: Depends on the shared alias plumbing from Phase 2 and completes list/detail visibility behavior after alias capture exists.

### Within Each User Story

- Tests MUST be written and fail before implementation is considered complete.
- Model or controller behavior should be in place before the corresponding view wiring for the same story.
- Story-specific UX and performance validation follows implementation before the story is considered done.

### Parallel Opportunities

- T001 and T002 can run in parallel in the setup phase.
- T004 and T005 can proceed in parallel after T003 is defined if migration naming is settled.
- T006, T007, and T008 can run in parallel within US1.
- T013 and T014 can run in parallel within US2.
- T018 and T019 can run in parallel within US3.
- T023 and T024 can run in parallel with the final validation execution tasks once implementation is complete.

---

## Parallel Example: User Story 1

```bash
# Launch US1 regression work together
Task: "Add model coverage for alias trimming, whitespace-only input, trimmed-length overflow rejection, and duplicate alias allowance in test/models/client_test.rb"
Task: "Add controller coverage for create with alias, blank alias, and invalid alias input in test/controllers/admin/clients_controller_test.rb"
Task: "Add system coverage for creating clients with and without aliases from the new-client form in test/system/clients_management_test.rb"
```

---

## Parallel Example: User Story 3

```bash
# Launch US3 verification work together
Task: "Add controller assertions for alias and fallback visibility on index and show responses in test/controllers/admin/clients_controller_test.rb"
Task: "Add system coverage for identifier-preserving alias visibility, empty-state continuity, and list/detail fallback rendering in test/system/clients_management_test.rb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate alias create behavior independently on the new and detail pages.
5. Demo the MVP before expanding to alias editing and broader visibility work.

### Incremental Delivery

1. Build the shared alias schema, validation, and routing foundation.
2. Deliver US1 for alias capture during client creation.
3. Deliver US2 for alias editing and clearing on the detail page.
4. Deliver US3 for consistent list and detail visibility.
5. Finish with quickstart alignment, focused automated validation, and linting.

### Parallel Team Strategy

1. One developer can prepare fixture and regression scaffolding while another drafts the migration and model validation.
2. After Phase 2, one developer can focus on create-flow tests and UI while another prepares the update-flow regression coverage.
3. Once detail-page behavior is stable, list-view visibility and quickstart reconciliation can proceed in parallel.

---

## Notes

- `[P]` tasks target different files or independent verification work.
- `[US1]`, `[US2]`, and `[US3]` map each task to an independently testable user story.
- The migration task uses the conventional Rails timestamped filename pattern in db/migrate/YYYYMMDDHHMMSS_add_alias_to_clients.rb.
- Timing evidence for manual performance validation is stored in specs/005-client-alias/verification-evidence.md.
- Final validation must cover both functional behavior and the documented under-2-second responsiveness target.
