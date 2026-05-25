# Implementation Plan: Client Alias Management

**Branch**: `[005-client-alias]` | **Date**: 2026-05-25 | **Spec**: [spec.md](/Users/robu/work/projects/facthub/specs/005-client-alias/spec.md)
**Input**: Feature specification from `/specs/005-client-alias/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Add an optional informational alias to admin-managed clients so administrators can enter it at creation time, view it in the client list and detail screens, and update or clear it later from a dedicated form on the detail page. The implementation will extend the existing Rails admin client flow with a nullable alias column, model-level trimming and length validation, alias-aware create and update handling in the existing controller, and focused Minitest plus Capybara coverage for creation, display, update, clearing, and fallback behavior.

## Technical Context

**Language/Version**: Ruby 3.2+ on Ruby on Rails 8.1.3  
**Primary Dependencies**: Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3  
**Storage**: SQLite 3 application database with the existing `clients` table extended by one nullable alias column  
**Testing**: Minitest model and controller tests plus Capybara system tests  
**Target Platform**: Server-rendered Rails admin web application for macOS/Linux development and Rails-supported deployment targets
**Project Type**: Monolithic Rails web application with admin UI and public API  
**Performance Goals**: Client creation, list rendering, detail rendering, and alias updates remain visible to admins in under 2 seconds for at least 95% of interactions with up to 500 clients, measured with a representative 20-run manual timing log or equivalent implementation-time evidence  
**Constraints**: Preserve current admin UX patterns, keep the generated client identifier visible wherever alias is shown, display the exact fallback text "No alias defined", trim leading and trailing whitespace before validation, reject aliases whose trimmed length exceeds 100 characters as counted by standard Rails length validation, and avoid introducing new gems or changing public API behavior  
**Scale/Scope**: One existing persisted entity, one admin controller, three existing admin client views, one schema migration, and targeted regression coverage for create, show, index, and update flows

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Check

- Code quality: Keep the change in the owning Rails slices only: `Client`, `Admin::ClientsController`, `config/routes.rb`, and the existing admin client templates. Validation gates are `bundle exec rubocop` on touched Ruby files plus focused review of the migration, strong parameters, and view rendering logic. No constitution exception is needed because the feature does not require new abstractions or dependencies.
- Testing: Required automated coverage includes model tests for alias normalization and validation, controller tests for authenticated create and update flows plus fallback behavior, and system tests for admin-visible create, list, detail, update, and clear journeys. Primary commands are `bundle exec rails test test/models/client_test.rb test/controllers/admin/clients_controller_test.rb` and `bundle exec rails test:system test/system/clients_management_test.rb`.
- UX consistency: The feature must reuse the existing Tailwind-based admin cards, tables, flash notices, and form affordances. Alias UI must appear as a small extension of the current client screens, keep the opaque client identifier visible, use the exact fallback copy from the spec, and preserve current empty, error, confirmation, and navigation behavior. Validation must explicitly cover fallback copy, validation error rendering, existing destructive-action confirmations, and existing success flashes.
- Performance: The affected critical path is the admin client management flow. Budget is under 2 seconds for create, list, show, and alias-save interactions with up to 500 clients. Validation will use targeted automated tests for behavior, a representative 20-run manual timing log for create with alias against SC-004, and recorded timing evidence for list, show, and alias-save interactions on a seeded 500-client dataset.

### Post-Design Check

- Code quality: Pass. The design keeps normalization in the model, uses standard Rails route and parameter handling, and limits UI changes to the existing client templates.
- Testing: Pass. The design explicitly covers model, controller, and system behavior for creation, update, blank alias fallback, and invalid alias rejection.
- UX consistency: Pass. Alias capture and editing extend existing client pages without changing the surrounding admin navigation or action patterns.
- Performance: Pass. A single nullable string column and the current ordered client queries are sufficient for the stated scale, and the design now requires explicit timing evidence for create, list, show, and alias-save interactions rather than qualitative responsiveness checks.

## Project Structure

### Documentation (this feature)

```text
specs/005-client-alias/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── verification-evidence.md
├── contracts/
│   └── admin-client-alias-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── admin/
├── models/
└── views/
    └── admin/
        └── clients/

config/
└── routes.rb

db/
└── migrate/

test/
├── controllers/
│   └── admin/
├── models/
└── system/
```

**Structure Decision**: Use the existing monolithic Rails structure. Persist alias data on `Client`, update the existing `Admin::ClientsController` to accept alias input during create and alias updates from the detail page, extend `app/views/admin/clients/new.html.erb`, `index.html.erb`, and `show.html.erb`, add a migration under `db/migrate`, and keep all regression coverage in the current Minitest and Capybara suites.

## Implementation Outline

### Phase 0 Output

- Research captured in [research.md](/Users/robu/work/projects/facthub/specs/005-client-alias/research.md)

### Phase 1 Design Output

- Data model captured in [data-model.md](/Users/robu/work/projects/facthub/specs/005-client-alias/data-model.md)
- Admin HTTP and UI contract captured in [contracts/admin-client-alias-contract.md](/Users/robu/work/projects/facthub/specs/005-client-alias/contracts/admin-client-alias-contract.md)
- Verification guide captured in [quickstart.md](/Users/robu/work/projects/facthub/specs/005-client-alias/quickstart.md)

### Planned Implementation Slices

1. Add a nullable alias column for clients and implement model-level trimming plus maximum-length validation while allowing blank and duplicate aliases, with the 100-character limit defined by standard Rails length validation on the trimmed value.
2. Extend admin client creation to accept an optional alias without changing identifier generation or progression behavior.
3. Add dedicated alias editing on the client detail page using a standard Rails update route and keep alias plus identifier visible on both show and index screens.
4. Render the exact fallback text "No alias defined" consistently in management views whenever a client has no saved alias.
5. Add model, controller, and system regression coverage for creation with alias, whitespace normalization, invalid length handling, duplicate aliases, list visibility, detail visibility, alias update, and alias clearing.

## Complexity Tracking

No constitution exceptions are currently required.
