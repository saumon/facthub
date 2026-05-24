# Research: Next Fact by Client

**Phase**: 0 — Outline & Research  
**Date**: 2026-05-24  
**Branch**: `002-next-fact-client`

## Decisions

---

### 1. Persist eligible clients in a dedicated `Client` model

**Decision**: Add a new persisted `Client` model dedicated to the next-fact feature. It stores a
system-generated opaque `client_identifier` and a nullable integer `last_fact_id` representing the
last fact served to that client.

**Rationale**: The current application already separates public API concerns from admin-only concerns.
Introducing a dedicated `Client` model matches that design: the public API resolves a client by its
generated identifier, while the authenticated admin interface manages eligibility and progression. A
single row per eligible client is enough because the spec requires only the current cursor, not full
history.

**Alternatives considered**:

- A separate progression-history table. Rejected because the specification does not require an audit of
  all served facts and a single cursor is sufficient for ordering and wrap-around.
- Reusing `Admin` for client eligibility. Rejected because admins and API consumers are distinct roles
  with different authentication expectations.

---

### 2. Store `last_fact_id` as a plain integer cursor, not a foreign key

**Decision**: Keep `last_fact_id` as a nullable integer column without a database foreign-key
constraint to `facts.id`.

**Rationale**: The specification requires sensible continuation when the last served fact has been
deleted. If the cursor were a hard foreign key, deleting a fact would force nullification or a blocked
delete, which would either lose the progression anchor or change current admin behavior. A plain integer
cursor preserves the last served identifier even after deletion, allowing the next request to continue
with the next higher fact id or wrap to the first available fact.

**Alternatives considered**:

- Foreign key with `nullify`. Rejected because it loses the numeric anchor needed for deterministic
  continuation after fact deletion.
- Foreign key with `restrict`. Rejected because it would interfere with existing admin fact deletion
  expectations.

---

### 3. Expose the new public contract as `GET /api/facts/next?client_id=...`

**Decision**: Add `GET /api/facts/next` with a required `client_id` query parameter carrying the
generated opaque client identifier. Return the same success shape as the current random endpoint:
`{ id, body }`.

**Rationale**: The specification consistently describes a client identified by an id, not by a secret,
header, or session. A required query parameter keeps the public contract simple and easy to document in
README, OpenAPI, and curl examples. Reusing the existing fact payload shape avoids introducing a second
JSON representation for the same resource.

**Alternatives considered**:

- Path parameter such as `/api/clients/:id/next_fact`. Rejected because the application already groups
  public fact retrieval under `/api/facts/*`, and the user asked for a fact endpoint rather than a
  client resource endpoint.
- Header-based client identifier. Rejected because it complicates documentation and is not required by
  the spec.

**Response decisions**:

- `200 OK` with `{ id, body }` when a fact is served.
- `400 Bad Request` with `error: "missing_client_id"` when the required identifier is absent or blank.
- `404 Not Found` with `error: "unknown_client"` when the identifier is not recognized or the client was deleted.
- `404 Not Found` with `error: "no_facts_available"` when no fact exists to serve.

---

### 4. Keep all client management strictly behind Devise authentication

**Decision**: Implement client administration entirely under `Admin::BaseController` so every client
management action inherits `before_action :authenticate_admin!`.

**Rationale**: This is already the established pattern in the repository for protected CRUD, and the
user explicitly confirmed that client management must only be possible when authenticated. Reusing the
existing admin namespace prevents any divergence in access control or session-expiry behavior.

**Alternatives considered**:

- A public or partially public client management API. Rejected because it directly conflicts with the
  user request and current Devise-protected administration model.

---

### 5. Encapsulate sequencing and concurrency rules in a service object

**Decision**: Put next-fact progression logic in a dedicated service object, such as
`ClientNextFactResolver`, responsible for locating the next available fact, handling wrap-around,
honoring immediate eligibility of new facts, skipping deleted facts, and atomically updating the
client cursor.

**Rationale**: The current `Api::FactsController#random` action is trivial, but the new feature adds
sequencing, cursor persistence, and concurrency guarantees. A service object keeps the controller thin,
gives the rules a focused unit-test target, and supports the constitution requirement that touched code
remain readable.

**Concurrency decision**: Same-client concurrent requests must be serialized around cursor advancement.
Under SQLite this means accepting write serialization and implementing the progression update in a single
transaction so each successful request advances the cursor exactly once.

**Alternatives considered**:

- Implementing everything directly in the API controller. Rejected because the logic becomes harder to
  test and reason about.
- Introducing a background queue. Rejected because the spec requires synchronous API responses and the
  current app does not need that extra infrastructure.

---

### 6. Limit the admin UI to the operations actually required by the specification

**Decision**: Provide admin flows for index, show, new, create, reset progression, and destroy. Do not
add a general edit/update form for clients.

**Rationale**: The feature requires creation, consultation of current progression, reset, deletion, and
copying the generated identifier. It does not require renaming or mutating a client after creation.
Avoiding unused CRUD operations keeps the UI and routing smaller and clearer.

**Alternatives considered**:

- Full CRUD with editable identifier. Rejected because it undermines the generated opaque identifier
  decision and expands scope without user value.

---

### 7. Treat README and changelog updates as part of the feature deliverable

**Decision**: Update `README.md` in English to document the next-fact capability, client management,
usage example for `GET /api/facts/next`, and admin-only client creation. Add a new top changelog entry
describing the feature above the current v1.0.0 section.

**Rationale**: The user explicitly asked for the feature to be clearly described in README and for the
README changelog to be updated. Making this an explicit plan decision ensures documentation work is not
treated as optional polish.

**Alternatives considered**:

- Limiting documentation to OpenAPI only. Rejected because the user specifically asked for README and
  changelog updates.

---

## Unresolved Items

None. All specification clarifications required for planning were resolved before this document.
