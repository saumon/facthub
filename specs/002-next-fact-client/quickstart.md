# Quickstart: Next Fact by Client

**Feature**: Sequential Fact Retrieval by Eligible Client  
**Stack**: Ruby on Rails 8.1.3 · SQLite · Devise · TailwindCSS v4.3

---

## Prerequisites

| Tool | Version |
| ---- | ------- |
| Ruby | >= 3.2 |
| Bundler | >= 2.4 |
| Node.js | >= 18 |
| Chrome + ChromeDriver | Latest stable (system tests only) |

---

## Setup

```bash
bundle install
export ADMIN_EMAIL=admin@example.com
export ADMIN_PASSWORD=changeme123
bin/rails db:create db:migrate db:seed
bin/dev
```

Open the application at `http://localhost:3000`.

---

## Admin Verification Flow

1. Sign in at `http://localhost:3000/admins/sign_in` with the seeded admin credentials.
2. Open the authenticated clients management area at `http://localhost:3000/admin/clients`.
3. Create a new eligible client.
4. Confirm the generated client identifier is visible and can be copied from the list or client detail view.
5. Confirm the new client initially shows no progression.

---

## Fact Retrieval Verification Flow

Prepare at least three facts in the admin fact management UI.

```bash
# Replace CLIENT_ID with the copied generated identifier
curl -s "http://localhost:3000/api/facts/next?client_id=CLIENT_ID"
curl -s "http://localhost:3000/api/facts/next?client_id=CLIENT_ID"
curl -s "http://localhost:3000/api/facts/next?client_id=CLIENT_ID"
curl -s "http://localhost:3000/api/facts/next?client_id=CLIENT_ID"
```

Expected behavior:

- Responses return facts in ascending id order.
- After the last available fact, the next response wraps to the first available fact.
- The admin client page shows the updated last served fact id after calls.

---

## Edge-Case Verification

### Unknown or missing client id

```bash
curl -s "http://localhost:3000/api/facts/next"
curl -s "http://localhost:3000/api/facts/next?client_id=unknown"
```

Expected behavior:

- Missing `client_id` returns a clear 400 error.
- Unknown or deleted `client_id` returns a clear 404 error.

### Reset progression

1. From the authenticated admin client page, trigger the reset action.
2. Call `GET /api/facts/next?client_id=CLIENT_ID` again.
3. Confirm the first available fact is returned and the admin view reflects the restarted progression.

### Newly added fact becomes immediately eligible

1. Advance a client partway through the sequence.
2. Create a new fact with a higher id.
3. Continue calling `GET /api/facts/next?client_id=CLIENT_ID`.
4. Confirm the new fact appears in the correct canonical position during the ongoing cycle.

### Deleted client

1. Delete the client from the authenticated admin UI.
2. Retry the API call with the previously copied identifier.
3. Confirm the endpoint now returns the unknown-client error.

---

## Automated Validation

```bash
bundle exec rails test
bundle exec rails test:system
bundle exec rubocop
```

---

## Latency Validation — SC-001 (`GET /api/facts/next` p95 ≤ 2 s)

The integration test `GET /api/facts/next responds within 2 seconds` in
[test/controllers/api/facts_controller_test.rb](../../test/controllers/api/facts_controller_test.rb)
measures wall-clock time of a single client lookup + next-fact selection + cursor update against
the test SQLite database.

**Documented command:**

```bash
bundle exec rails test test/controllers/api/facts_controller_test.rb \
  --name "GET /api/facts/next responds within 2 seconds"
```

**Observed result (2026-05-24, macOS, Ruby 3.4.6, Rails 8.1.3, SQLite):**

The test completed in under 0.01 s (well within the 2 s p95 budget). The critical path
(client lookup by indexed `client_identifier`, `SELECT id > cursor LIMIT 1`, `UPDATE clients`)
involves two indexed primary-key/unique-index queries and one atomic update under `with_lock`,
which stays well within SC-001 even under local development load.

---

## Documentation Verification

After implementation, confirm `README.md` includes all of the following in English:

- A feature description for the client-based sequential next-fact endpoint. ✓
- An explanation that client management is only available to authenticated admins. ✓
- At least one usage example for `GET /api/facts/next`. ✓
- A new top changelog entry describing the feature and its admin-management capability. ✓
