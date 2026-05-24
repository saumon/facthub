# Research: Fact Hub Public API and Admin

**Phase**: 0 — Outline & Research  
**Date**: 2026-05-23  
**Branch**: `001-fact-hub-api-admin`

## Decisions

---

### 1. TailwindCSS v4.3 Integration in Rails 8.1.3

**Decision**: Use `tailwindcss-rails` gem (v4-compatible release). Run `bin/rails tailwindcss:install` once during project bootstrap. Use the Puma plugin (or `bin/dev` via Foreman) for live CSS rebuilding in development.

**Rationale**: The `tailwindcss-rails` gem wraps the Tailwind standalone CLI binary and integrates with the Rails asset pipeline (Sprockets or Propshaft). Since Rails 8.1.3, `tailwindcss-rails` supports TailwindCSS v4 out of the box. The installer places the input CSS at `app/assets/tailwind/application.css`, which differs from the v3 location — no manual migration needed for a new project. Production CSS is compiled automatically during `assets:precompile`.

**Alternatives considered**:

- **PostCSS + npm**: Adds a Node.js build dependency and complicates deployment. Rejected as unnecessary overhead for a single-developer v1 Rails app.
- **Pinning to Tailwind v3**: Would require `tailwindcss-rails ~> 3.x`. Rejected because the user explicitly requested v4.3.

**Key setup details**:

- Input file: `app/assets/tailwind/application.css` (import TW base + utilities here).
- Output file: compiled and served by Rails asset pipeline.
- Development command: `bin/dev` (Procfile.dev with `web: bin/rails server` and `css: bin/rails tailwindcss:watch`).
- No `tailwind.config.js` in v4; configuration lives in the CSS file via `@theme` and `@import` directives.

---

### 2. Devise Admin Model for a Single-Account Setup

**Decision**: Generate a dedicated `Admin` model (not `User`) with `devise :database_authenticatable, :timeoutable`. Seed the single admin account via `db/seeds.rb` using environment variables for the initial credentials.

**Rationale**: Devise's separate model approach cleanly namespaces routes (`/admins/sign_in`), helpers (`current_admin`, `admin_signed_in?`), and controller guards (`authenticate_admin!`). The `:timeoutable` module handles session expiry (FR-020) without additional code — it redirects to the sign-in page when the session exceeds `Devise.timeout_in`. A single seeded account satisfies FR-019 without introducing user-registration flows.

**Alternatives considered**:

- **Devise on a `User` model with an `admin` boolean flag**: Suitable when mixing public users and admins. Rejected because Fact Hub has no public user accounts; a separate `Admin` model avoids accidental conflation of access levels.
- **HTTP Basic Auth**: Simpler but does not support session expiry, proper flash feedback, or styled login pages. Rejected because FR-006 and FR-017 require a full login UI with consistent UX states.
- **Devise `registerable` module**: Excluded; admin accounts must not be self-registerable.

**Key setup details**:

- Model: `Admin` with `devise :database_authenticatable, :timeoutable`.
- Routes: `devise_for :admins` (generates `/admins/sign_in`, `/admins/sign_out`).
- Controller base: `Admin::BaseController < ApplicationController` with `before_action :authenticate_admin!`.
- Timeout: configurable via `config.timeout_in` in `config/initializers/devise.rb` (default 30 minutes).
- Seed example: `Admin.find_or_create_by!(email: ENV.fetch("ADMIN_EMAIL")) { |a| a.password = ENV.fetch("ADMIN_PASSWORD") }`.

---

### 3. Rails API Namespace and `GET /api/facts/random` Endpoint

**Decision**: Use a standard Rails controller namespace `api/` with `respond_to :json`. Route: `namespace :api { get "facts/random", to: "facts#random" }`. No API versioning in v1.

**Rationale**: A dedicated `api/` namespace cleanly separates public JSON controllers from admin HTML controllers. The path `/api/facts/random` matches the user requirement exactly. Omitting version prefix (`/api/v1/`) keeps the contract simple for a single-version v1 product; versioning can be introduced later without breaking changes if the path is changed.

**Alternatives considered**:

- **`/api/v1/facts/random`**: Adds forward-compatibility. Rejected for v1 to match the stated requirement and avoid over-engineering.
- **Grape / Hanami API**: External API frameworks. Rejected because the Rails built-in JSON rendering is sufficient for a single endpoint.

**Key setup details**:

- Controller: `Api::FactsController < ApplicationController` with `skip_before_action :verify_authenticity_token` (JSON API; CSRF not applicable).
- Action `random`: `Fact.order("RANDOM()").first` — returns one random record or `nil`.
- 200 OK with `{ id:, body: }` when a fact is found.
- 404 Not Found with `{ error: "no_facts_available" }` when the catalog is empty.

---

### 4. SQLite Random Row Selection Strategy

**Decision**: Use `Fact.order("RANDOM()").limit(1).first` for v1.

**Rationale**: For a catalog in the hundreds of rows, SQLite's `ORDER BY RANDOM()` performs a full sequential scan but this is fast enough to stay well within the 2 s budget on a single-file SQLite database. The approach is simple, correct, and requires no additional indexing beyond the primary key.

**Alternatives considered**:

- **Random offset (`OFFSET FLOOR(RANDOM() * COUNT(*))`)**:  More performant at scale because it avoids sorting, but requires two queries and introduces a race condition if rows are deleted between the COUNT and the SELECT. Rejected for v1.
- **Caching a randomised list**: Adds statefulness. Rejected as unnecessary complexity.

---

### 5. Testing Strategy

**Decision**: Minitest (Rails 8 default). Model tests, request (integration) tests, and Capybara system tests with the default `selenium-webdriver` driver already included in Rails 8.

**Rationale**: No additional test framework setup required. Minitest with Rails fixtures and `ActionDispatch::IntegrationTest` covers API contract verification. Capybara system tests (`ApplicationSystemTestCase`) cover the admin UI flows required by the spec's acceptance scenarios.

**Alternatives considered**:

- **RSpec**: Preferred by many Rails developers for readability. Rejected because the user did not specify it and it adds setup overhead (rspec-rails, factories, etc.) that is unnecessary given a well-defined, small test surface.

---

### 6. Uniqueness Validation Scope

**Decision**: `validates :body, presence: true, uniqueness: { case_sensitive: true }`.

**Rationale**: The spec clarification states "refuser les doublons exacts" (exact text match). Case-sensitive uniqueness matches this precisely and avoids unintended rejection of facts that differ only in capitalisation. A database-level unique index on `body` backs the model validation.

**Alternatives considered**:

- **Case-insensitive uniqueness**: More defensive but wider than what the spec requires. Deferred to a future enhancement if needed.

---

## Unresolved Items

None. All NEEDS CLARIFICATION markers from the specification were resolved in the clarification session of 2026-05-23.
