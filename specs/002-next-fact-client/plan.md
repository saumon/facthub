# Implementation Plan: Next Fact by Client

**Branch**: `002-next-fact-client` | **Date**: 2026-05-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-next-fact-client/spec.md`

## Summary

Add a second public API retrieval flow, `GET /api/facts/next`, that serves facts in ascending
identifier order for a known client and stores that client's per-sequence cursor so repeated calls
avoid repeats until wrap-around. The same Rails monolith will introduce an authenticated admin-only
client management surface for creating eligible clients, showing/copying generated opaque client
identifiers, inspecting current progression, resetting progression, and deleting clients. The design
must preserve the existing random endpoint, keep admin operations behind Devise authentication, update
OpenAPI, and add a clear English README feature description plus a new changelog entry in README.

## Technical Context

**Language/Version**: Ruby on Rails 8.1.3 (Ruby >= 3.2)  
**Primary Dependencies**: Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3  
**Storage**: SQLite with existing `facts` and `admins` tables plus a new persisted clients table for per-client progression  
**Testing**: Minitest (model tests, request/controller integration tests, concurrency-focused integration test, Capybara system tests)  
**Target Platform**: Linux/macOS web server running a single Rails monolith on Puma  
**Project Type**: Rails monolithic web application with public JSON API and authenticated admin HTML namespace  
**Performance Goals**: p95 <= 2 s for `GET /api/facts/next` and `GET /api/facts/random`; admin client operations complete within 30 s during routine use  
**Constraints**: Client management remains authenticated-only via Devise; the next-fact endpoint uses only the generated client identifier; fact ordering is canonical by ascending `facts.id`; SQLite single-writer behavior must not break per-client progression correctness; README and changelog updates must be written in English  
**Scale/Scope**: Single-instance deployment, hundreds of facts, tens to low hundreds of eligible clients, modest concurrent traffic with possible same-client request bursts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Code Quality — PASS

Controllers stay thin by moving next-fact progression rules into a focused service object instead of
embedding sequencing and concurrency logic directly in controllers or views. RuboCop remains the
formatting and lint gate (`bundle exec rubocop`). Existing Rails conventions remain intact: model
validations for persistence rules, controller namespaces for public/admin split, no inline SQL beyond
small ordering predicates justified by the feature.

### II. Tests Prove Behavior — PASS

| Layer | File | Covers |
| ----- | ---- | ------ |
| Model unit | `test/models/client_test.rb` | Generated identifier, uniqueness, progression reset semantics |
| Model or service unit | `test/models/client_next_fact_resolver_test.rb` or equivalent | Canonical ordering, wrap-around, deleted-fact skip behavior |
| Request integration | `test/controllers/api/facts_controller_test.rb` | `GET /api/facts/next` success, missing/unknown client, wrap-around, no facts |
| Request integration | `test/controllers/admin/clients_controller_test.rb` | Auth guard, create/show/reset/destroy flows |
| Integration | `test/integration/client_progression_concurrency_test.rb` | Same-client concurrent requests advance without duplicate facts when enough facts exist |
| System (Capybara) | `test/system/clients_management_test.rb` | Admin UI for creating, copying identifier, inspecting progression, resetting, deleting |

Commands: `bundle exec rails test`, `bundle exec rails test:system`, `bundle exec rubocop`.

### III. UX Consistency — PASS

Admin client management reuses the existing Devise-protected admin namespace, `Admin::BaseController`,
shared admin layout, flash messaging, and Tailwind styling patterns already used for fact CRUD. The UI
must preserve existing feedback expectations for empty states, validation errors, successful saves,
successful resets, successful deletes, and expired sessions. The generated client identifier must be
visible and easy to copy without introducing a divergent interaction model.

### IV. Performance Budgets — PASS

Critical-path budget: p95 <= 2 s for `GET /api/facts/next` under normal operating conditions, while
preserving atomic cursor advancement for the same client. Validation will rely on request/integration
tests for response shape and sequencing plus a focused concurrency test proving distinct consecutive
results for same-client concurrent requests when enough facts exist. SQLite write serialization is an
accepted v1 constraint; the implementation must favor correctness of progression over maximizing write
parallelism.
The delivery plan MUST include at least one reproducible executable validation step for the next-fact
latency budget and record the observed result against the documented threshold.

## Project Structure

### Documentation (this feature)

```text
specs/002-next-fact-client/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── GET_api_facts_next.md
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── admin/
│   │   ├── base_controller.rb
│   │   └── clients_controller.rb          # index, show, new, create, reset, destroy
│   ├── api/
│   │   └── facts_controller.rb            # random + next
│   └── application_controller.rb
├── models/
│   ├── admin.rb
│   ├── client.rb                          # generated client_identifier + last_fact_id cursor
│   └── fact.rb
├── services/
│   └── client_next_fact_resolver.rb       # canonical order + wrap + atomic progression update
├── views/
│   ├── admin/
│   │   └── clients/
│   │       ├── index.html.erb
│   │       ├── new.html.erb
│   │       └── show.html.erb
│   └── layouts/
│       └── admin.html.erb

config/
└── routes.rb                              # add /api/facts/next + admin/client routes

db/
└── migrate/
    └── *_create_clients.rb               # client_identifier + last_fact_id cursor

docs/
└── openapi.yml                           # document /api/facts/next

test/
├── controllers/
│   ├── admin/
│   │   └── clients_controller_test.rb
│   └── api/
│       └── facts_controller_test.rb
├── integration/
│   └── client_progression_concurrency_test.rb
├── models/
│   └── client_test.rb
└── system/
    └── clients_management_test.rb

README.md                                 # English feature description + changelog update
```

**Structure Decision**: Keep the single Rails monolith and add one new model plus one focused service
object for sequencing logic. This preserves the existing separation between public API and admin UI,
keeps authentication centralized in Devise, and limits complexity while still isolating the concurrency-
sensitive progression rules from controller code.

## Complexity Tracking

> No constitution violations are required for this feature. The only notable complexity is atomic
> same-client progression under SQLite, which is handled within the accepted project constraints and
> does not require a governance exception.
