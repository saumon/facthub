# ✨ FactHub

A Ruby on Rails application that exposes a public JSON API serving random fun facts and provides a password-protected admin interface for managing them.

![Ruby](https://img.shields.io/badge/Ruby-3.2+-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1.3-red?logo=rubyonrails)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-4.3-06B6D4?logo=tailwindcss)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)
![License](https://img.shields.io/badge/license-MIT-blue)

[Features](#-features) • [Quick Start](#-quick-start) • [API](#-api) • [Development](#-development) • [Changelog](#-changelog) • [License](#-license)

---

## ✨ Features

- 🌐 **Public REST API** — `GET /api/facts/random` returns a random fact as JSON, no authentication required
- 🔒 **Admin UI** — Full CRUD interface for fun facts, protected by Devise authentication
- ⏱ **Session timeout** — Admin sessions automatically expire after 30 minutes of inactivity
- 🎨 **Modern UI** — Dark indigo gradient theme built with TailwindCSS v4.3 and Stimulus
- 🔔 **Toast notifications** — Auto-dismissing flash messages with smooth transitions

---

## 🚀 Quick Start

### Prerequisites

- Ruby ≥ 3.2 (check with `ruby -v`)
- Bundler (`gem install bundler`)
- Node.js (for TailwindCSS watcher via `bin/dev`)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/facthub.git
cd facthub

# Install dependencies
bundle install

# Setup database (create, migrate, seed)
bin/rails db:setup
```

### Running the app

```bash
bin/dev
```

This starts the Puma web server and the TailwindCSS watcher together. The app is available at [http://localhost:3000](http://localhost:3000).

### Admin access

Navigate to `http://localhost:3000` and sign in with the default seed account:

| Email | Password |
| ----- | -------- |
| `admin@example.com` | `password` |

---

## 🛠 Tech Stack

| Layer | Technology |
| ----- | -------- |
| Framework | Ruby on Rails 8.1.3 |
| Database | SQLite 3 |
| Authentication | Devise 4.x |
| Frontend | Hotwire (Turbo + Stimulus) |
| CSS | TailwindCSS v4.3 |
| Asset Pipeline | Propshaft + Importmap |

---

## 🔗 API

Full OpenAPI specification: [docs/openapi.yml](docs/openapi.yml)

### Endpoints

| Method | Path | Auth | Description |
| ------ | ---- | ---- | ----------- |
| `GET` | `/api/facts/random` | None | Returns a random fun fact |

### `GET /api/facts/random`

```text
GET http://localhost:3000/api/facts/random
```

**Success (200):**

```json
{
  "id": 42,
  "body": "Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs that was still perfectly edible."
}
```

**No facts available (404):**

```json
{
  "error": "no_facts_available",
  "message": "No fun facts are currently available."
}
```

---

## 🧑‍💻 Development

### Testing

```bash
# Unit + integration tests
bundle exec rails test

# System tests (requires Chrome)
bundle exec rails test:system

# Full suite
bundle exec rails test && bundle exec rails test:system
```

### Linting

```bash
bundle exec rubocop        # Check
bundle exec rubocop -A     # Auto-fix
```

### Database commands

```bash
bin/rails db:create        # Create database
bin/rails db:migrate       # Run migrations
bin/rails db:seed          # Seed demo data
bin/rails db:reset         # Drop + create + migrate + seed
```

### Console

```bash
bin/rails console

# Examples
Fact.count
Fact.order("RANDOM()").first
Admin.find_by(email: "admin@example.com")
```

---

## 📋 Changelog

### v1.0.0 *(May 23, 2026)* — Initial release

- 🌐 **Public REST API** — `GET /api/facts/random` returns a random fun fact as JSON; returns a structured 404 when no facts are available ([spec](specs/001-fact-hub-api-admin/spec.md))
- 🔒 **Admin authentication** — Devise-based login with local admin account; session timeout after 30 minutes of inactivity
- 📝 **Admin CRUD** — Full create, read, update, delete interface for fun facts; duplicate body rejected with validation error
- 🎨 **Modern UI** — Dark indigo gradient theme, TailwindCSS v4.3, auto-dismissing toast notifications via Stimulus
- 🗄 **Database** — SQLite 3 with 5 seeded fun facts and a default admin account

---

## 📜 License

This project is licensed under the MIT License.

---

Made with ❤️ and ✨

[⬆ Back to top](#-facthub)
