# API Contract: GET /api/facts/random

**Phase**: 1 — Design  
**Date**: 2026-05-23  
**Branch**: `001-fact-hub-api-admin`

---

## Endpoint

| Property | Value |
| -------- | ----- |
| **Method** | `GET` |
| **Path** | `/api/facts/random` |
| **Authentication** | None |
| **Request body** | None |
| **Content-Type (response)** | `application/json` |

---

## Success Response — 200 OK

Returned when at least one fun fact exists in the catalog.

**Body**:

```json
{
  "id": 42,
  "body": "Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs that was still perfectly edible."
}
```

**Field descriptions**:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `id` | integer | Unique identifier of the selected fun fact |
| `body` | string | The fun fact text. Always non-empty when present. |

---

## Not Found Response — 404 Not Found

Returned when the catalog contains no fun facts.

**Body**:

```json
{
  "error": "no_facts_available",
  "message": "No fun facts are currently available."
}
```

**Field descriptions**:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `error` | string | Machine-readable error code: always `"no_facts_available"` in this case |
| `message` | string | Human-readable explanation |

---

## Behaviour Notes

- The selection algorithm is random (`ORDER BY RANDOM() LIMIT 1`). The same fact may be returned on consecutive calls.
- No pagination, filtering, or category parameters exist in this version.
- No rate limiting is applied in v1.
- The `id` field is included to allow clients to identify which fact was received (e.g., for deduplication in a display history).
- No `Cache-Control` headers are set; clients must not cache the response if they expect varied results.

---

## Example cURL

```bash
# Success
curl -s https://example.com/api/facts/random
# → {"id":42,"body":"Honey never spoils..."}

# Empty catalog
curl -s -o /dev/null -w "%{http_code}" https://example.com/api/facts/random
# → 404
```

---

## Spec Coverage

| Requirement | Satisfied by |
| ----------- | ------------ |
| FR-001 (one random fact per request) | `ORDER BY RANDOM() LIMIT 1` |
| FR-002 (anonymous access) | No `authenticate_admin!` guard on this action |
| FR-003 (persisted records) | Query against the `facts` table |
| FR-004 (consistent response structure) | Fixed `{ id:, body: }` shape |
| FR-005 (unavailable-content response) | 404 with `error: "no_facts_available"` |
| FR-016 (no active/inactive status) | All rows in `facts` table are eligible |
| SC-001 (≤ 2 s p95) | Single-query response on SQLite; validated in integration tests |
