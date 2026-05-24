# Quickstart: Fact Hub

**Feature**: Public API + Admin Interface  
**Stack**: Ruby on Rails 8.1.3 · SQLite · Devise · TailwindCSS v4.3

---

## Prerequisites

| Tool | Version |
| ----- | ------- |
| Ruby | ≥ 3.2 |
| Bundler | ≥ 2.4 |
| Node.js | ≥ 18 (only needed if regenerating CSS outside of the Rails watcher) |
| Chrome + ChromeDriver | Latest stable (required for system tests only) |

---

## First-time Setup

```bash
# 1. Clone the repository
git clone <repo-url> facthub
cd facthub

# 2. Install Ruby dependencies
bundle install

# 3. Install TailwindCSS (first-time only; already done if setup via rails new --css tailwind)
bin/rails tailwindcss:install

# 4. Create and migrate the database
bin/rails db:create db:migrate

# 5. Seed the initial admin account
# Set credentials in environment variables before running seeds:
export ADMIN_EMAIL=admin@example.com
export ADMIN_PASSWORD=changeme123
bin/rails db:seed
```

> **Security**: Change the seeded admin credentials immediately in any non-local environment.
> Never commit real credentials to source control.

---

## Development Server

```bash
bin/dev
```

This starts:

- **Puma** web server on `http://localhost:3000`
- **TailwindCSS watcher** that rebuilds CSS on view changes

---

## Key URLs (development)

| URL | Description |
| ----- | ----------- |
| `GET http://localhost:3000/api/facts/random` | Public API — returns a random fun fact as JSON |
| `http://localhost:3000/admins/sign_in` | Admin login page |
| `http://localhost:3000/admin/facts` | Fun facts list (requires admin login) |

---

## Running Tests

```bash
# Unit and integration tests (fast)
bundle exec rails test

# System tests (requires Chrome + ChromeDriver)
bundle exec rails test:system

# All tests
bundle exec rails test && bundle exec rails test:system
```

---

## Linting

```bash
bundle exec rubocop
```

---

## Database Reset (development only)

```bash
bin/rails db:drop db:create db:migrate db:seed
```

---

## Environment Variables

| Variable | Purpose | Default |
| -------- | ------- | ------- |
| `ADMIN_EMAIL` | Initial admin account email used by `db:seed` | _(required for seed)_ |
| `ADMIN_PASSWORD` | Initial admin account password used by `db:seed` | _(required for seed)_ |
| `RAILS_ENV` | Rails environment | `development` |
| `SECRET_KEY_BASE` | Cookie signing key (Rails generates for dev) | auto-generated |
