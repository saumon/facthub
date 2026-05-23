# Implementation Plan: Fact Hub Public API and Admin

**Branch**: `001-fact-hub-api-admin` | **Date**: 2026-05-23 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-fact-hub-api-admin/spec.md`

## Summary

Build a Ruby on Rails 8.1.3 monolithic application named **Fact Hub**. It exposes a public REST
API endpoint `GET /api/facts/random` that returns one randomly-selected fun fact persisted in
SQLite — no authentication required. The same application hosts a browser-based administration
interface protected by Devise (single `Admin` model, `database_authenticatable` +
`timeoutable`) where the administrator can list, create, edit, and delete fun facts. All
user-facing markup uses TailwindCSS v4.3. An English README describes the project and the
feature.

## Technical Context

**Language/Version**: Ruby on Rails 8.1.3 (Ruby ≥ 3.2)  
**Primary Dependencies**: Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3  
**Storage**: SQLite (single-file, WAL mode for write concurrency)  
**Testing**: Minitest (Rails default) — model unit tests, request integration tests, Capybara system tests  
**Target Platform**: Linux/macOS web server, single-process Puma  
**Project Type**: Rails monolithic web application with embedded REST API namespace  
**Performance Goals**: 95th-percentile response ≤ 2 s for `GET /api/facts/random` (SC-001)  
**Constraints**: SQLite only; single admin account; no external auth provider; no mobile-specific build  
**Scale/Scope**: Single-instance deployment; fun facts catalog at hundreds of records for v1

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Code Quality — PASS**  

Standard Rails `app/` and `test/` layout; no custom module hierarchy required. RuboCop (Rails profile via `rubocop-rails-omakase` or `rubocop-rails`) enforces style — run with `bundle exec rubocop`. Thin controllers, model-level validations, no inline SQL. No justified exceptions.

### II. Tests Prove Behavior — PASS**

| Layer | File | Covers |
| ----- | ---- | ------- |
| Model unit | `test/models/fact_test.rb` | Presence, uniqueness, non-blank validations |
| Model unit | `test/models/admin_test.rb` | Devise email/password requirements |
| Request integration | `test/controllers/api/facts_controller_test.rb` | FR-001, FR-002, FR-004, FR-005 |
| Request integration | `test/controllers/admin/facts_controller_test.rb` | FR-007→FR-015, FR-020 |
| System (Capybara) | `test/system/admin_auth_test.rb` | US-2 scenarios: login, wrong credentials, expired session |
| System (Capybara) | `test/system/facts_management_test.rb` | US-3 scenarios: list, add, edit, delete, duplicate rejection |

Commands: `bundle exec rails test` (unit + integration), `bundle exec rails test:system` (system).

### III. UX Consistency — PASS**  

TailwindCSS v4.3 utility classes throughout; no inline styles. All admin pages share `app/views/layouts/admin.html.erb`. Devise flash messages reuse a shared flash partial. All form validation errors use the same error-box pattern. Empty-list, loading, and error states are required by FR-017 and SC-005. Semantic HTML5 landmarks and `<label>` elements for all inputs (accessibility).

### IV. Performance Budgets — PASS**  

Budget: p95 ≤ 2 s for `GET /api/facts/random` (SC-001). Validation: request integration test asserts response within budget; SQLite `ORDER BY RANDOM() LIMIT 1` is bounded on a catalog of hundreds of records; single-row response; no N+1 risk. Admin CRUD pages: no explicit latency budget, but `body` column uniqueness index prevents full-table scans for duplicate checks.

## Project Structure

### Documentation (this feature)

```text
specs/001-fact-hub-api-admin/
├── plan.md                            # This file
├── research.md                        # Phase 0 output
├── data-model.md                      # Phase 1 output
├── quickstart.md                      # Phase 1 output
├── contracts/
│   └── GET_api_facts_random.md        # Phase 1 output
└── tasks.md                           # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── admin/
│   │   ├── base_controller.rb         # before_action :authenticate_admin!
│   │   └── facts_controller.rb        # index, new, create, edit, update, destroy
│   ├── api/
│   │   └── facts_controller.rb        # GET /api/facts/random
│   └── application_controller.rb
├── models/
│   ├── admin.rb                       # Devise :database_authenticatable, :timeoutable
│   └── fact.rb                        # Validations: presence, uniqueness
├── views/
│   ├── admin/
│   │   └── facts/
│   │       ├── index.html.erb
│   │       ├── new.html.erb
│   │       └── edit.html.erb
│   ├── devise/
│   │   └── sessions/
│   │       └── new.html.erb
│   └── layouts/
│       ├── admin.html.erb
│       └── application.html.erb
└── assets/
    └── tailwind/
        └── application.css            # TailwindCSS v4.3 entry point

config/
└── routes.rb                          # api namespace + devise_for :admins + admin namespace

db/
├── migrate/
│   ├── xxx_create_admins.rb
│   └── xxx_create_facts.rb
└── seeds.rb                           # Initial admin account (credentials in ENV or commented)

test/
├── models/
│   ├── fact_test.rb
│   └── admin_test.rb
├── controllers/
│   ├── api/
│   │   └── facts_controller_test.rb
│   └── admin/
│       └── facts_controller_test.rb
└── system/
    ├── admin_auth_test.rb
    └── facts_management_test.rb

README.md                              # English project + feature description
```

**Structure Decision**: Single Rails monolith with two controller namespaces — `api/` for the
public REST endpoint and `admin/` for the Devise-protected CRUD interface. This avoids
multi-project overhead and keeps all data access within a single SQLite file, which is
sufficient for v1 scale and simplifies deployment.

## Complexity Tracking

> No violations — all four Constitution principles are met within standard Rails conventions.
> No exceptions required.
