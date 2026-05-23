# Data Model: Fact Hub Public API and Admin

**Phase**: 1 — Design  
**Date**: 2026-05-23  
**Branch**: `001-fact-hub-api-admin`

## Entities

---

### Fact

Represents a single fun fact stored in the catalog and eligible for random public retrieval.

| Field | Type | Constraints | Description |
| ----- | ---- | ----------- | ----------- |
| `id` | integer | PK, auto-increment | Surrogate primary key |
| `body` | string | NOT NULL, UNIQUE (case-sensitive), max 500 chars | The fun fact text sentence |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Last modification timestamp |

**Validation rules**:

- `body` must be present (not null, not blank, not whitespace-only).
- `body` must be unique across all existing facts (exact, case-sensitive match).
- A fact with a `body` identical to an existing record must be rejected at both model and database levels.

**State transitions**:

```text
[Created] ──edit──▶ [Updated] ──edit──▶ [Updated] ... ──delete──▶ [Removed from catalog]
```

No status column exists. A fact is available for public retrieval from the moment it is created until the moment it is deleted. Deletion is hard-delete (no soft-delete / archive in this scope).

**Indexes**:

- Primary key on `id` (implicit).
- Unique index on `body` (enforces uniqueness at the database level, also improves duplicate-check performance).

---

### Admin

Represents the single local administrator account that protects the administration interface. Managed by Devise.

| Field | Type | Constraints | Description |
| ----- | ---- | ----------- | ----------- |
| `id` | integer | PK, auto-increment | Surrogate primary key |
| `email` | string | NOT NULL, UNIQUE | Login identifier |
| `encrypted_password` | string | NOT NULL | Bcrypt-hashed password (managed by Devise) |
| `remember_created_at` | datetime | nullable | Set by Devise `:rememberable` if enabled |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Last modification timestamp |

**Note**: The `:timeoutable` Devise module does not add a database column. Session expiry is enforced in memory using the session-stored sign-in timestamp compared against `Devise.timeout_in`.

**Business constraint**: Exactly one `Admin` record exists in this scope. No self-registration flow is provided. The account is created via `db/seeds.rb`.

**Indexes**:

- Primary key on `id` (implicit).
- Unique index on `email` (Devise default).

---

### Administrator Session

Not a persisted database entity. Represented by the Rack session (cookie-based, server-side expiry enforced by Devise `:timeoutable`).

| Property | Description |
| -------- | ----------- |
| Owner | The `Admin` record identified during sign-in |
| Lifetime | Configurable via `Devise.timeout_in` (default: 30 minutes of inactivity) |
| Expiry behavior | On expiry, Devise clears the session and redirects any protected request to `/admins/sign_in` |
| Explicit logout | Admin can end the session at any time via `DELETE /admins/sign_out` |

---

## Entity Relationships

```text
Admin  (1) ─────────────── owns session ─────────────── Administrator Session
                                                                  │
                                                   authorises CRUD on
                                                                  │
Fact   (N) ─── created / updated / deleted by ────────── Admin
```

No foreign key relationship exists between `Fact` and `Admin` in this scope. Authorship tracking is not required.

---

## Integrity Rules Summary

| Rule | Enforced by |
| ----- | ------------- |
| Fun fact body must be non-empty | Model validation (`presence: true`) |
| Fun fact body must be unique (exact match) | Model validation (`uniqueness: true`) + DB unique index |
| Admin email must be unique | Devise model validation + DB unique index |
| Session access requires valid Admin credentials | Devise `authenticate_admin!` before_action |
| Expired session blocks all admin pages | Devise `:timeoutable` module |
| Deleted facts are not returned by the public API | Hard-delete: removed from the `facts` table |
