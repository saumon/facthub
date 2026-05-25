# facthub Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-05-25

## Active Technologies
- Ruby on Rails 8.1.3 (Ruby >= 3.2) + Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3 (002-next-fact-client)
- SQLite with existing `facts` and `admins` tables plus a new persisted clients table for per-client progression (002-next-fact-client)
- Ruby 3.2+ on Ruby on Rails 8.1.3 + Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3, Solid Queue (003-admin-fact-import)
- SQLite 3 for application data, uploaded files handled through multipart requests, persisted import status in application database (003-admin-fact-import)
- SQLite 3 application database with existing facts table; no new persisted entities expected (004-facts-pagination)
- SQLite 3 application database with the existing `clients` table extended by one nullable alias column (005-client-alias)

- Ruby on Rails 8.1.3 (Ruby ≥ 3.2) + Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3 (001-fact-hub-api-admin)

## Project Structure

```text
app/controllers/api/           # Public REST API (no auth)
app/controllers/admin/         # Admin CRUD (Devise-protected)
app/models/                    # Fact, Admin (Devise)
app/views/admin/facts/         # Admin UI (TailwindCSS v4.3)
app/assets/tailwind/           # TailwindCSS v4.3 entry point
config/routes.rb               # api namespace + devise_for :admins + admin namespace
db/migrate/                    # create_facts, create_admins
test/models/                   # Minitest unit tests
test/controllers/              # Request integration tests
test/system/                   # Capybara system tests
README.md                      # English project description
```

## Commands

```bash
bundle install                        # Install dependencies
bin/rails db:create db:migrate db:seed  # Setup database + seed admin
bin/dev                               # Start Puma + TailwindCSS watcher
bundle exec rails test                # Unit + integration tests
bundle exec rails test:system         # System tests (requires Chrome)
bundle exec rubocop                   # Linting
```

## Code Style

Ruby on Rails 8.1.3 (Ruby ≥ 3.2): Follow standard Rails conventions. Thin controllers, model-level validations, no inline SQL. Use `before_action :authenticate_admin!` in `Admin::BaseController`. API controllers inherit from `ApplicationController` with `respond_to :json`.

## Recent Changes
- 005-client-alias: Added Ruby 3.2+ on Ruby on Rails 8.1.3 + Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3
- 004-facts-pagination: Added Ruby 3.2+ on Ruby on Rails 8.1.3 + Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3
- 003-admin-fact-import: Added Ruby 3.2+ on Ruby on Rails 8.1.3 + Rails 8.1.3, Devise 4.x, Turbo, Stimulus, tailwindcss-rails v4.3, Solid Queue


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
