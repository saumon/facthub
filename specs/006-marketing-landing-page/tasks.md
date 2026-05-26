# Tasks: Facthub Marketing Landing Page

**Input**: Design documents from `/specs/006-marketing-landing-page/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/landing-page-contract.md, quickstart.md

**Tests**: Automated tests are REQUIRED for this feature. Each user story includes repository-level static-page verification, followed by manual responsive and performance validation where needed.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the static landing page workspace and shared test support.

- [x] T001 Create the static landing page file structure in docs/index.html and docs/assets/styles.css, leaving docs/assets/app.js optional until progressive enhancement is needed
- [x] T002 [P] Create shared static page assertions in test/support/static_landing_page_helper.rb
- [x] T003 Update test/test_helper.rb to load test/support/static_landing_page_helper.rb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the static contract, shared layout shell, and reusable theme primitives required by all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 Implement the base HTML document shell, metadata, relative asset links, and section anchors in docs/index.html
- [x] T005 [P] Implement shared design tokens, typography, layout utilities, and CTA/button primitives in docs/assets/styles.css
- [x] T006 [P] Add contract coverage for static entry point, relative asset paths, required no-server behavior, and core navigation/content availability without decorative assets in test/integration/docs_landing_page_contract_test.rb

**Checkpoint**: Foundation ready. User story work can now proceed in priority order or in parallel.

---

## Phase 3: User Story 1 - Understand the product quickly (Priority: P1) 🎯 MVP

**Goal**: Deliver a clear marketing narrative that explains Facthub's audience, purpose, and core value on first read.

**Independent Test**: Open docs/index.html directly in a browser and confirm a first-time visitor can identify the product purpose, audience, core features, and GitHub CTA without any backend running.

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T007 [US1] Add content assertions for hero messaging, English-only visible copy, feature highlights, and the primary repository CTA in test/integration/docs_landing_page_content_test.rb

### Implementation for User Story 1

- [x] T008 [US1] Implement the hero, feature highlights, proof/benefits, and primary CTA content in docs/index.html
- [x] T009 [US1] Add content-specific section styling and emphasis treatments for the marketing narrative in docs/assets/styles.css
- [x] T010 [US1] Validate the comprehension flow from specs/006-marketing-landing-page/quickstart.md against docs/index.html
- [x] T011 [US1] Measure first-visible content readiness against the plan budget for docs/index.html

**Checkpoint**: User Story 1 should now be fully functional and independently demonstrable as the MVP.

---

## Phase 4: User Story 2 - Review the page comfortably on any device (Priority: P2)

**Goal**: Make the landing page readable, navigable, and touch-friendly across laptop and smartphone viewports.

**Independent Test**: Open docs/index.html on desktop and mobile viewports, including a narrow mobile width, and confirm there is no horizontal scrolling, broken layout, or inaccessible CTA.

### Tests for User Story 2 ⚠️

- [x] T012 [US2] Add responsive contract assertions for viewport metadata, mobile-safe structure, and relative asset references in test/integration/docs_landing_page_responsive_test.rb

### Implementation for User Story 2

- [x] T013 [US2] Refine the page structure for responsive navigation and mobile-friendly section flow in docs/index.html
- [x] T014 [US2] Implement breakpoints, fluid spacing, and overflow protections for laptop and smartphone layouts in docs/assets/styles.css
- [x] T015 [US2] Add non-critical mobile interaction enhancements in docs/assets/app.js if progressive enhancement is needed
- [x] T016 [US2] Validate responsive behavior from specs/006-marketing-landing-page/quickstart.md against docs/index.html and docs/assets/styles.css
- [x] T017 [US2] Capture performance and interaction checks for docs/index.html after responsive enhancements

**Checkpoint**: User Stories 1 and 2 should both work independently, with the page remaining usable across supported viewport sizes.

---

## Phase 5: User Story 3 - Recognize a consistent brand and polished presentation (Priority: P3)

**Goal**: Make the landing page feel visually aligned with the admin interface while remaining polished and prospect-facing.

**Independent Test**: Compare docs/index.html against the admin UI references and confirm the landing page preserves the indigo gradient theme, card/button language, and clean hierarchy without feeling like an unrelated microsite.

### Tests for User Story 3 ⚠️

- [x] T018 [US3] Add theme and presentation assertions for admin-inspired styling hooks in test/integration/docs_landing_page_theme_test.rb

### Implementation for User Story 3

- [x] T019 [US3] Apply admin-inspired gradient, card, button, and typography styling refinements in docs/assets/styles.css
- [x] T020 [US3] Tune section hierarchy, visual rhythm, and supporting polish in docs/index.html
- [x] T021 [US3] Add optional decorative assets and supporting imagery in docs/assets/images/
- [x] T022 [US3] Validate visual consistency against app/views/layouts/admin.html.erb and docs/index.html
- [x] T023 [US3] Re-check render performance and degraded-asset readability for docs/index.html, docs/assets/styles.css, and docs/assets/app.js if present

**Checkpoint**: All user stories should now be independently functional, visually consistent, and ready for final cross-cutting review.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finish repository-wide validation, documentation, and cleanup that affect multiple user stories.

- [x] T024 [P] Update README.md to reference the static landing page published from docs/index.html
- [x] T025 Clean up unused styles, placeholder markup, and scripts in docs/index.html, docs/assets/styles.css, and docs/assets/app.js if present
- [x] T026 Run the full quickstart validation flow from specs/006-marketing-landing-page/quickstart.md against docs/index.html, docs/assets/styles.css, docs/assets/app.js if present, and test/integration/, then apply any follow-up fixes in the touched implementation files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion; blocks all user stories.
- **User Stories (Phases 3-5)**: Depend on Foundational completion.
- **Polish (Phase 6)**: Depends on completion of the desired user stories.

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational; no dependency on later stories.
- **User Story 2 (P2)**: Starts after Foundational and can build on US1 markup, but must remain independently testable from docs/index.html.
- **User Story 3 (P3)**: Starts after Foundational and can layer on the existing page structure, but must remain independently testable as a presentation-focused slice.

### Within Each User Story

- Write the listed automated tests first and confirm they fail.
- Update markup before or alongside CSS/JS specific to that story.
- Complete story-specific validation before moving on.

### Parallel Opportunities

- T002 can run in parallel with T001 because it touches a separate test helper file.
- T005 and T006 can run in parallel after T004 starts because they target separate files.
- Once Foundational work is complete, different team members can own Phases 3-5 in parallel if coordination on docs/index.html is managed carefully.
- T024 can run in parallel with final cleanup because it only touches README.md.

---

## Parallel Example: User Story 1

```bash
Task: "Add content assertions for hero messaging, English-only visible copy, feature highlights, and the primary repository CTA in test/integration/docs_landing_page_content_test.rb"
Task: "Add content-specific section styling and emphasis treatments for the marketing narrative in docs/assets/styles.css"
```

## Parallel Example: User Story 2

```bash
Task: "Add responsive contract assertions for viewport metadata, mobile-safe structure, and relative asset references in test/integration/docs_landing_page_responsive_test.rb"
Task: "Add non-critical mobile interaction enhancements in docs/assets/app.js if progressive enhancement is needed"
```

## Parallel Example: User Story 3

```bash
Task: "Add theme and presentation assertions for admin-inspired styling hooks in test/integration/docs_landing_page_theme_test.rb"
Task: "Add optional decorative assets and supporting imagery in docs/assets/images/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate docs/index.html directly from disk and through the automated story checks.
5. Stop and review before expanding scope.

### Incremental Delivery

1. Setup + Foundational establish the static page shell and shared theme primitives.
2. Deliver User Story 1 as the first shippable marketing page.
3. Add User Story 2 to harden responsiveness and mobile usability.
4. Add User Story 3 to align the final presentation with the admin brand language.
5. Finish with cross-cutting cleanup and validation.

### Parallel Team Strategy

1. One developer completes Setup and Foundational tasks.
2. After that checkpoint:
   - Developer A owns User Story 1 content and CTA completion.
   - Developer B owns User Story 2 responsive behavior and minimal JS.
   - Developer C owns User Story 3 visual polish and asset refinements.
3. Rejoin for Phase 6 cleanup and validation.

---

## Notes

- [P] tasks touch separate files with no blocking dependency on incomplete work.
- [US1], [US2], and [US3] labels map each task back to the specification's user stories.
- The MVP scope is Phase 3 only after Setup and Foundational work are complete.
- Keep the landing page static: no Rails helpers, no API calls, and no server dependency for the primary experience.
