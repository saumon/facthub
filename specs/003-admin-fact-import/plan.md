# Implementation Plan: Bulk Fact Import Setup

**Branch**: `[003-admin-fact-import]` | **Date**: 2026-05-25 | **Spec**: [spec.md](/Users/robu/work/projects/facthub/specs/003-admin-fact-import/spec.md)
**Input**: Feature specification from `/specs/003-admin-fact-import/spec.md`

## Summary

Add an authenticated admin setup flow for importing one or more markdown files of facts, with per-file validation, batch deduplication, and a visible progress bar throughout processing. The implementation will use a persisted import-run model plus Active Job-backed processing, a polling status endpoint for the Stimulus-driven progress UI, and README documentation updates in English including the v1.2.0 changelog entry.

## Technical Context

**Language/Version**: Ruby 3.2+ on Ruby on Rails 8.1.3  
**Primary Dependencies**: Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3, Solid Queue  
**Storage**: SQLite 3 for application data, uploaded files handled through multipart requests, persisted import status in application database  
**Testing**: Minitest unit, controller/integration, and system tests with Capybara/Selenium  
**Target Platform**: Server-rendered web application on macOS/Linux development and deployment targets supported by Rails
**Project Type**: Monolithic Rails web application with admin UI and public API  
**Performance Goals**: Support imports up to 10,000 lines per file, show progress updates within 1 second polling intervals, and complete a standard 10,000-line import within 2 minutes under normal operating conditions  
**Constraints**: Must preserve existing admin UX patterns, reject any file containing invalid lines, remain compatible with current SQLite setup, avoid duplicate facts, and update README documentation in English including changelog v1.2.0  
**Scale/Scope**: One setup page, one import workflow, up to several files per batch, each file capped at 10,000 lines, admin-only usage with per-run progress tracking

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Check

- Code quality: Changes are confined to admin routes/controllers/views, one or more service objects, one background job, supporting models for import tracking, a Stimulus controller, and README updates. Validation gates are `bundle exec rubocop`, focused Rails tests, and repository review of touched slices only.
- Testing: Required automated coverage includes unit tests for parsing/validation/deduplication logic, controller or integration tests for import creation and status polling, and system tests for admin navigation, progress bar visibility, and final summary rendering. Validation commands will include targeted `bundle exec rails test` invocations plus `bundle exec rails test:system` for the setup flow.
- UX consistency: The new setup page must reuse the existing admin layout, navigation styling, flash/toast patterns, Tailwind visual language, and accessible feedback states already used by facts and clients management. The progress region must expose both visible status text and a progress indicator without introducing a divergent interaction model.
- Performance: Explicit budget is up to 10,000 lines per file with visible progress updates during processing and completion within 2 minutes for a standard import. Validation will include automated service-level tests for large files and manual/system verification of progress feedback cadence.

### Post-Design Check

- Code quality: Pass. The design centers on explicit service and job boundaries instead of embedding parsing/import logic directly in controllers.
- Testing: Pass. The design names unit, integration, and system test layers with concrete affected slices.
- UX consistency: Pass. The setup page and progress/result states extend the existing admin shell and Stimulus usage without requiring a new frontend stack.
- Performance: Pass with monitoring. Persisted import runs plus polling allow measurable progress and make the 10,000-line budget testable. SQLite lock contention remains a known operational constraint but is bounded by admin-only usage and small transaction scope.

## Project Structure

### Documentation (this feature)

```text
specs/003-admin-fact-import/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── admin-import-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── admin/
├── javascript/
│   └── controllers/
├── jobs/
├── models/
├── services/
└── views/
    └── admin/

config/
├── routes.rb
└── queue.yml

db/
└── migrate/

test/
├── controllers/
├── models/
├── system/
└── fixtures/

README.md
```

**Structure Decision**: Use the existing monolithic Rails application structure. Admin setup endpoints and HTML live under `app/controllers/admin` and `app/views/admin`, long-running import execution lives in `app/jobs`, parsing/import orchestration lives in `app/services`, persisted status lives in `app/models`, progress UI behavior lives in `app/javascript/controllers`, automated coverage stays in the current Minitest layout, and release documentation changes are made in `README.md`.

## Implementation Outline

### Phase 0 Output

- Research captured in [research.md](/Users/robu/work/projects/facthub/specs/003-admin-fact-import/research.md)

### Phase 1 Design Output

- Data model captured in [data-model.md](/Users/robu/work/projects/facthub/specs/003-admin-fact-import/data-model.md)
- Admin flow contract captured in [contracts/admin-import-contract.md](/Users/robu/work/projects/facthub/specs/003-admin-fact-import/contracts/admin-import-contract.md)
- Verification guide captured in [quickstart.md](/Users/robu/work/projects/facthub/specs/003-admin-fact-import/quickstart.md)

### Planned Implementation Slices

1. Persist import tracking entities and supporting status transitions for one admin-owned import run and per-file outcomes.
2. Add admin setup routes and controller actions to create an import run, enqueue processing, and return progress/status payloads.
3. Implement markdown parsing and import orchestration in services with per-file validation, 10,000-line limit enforcement, and batch-level duplicate detection.
4. Implement a background job that updates persisted progress while processing files and populates final added versus ignored duplicate counts.
5. Add the setup page, file upload form, progress bar, and results rendering within the existing admin UI.
6. Add a Stimulus controller to start polling, update the progress bar, and render terminal summaries.
7. Cover the behavior with targeted unit, integration, and system tests.
8. Update the English README feature documentation and changelog for version 1.2.0.

## Complexity Tracking

No constitution exceptions are currently required.
