# Tasks: Fact Hub Public API and Admin

**Input**: Design documents from `/specs/001-fact-hub-api-admin/`  
**Prerequisites**: plan.md ✅ · spec.md ✅ · research.md ✅ · data-model.md ✅ · contracts/GET_api_facts_random.md ✅  
**Branch**: `001-fact-hub-api-admin`  
**Generated**: 2026-05-23

**Tests**: Required by Constitution Principle II — included in every user story phase.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can be executed in parallel (different files, no incomplete dependencies)
- **[Story]**: User story scope — [US1], [US2], [US3] (only in story phases)
- Exact file paths in every description

---

## Phase 1: Setup

**Purpose**: Bootstrap the Rails application with all required dependencies and tooling.

- [X] T001 Bootstrap Rails 8.1.3 application with SQLite and TailwindCSS v4.3 (`rails new . --css tailwind --database sqlite3`) in project root — generates Gemfile, config/application.rb, config/database.yml, app/assets/tailwind/application.css, Procfile.dev, bin/dev
- [X] T002 Add Devise gem to Gemfile, run `bundle install` and `rails generate devise:install` — creates config/initializers/devise.rb and config/locales/devise.en.yml
- [X] T003 [P] Add `rubocop-rails-omakase` to Gemfile development group and create .rubocop.yml inheriting from `rubocop-rails-omakase`

**Checkpoint**: Rails app boots (`bin/rails about`), TailwindCSS compiles, Devise initializer present, RuboCop runs without crash.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data layer and routing that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 [P] Create Fact model with `validates :body, presence: true, uniqueness: { case_sensitive: true }, length: { maximum: 500 }` and migration `create_facts` with `t.string :body, null: false, limit: 500` and unique index on `body` — app/models/fact.rb, db/migrate/TIMESTAMP_create_facts.rb
- [X] T005 [P] Generate Admin Devise model with `devise :database_authenticatable, :timeoutable`, set `config.timeout_in = 30.minutes` in config/initializers/devise.rb — app/models/admin.rb, db/migrate/TIMESTAMP_create_admins.rb
- [X] T006 Configure routes: `namespace :api { get 'facts/random', to: 'facts#random' }`, `devise_for :admins`, `namespace :admin { resources :facts }` — config/routes.rb
- [X] T007 Create db/seeds.rb seeding the Admin account from `ENV.fetch("ADMIN_EMAIL")` and `ENV.fetch("ADMIN_PASSWORD")` using `find_or_create_by!`
- [X] T008 [P] Write Fact model unit tests covering: body presence required, body uniqueness (exact duplicate rejected), blank/whitespace body rejected, body longer than 500 chars rejected — test/models/fact_test.rb
- [X] T009 [P] Write Admin model unit tests covering: email presence required, encrypted_password set, Devise modules `database_authenticatable` and `timeoutable` declared — test/models/admin_test.rb

**Checkpoint**: `bin/rails db:create db:migrate db:seed ADMIN_EMAIL=a@b.com ADMIN_PASSWORD=pass` succeeds, `bundle exec rails test test/models/` green.

---

## Phase 3: User Story 1 — Retrieve a random fun fact (Priority: P1) 🎯 MVP

**Goal**: Public clients can call `GET /api/facts/random` without authentication and receive a random fun fact or a clear unavailable-content response.

**Independent Test**: `GET /api/facts/random` returns `{ "id": ..., "body": "..." }` (200) when facts exist, `{ "error": "no_facts_available", "message": "No fun facts are currently available." }` (404) when catalog is empty, with no credentials.

### Tests for User Story 1

- [X] T010 [US1] Write request integration tests for `GET /api/facts/random` — assert 200 + JSON shape `{id:, body:}` when catalog has facts, assert 404 + `{error: "no_facts_available", message: "No fun facts are currently available."}` when catalog is empty, assert no `Authorization` header required, assert response time ≤ 2 s (single-request approximation, acceptable at v1 SQLite scale), assert fact deleted via destroy action no longer returned by subsequent API call — test/controllers/api/facts_controller_test.rb

### Implementation for User Story 1

- [X] T011 [US1] Create `Api::FactsController` inheriting `ApplicationController` with `respond_to :json` and action `random`: `Fact.order("RANDOM()").limit(1).first`, render `{ id:, body: }` on 200 or `{ error: "no_facts_available", message: "No fun facts are currently available." }` on 404 — app/controllers/api/facts_controller.rb

**Checkpoint**: `bundle exec rails test test/controllers/api/` green. `curl http://localhost:3000/api/facts/random` returns JSON.

---

## Phase 4: User Story 2 — Access the administration area (Priority: P2)

**Goal**: Unauthenticated access to admin pages is blocked; a valid local admin can log in and reach the admin area; expired sessions are redirected to the login page.

**Independent Test**: Navigate to `/admin/facts` without a session → redirected to `/admins/sign_in`. Log in with seeded credentials → reaches admin area. Log in with wrong credentials → login page with error message. Session expires → next request redirected to login.

### Tests for User Story 2

- [X] T012 [US2] Write system tests for admin authentication — (1) unauthenticated GET `/admin/facts` redirects to sign-in, (2) valid credentials on sign-in form open the admin area, (3) invalid credentials show Devise flash error, (4) signed-in admin with expired session is redirected to sign-in — test/system/admin_auth_test.rb

### Implementation for User Story 2

- [X] T013 [P] [US2] Create `Admin::BaseController < ApplicationController` with `before_action :authenticate_admin!` — app/controllers/admin/base_controller.rb
- [X] T014 [P] [US2] Create admin application layout with TailwindCSS — semantic `<header>` nav bar with app name and sign-out link, `<main>` content area, shared `_flash.html.erb` partial rendering Devise flash notice/alert — app/views/layouts/admin.html.erb, app/views/shared/_flash.html.erb
- [X] T015 [P] [US2] Customise Devise sessions login view with TailwindCSS — centered card with email input, password input, submit button, and flash error message zone — app/views/devise/sessions/new.html.erb

**Checkpoint**: `bundle exec rails test:system test/system/admin_auth_test.rb` green. Sign-in and sign-out flows work in a browser.

---

## Phase 5: User Story 3 — Manage fun facts (Priority: P3)

**Goal**: An authenticated administrator can list all fun facts, add a new one, edit an existing one, and delete one. Duplicate and blank submissions are rejected with explicit feedback.

**Independent Test**: After login: `/admin/facts` shows the full list (or empty state). Create a new fact → appears in list. Edit a fact → updated text shown. Delete a fact → removed from list. Submit duplicate → validation error shown. Submit blank → validation error shown.

### Tests for User Story 3

- [X] T016 [US3] Write request integration tests for `Admin::FactsController` — index (200 when signed in, redirect when not), create (success redirect, duplicate rejected 422, blank body rejected 422), update (success redirect, duplicate rejected 422), destroy (success redirect) — test/controllers/admin/facts_controller_test.rb
- [X] T017 [P] [US3] Write system tests for facts management UI — list with facts, empty-list message, add fact success flash, edit fact success flash, delete fact success flash, duplicate submission shows validation error, blank body shows validation error — test/system/facts_management_test.rb

### Implementation for User Story 3

- [X] T018 [P] [US3] Create `Admin::FactsController < Admin::BaseController` with `index`, `new`, `create`, `edit`, `update`, `destroy` — `index`: `Fact.order(:created_at)`, `create`/`update`: redirect on success or re-render with errors — app/controllers/admin/facts_controller.rb
- [X] T019 [P] [US3] Create admin facts index view with TailwindCSS — table listing all facts with Edit/Delete links, empty-state paragraph when catalog is empty, delete via `data-turbo-method="delete"` with confirmation — app/views/admin/facts/index.html.erb
- [X] T020 [US3] Create admin facts `_form.html.erb` shared partial with TailwindCSS — labelled `<textarea>` for `body`, error list block rendering `fact.errors.full_messages`, submit button — app/views/admin/facts/_form.html.erb
- [X] T021 [P] [US3] Create admin facts new view — page heading, render `_form` partial, back link — app/views/admin/facts/new.html.erb
- [X] T022 [P] [US3] Create admin facts edit view — page heading with current fact identifier, render `_form` partial, back link — app/views/admin/facts/edit.html.erb

**Checkpoint**: `bundle exec rails test test/controllers/admin/` and `bundle exec rails test:system test/system/facts_management_test.rb` green. CRUD flows work end-to-end in a browser.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Seed data, README, final lint and full test run.

- [X] T023 [P] Extend db/seeds.rb with 5 sample fun facts seeded after the admin account using `Fact.find_or_create_by!(body: "...")` — db/seeds.rb
- [X] T024 [P] Write English README.md — project description, public API endpoint (`GET /api/facts/random` with request/response examples), admin interface overview, prerequisites, setup steps (`bundle install`, `db:create db:migrate db:seed`, `bin/dev`), test commands — README.md
- [X] T025 [P] Run `bundle exec rubocop -A` and fix all style violations across app/, config/, db/, test/
- [X] T026 Run complete test suite — `bundle exec rails test && bundle exec rails test:system` — confirm zero failures and zero errors

**Checkpoint**: All 26 tasks complete, zero rubocop offenses, zero test failures.

---

## Dependencies & Execution Order

### Phase Dependencies

```text
Phase 1: Setup
  └── Phase 2: Foundational  ← BLOCKS all user stories
        ├── Phase 3: US1 (P1) — no dependency on US2 or US3
        ├── Phase 4: US2 (P2) — no dependency on US1
        │     └── Phase 5: US3 (P3) ← depends on US2 (Admin::BaseController T013)
        └── Phase 6: Polish   ← after all desired stories complete
```

### User Story Dependencies

| Story | Phase Gate | Inter-story dependency |
| ----- | --------- | ---------------------- |
| US1 (P1) | Foundational complete | None — independently testable |
| US2 (P2) | Foundational complete | None — independently testable |
| US3 (P3) | Foundational + T013 (Admin::BaseController) | Requires US2 auth layer |

### Within Each Phase

- **Phase 2**: T004 ‖ T005 (parallel), then T006, then T007 ‖ T008 ‖ T009 (parallel)
- **Phase 3**: T010 → T011 (tests first, then implementation)
- **Phase 4**: T012 → T013 ‖ T014 ‖ T015 (tests first, then implementations in parallel)
- **Phase 5**: T016 ‖ T017 → T018 ‖ T019, then T020 → T021 ‖ T022
- **Phase 6**: T023 ‖ T024 ‖ T025 → T026

---

## Parallel Execution Examples

### Phase 2 — Foundation

```text
Stream A: T004 (Fact model + migration)
Stream B: T005 (Admin model + Devise config)
                            → both done → T006 (routes)
                                              → T007 ‖ T008 ‖ T009
```

### Phase 4 — US2 implementation (after T012 tests written)

```text
Stream A: T013 (Admin::BaseController)
Stream B: T014 (admin layout + flash partial)
Stream C: T015 (Devise login view)
```

### Phase 5 — US3 implementation (after T016/T017 tests written)

```text
Stream A: T018 (Admin::FactsController)
Stream B: T019 (index.html.erb)
Stream C: T020 (_form.html.erb) → T021 ‖ T022
```

---

## Implementation Strategy

### MVP: User Story 1 Only (5 tasks)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T009)
3. Complete Phase 3: US1 (T010–T011)
4. **STOP and VALIDATE**: `bundle exec rails test test/controllers/api/` — confirm API works end-to-end
5. Optional: deploy or demo `GET /api/facts/random`

### Incremental Delivery

1. Phases 1–2 → Shared foundation ready
2. Phase 3 (US1) → Public API ✅ — demo-able MVP
3. Phase 4 (US2) → Admin login ✅ — security layer in place
4. Phase 5 (US3) → Admin CRUD ✅ — full feature complete
5. Phase 6 → Polish, README, lint, full test pass ✅ — ready for review

---

## Summary

| Phase | Tasks | Story | Parallel Opportunities |
| ----- | ----- | ----- | ---------------------- |
| Setup | T001–T003 | — | T003 ‖ T002 |
| Foundational | T004–T009 | — | T004 ‖ T005; T007 ‖ T008 ‖ T009 |
| US1 (P1) | T010–T011 | US1 | — |
| US2 (P2) | T012–T015 | US2 | T013 ‖ T014 ‖ T015 |
| US3 (P3) | T016–T022 | US3 | T016 ‖ T017; T018 ‖ T019; T021 ‖ T022 |
| Polish | T023–T026 | — | T023 ‖ T024 ‖ T025 |
| **Total** | **26 tasks** | | |
