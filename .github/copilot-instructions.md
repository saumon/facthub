# facthub Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-05-24

## Active Technologies
- Ruby on Rails 8.1.3 (Ruby >= 3.2) + Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3 (002-next-fact-client)
- SQLite with existing `facts` and `admins` tables plus a new persisted clients table for per-client progression (002-next-fact-client)

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
- 002-next-fact-client: Added Ruby on Rails 8.1.3 (Ruby >= 3.2) + Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3

- 001-fact-hub-api-admin: Added Ruby on Rails 8.1.3 (Ruby ≥ 3.2) + Devise 4.x (`database_authenticatable`, `timeoutable`), tailwindcss-rails (TailwindCSS v4.3), sqlite3

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
