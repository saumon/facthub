# Tasks: Bulk Fact Import Setup

**Input**: Design documents from `/specs/003-admin-fact-import/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/admin-import-contract.md, quickstart.md

**Tests**: Automated tests are REQUIRED by the constitution for service behavior, admin endpoints, and the user-visible import flow.

**Organization**: Tasks are grouped by user story so each story can be implemented and verified independently after the shared foundation is in place.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g. [US1], [US2], [US3])
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the repository for the new setup import flow and background processing support.

- [X] T001 Wire and document the development worker process for background imports in Procfile.dev and bin/dev
- [X] T002 Add setup/import route skeletons in config/routes.rb
- [X] T003 [P] Create admin setup controller skeleton in app/controllers/admin/setup_controller.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the persistence and background-processing primitives that every user story relies on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Create migration for fact import runs and files in db/migrate/20260525_create_fact_import_runs_and_fact_import_files.rb
- [X] T005 [P] Add FactImportRun model in app/models/fact_import_run.rb
- [X] T006 [P] Add FactImportFile model in app/models/fact_import_file.rb
- [X] T007 Add model associations and any required dependent behavior in app/models/admin.rb
- [X] T008 Add import run creation/status controller actions in app/controllers/admin/setup_controller.rb
- [X] T009 [P] Implement base import orchestration service in app/services/fact_import_orchestrator.rb
- [X] T010 [P] Implement background job shell for import execution in app/jobs/fact_import_job.rb
- [X] T011 Add admin setup page shell and upload form in app/views/admin/setup/show.html.erb
- [X] T012 [P] Add setup navigation entry in app/views/layouts/admin.html.erb
- [X] T013 [P] Add Stimulus controller shell for import progress polling in app/javascript/controllers/import_controller.js

**Checkpoint**: Foundation ready. User stories can now be implemented and tested independently.

---

## Phase 3: User Story 1 - Importer de nouveaux facts en masse (Priority: P1) 🎯 MVP

**Goal**: Let an authenticated admin start one-or-many markdown imports from the setup menu and follow real-time progress until completion.

**Independent Test**: Open the setup page, upload one valid markdown file, observe a visible progress bar during processing, and confirm that new facts appear in the facts index when the run completes.

### Tests for User Story 1 ⚠️

- [X] T014 [P] [US1] Add service tests for valid markdown parsing and line-based progress updates in test/services/fact_import_orchestrator_test.rb
- [X] T015 [P] [US1] Add controller tests for creating import runs, owner-only status access, and polling status in test/controllers/admin/setup_controller_test.rb
- [X] T016 [P] [US1] Add system test for admin setup import with visible progress bar in test/system/fact_imports_test.rb

### Implementation for User Story 1

- [X] T017 [US1] Implement valid markdown parsing and import-run progress tracking in app/services/fact_import_orchestrator.rb
- [X] T018 [US1] Implement job execution flow and status transitions in app/jobs/fact_import_job.rb
- [X] T019 [US1] Implement create/status HTML and JSON behavior, including owner-only status access control, in app/controllers/admin/setup_controller.rb
- [X] T020 [US1] Build setup upload form, progress bar region, and terminal summary container in app/views/admin/setup/show.html.erb
- [X] T021 [US1] Implement polling, progress rendering, and terminal state handling in app/javascript/controllers/import_controller.js
- [X] T022 [US1] Expose admin-owned import run summaries and owner-scoped lookups for setup and facts pages in app/models/fact_import_run.rb

### UX and Performance Validation for User Story 1

- [X] T023 [US1] Validate setup loading, progress, success, and empty states in test/system/fact_imports_test.rb
- [X] T024 [US1] Add a large-file performance regression test for a 10,000-line valid import in test/services/fact_import_orchestrator_test.rb

**Checkpoint**: User Story 1 is independently functional and demonstrates the MVP import flow.

---

## Phase 4: User Story 2 - Eviter les doublons lors des imports (Priority: P2)

**Goal**: Ensure imports create only truly new facts and show the final counts of added versus ignored duplicates.

**Independent Test**: Import multiple valid files containing overlaps with each other and with existing facts, then verify that only new facts are inserted once and the summary displays accurate added/ignored counts.

### Tests for User Story 2 ⚠️

- [X] T025 [P] [US2] Add service tests for intra-file, inter-file, and existing-record deduplication in test/services/fact_import_orchestrator_test.rb
- [X] T026 [P] [US2] Add controller tests for duplicate-count summaries in test/controllers/admin/setup_controller_test.rb
- [X] T027 [P] [US2] Add system test for duplicate-aware multi-file import summary in test/system/fact_imports_test.rb

### Implementation for User Story 2

- [X] T028 [US2] Implement normalized batch deduplication and duplicate counters in app/services/fact_import_orchestrator.rb
- [X] T029 [US2] Persist per-file added and ignored duplicate counts in app/models/fact_import_file.rb
- [X] T030 [US2] Render aggregate added/ignored summaries and per-file result rows in app/views/admin/setup/show.html.erb
- [X] T031 [US2] Render duplicate-aware terminal summary updates in app/javascript/controllers/import_controller.js

### UX and Performance Validation for User Story 2

- [X] T032 [US2] Validate duplicate-only and mixed duplicate-result states in test/system/fact_imports_test.rb
- [X] T033 [US2] Measure duplicate-heavy import behavior against the documented 2-minute budget in test/services/fact_import_orchestrator_test.rb

**Checkpoint**: User Stories 1 and 2 both work independently, with accurate duplicate handling and reporting.

---

## Phase 5: User Story 3 - Etre guidé en cas de fichier invalide ou vide (Priority: P3)

**Goal**: Reject invalid, empty, malformed, or over-limit files with clear per-file feedback while preserving successful imports from other valid files in the same batch.

**Independent Test**: Upload a batch containing one valid file plus files that are empty, over 10,000 lines, or contain a non-title/non-bullet markdown line, then verify that invalid files are fully rejected with clear reasons and valid files still succeed.

### Tests for User Story 3 ⚠️

- [X] T034 [P] [US3] Add service tests for empty files, malformed markdown lines, and over-limit files in test/services/fact_import_orchestrator_test.rb
- [X] T035 [P] [US3] Add controller tests for per-file rejection payloads in test/controllers/admin/setup_controller_test.rb
- [X] T036 [P] [US3] Add system test for mixed valid/invalid batch feedback in test/system/fact_imports_test.rb

### Implementation for User Story 3

- [X] T037 [US3] Implement strict file validation rules and 10,000-line limit rejection in app/services/fact_import_orchestrator.rb
- [X] T038 [US3] Persist invalid and over-limit file statuses plus error messages in app/models/fact_import_file.rb
- [X] T039 [US3] Return file-level validation errors and terminal statuses in app/controllers/admin/setup_controller.rb
- [X] T040 [US3] Render per-file rejection reasons, empty-file feedback, and validation guidance in app/views/admin/setup/show.html.erb
- [X] T041 [US3] Render invalid-file and partial-success terminal states in app/javascript/controllers/import_controller.js

### UX and Performance Validation for User Story 3

- [X] T042 [US3] Validate empty-file, invalid-file, over-limit, and mixed-result user-facing states in test/system/fact_imports_test.rb
- [X] T043 [US3] Add service coverage for progress accounting when files are rejected early in test/services/fact_import_orchestrator_test.rb

**Checkpoint**: All three user stories are independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize documentation, cleanup, and full-flow verification across all stories.

- [X] T044 [P] Update English README feature documentation and add v1.2.0 changelog entry in README.md
- [X] T045 [P] Add representative import fixtures for service and system tests in test/fixtures/files/facts_import_valid.md
- [X] T046 [P] Add representative invalid and duplicate-heavy import fixtures in test/fixtures/files/facts_import_invalid.md
- [X] T047 Run focused unit, controller, and system validation commands documented in specs/003-admin-fact-import/quickstart.md
- [X] T048 Run linting for touched Ruby and JavaScript files with bundle exec rubocop

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** has no dependencies and can start immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks all user stories.
- **Phase 3: User Story 1** depends on Phase 2 and delivers the MVP.
- **Phase 4: User Story 2** depends on Phase 2 and can begin after the foundation, though it builds most naturally on top of the US1 import flow.
- **Phase 5: User Story 3** depends on Phase 2 and can begin after the foundation, though it shares setup controller and service surfaces with US1.
- **Phase 6: Polish** depends on the user stories required for release.

### User Story Dependencies

- **US1 (P1)**: No dependency on other user stories once foundation is ready.
- **US2 (P2)**: Depends on the shared import flow from foundation; it extends US1 result accounting but remains independently testable through duplicate-specific fixtures.
- **US3 (P3)**: Depends on the shared import flow from foundation; it extends validation and error reporting but remains independently testable with invalid fixtures.

### Within Each User Story

- Tests MUST be written and fail before implementation is considered complete.
- Service and model logic precede controller/view/UI wiring for the same slice.
- Controller and UI integration precede UX/performance validation tasks.

### Parallel Opportunities

- T003 can run in parallel with T001-T002.
- T005, T006, T009, T010, T012, and T013 can run in parallel after T004 where applicable.
- Within each story, the listed test tasks marked [P] can run in parallel.
- README documentation and test fixture tasks in Phase 6 can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Launch US1 test work together
Task: "Add service tests for valid markdown parsing and line-based progress updates in test/services/fact_import_orchestrator_test.rb"
Task: "Add controller tests for creating import runs and polling status in test/controllers/admin/setup_controller_test.rb"
Task: "Add system test for admin setup import with visible progress bar in test/system/fact_imports_test.rb"

# Launch independent UI/backend slices after the tests exist
Task: "Build setup upload form, progress bar region, and terminal summary container in app/views/admin/setup/show.html.erb"
Task: "Implement polling, progress rendering, and terminal state handling in app/javascript/controllers/import_controller.js"
```

---

## Parallel Example: User Story 2

```bash
# Launch US2 test work together
Task: "Add service tests for intra-file, inter-file, and existing-record deduplication in test/services/fact_import_orchestrator_test.rb"
Task: "Add controller tests for duplicate-count summaries in test/controllers/admin/setup_controller_test.rb"
Task: "Add system test for duplicate-aware multi-file import summary in test/system/fact_imports_test.rb"
```

---

## Parallel Example: User Story 3

```bash
# Launch US3 test work together
Task: "Add service tests for empty files, malformed markdown lines, and over-limit files in test/services/fact_import_orchestrator_test.rb"
Task: "Add controller tests for per-file rejection payloads in test/controllers/admin/setup_controller_test.rb"
Task: "Add system test for mixed valid/invalid batch feedback in test/system/fact_imports_test.rb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate the single-file import flow, visible progress bar, and facts availability.
5. Demo or ship the MVP if duplicate/error refinements are intentionally deferred.

### Incremental Delivery

1. Build Setup + Foundational to establish import tracking and background execution.
2. Deliver US1 for the end-to-end import flow with progress.
3. Deliver US2 for accurate duplicate prevention and end-of-run reporting.
4. Deliver US3 for strict invalid-file handling and user guidance.
5. Finish with README/changelog updates and full validation.

### Parallel Team Strategy

1. One developer handles migration/models/job foundation.
2. One developer handles controller/view/Stimulus setup surfaces.
3. After foundation, one developer can focus on duplicate accounting while another handles invalid-file and validation flows.

---

## Notes

- [P] tasks are designed for different files or independently executable test slices.
- User story labels map each task to an independently testable increment.
- README documentation is part of the release scope, not optional polish.
- The final validation must cover both behavior and the 10,000-line performance budget.
