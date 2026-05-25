# Contract: Admin Bulk Fact Import

## Purpose

Define the internal admin-facing HTTP and UI contract used by the setup import flow for markdown fact imports.

## Routes

### GET /admin/setup

- Authentication: Required admin session
- Purpose: Render the setup page with the import form, progress container, and latest completed summary state if present.
- HTML responsibilities:
  - Show multi-file markdown upload input
  - Explain accepted format briefly
  - Show validation errors for rejected form submissions
  - Provide an initially hidden progress bar region with accessible progress text

### POST /admin/setup/imports

- Authentication: Required admin session
- Content type: multipart/form-data
- Request fields:
  - files[]: one or more markdown files
- Validation rules:
  - At least one file must be selected
  - Each file must be a markdown upload accepted by the setup form
- Success response:
  - HTTP 202 Accepted
  - Body: JSON

```json
{
  "import_run_id": 123,
  "status": "pending",
  "total_files": 3,
  "status_url": "/admin/setup/imports/123"
}
```

- Failure responses:
  - 422 Unprocessable Entity when no file is selected or the form payload is malformed
  - Response body contains a user-displayable message

### GET /admin/setup/imports/:id

- Authentication: Required admin session
- Purpose: Return current progress and final results for one import run owned by the current admin.
- Success response:
  - HTTP 200 OK
  - Body: JSON

```json
{
  "id": 123,
  "status": "processing",
  "total_files": 3,
  "processed_files": 1,
  "total_lines": 8200,
  "processed_lines": 3410,
  "progress_percent": 41,
  "added_facts_count": 1200,
  "ignored_duplicates_count": 87,
  "invalid_files_count": 0,
  "files": [
    {
      "filename": "batch-a.md",
      "status": "completed",
      "total_lines": 3000,
      "processed_lines": 3000,
      "added_facts_count": 900,
      "ignored_duplicates_count": 54,
      "error_message": null
    },
    {
      "filename": "batch-b.md",
      "status": "processing",
      "total_lines": 5200,
      "processed_lines": 210,
      "added_facts_count": 300,
      "ignored_duplicates_count": 33,
      "error_message": null
    },
    {
      "filename": "batch-c.md",
      "status": "pending",
      "total_lines": 0,
      "processed_lines": 0,
      "added_facts_count": 0,
      "ignored_duplicates_count": 0,
      "error_message": null
    }
  ],
  "error_message": null,
  "completed_at": null
}
```

- Terminal status rules:
  - completed: all files accepted and processed successfully
  - completed_with_errors: run finished, but at least one file was rejected or failed
  - failed: unexpected job-level execution failure

## UI Behavior Contract

- On import start, the setup page must immediately show the progress region.
- The progress bar must expose both percent complete and a textual status for accessibility.
- While status is pending or processing, the client polls the status endpoint and updates the progress bar in place.
- On terminal status, the client stops polling and renders:
  - total facts added
  - total facts ignored as duplicates
  - per-file outcomes with explicit failure reasons when present
- If a file exceeds 10,000 lines, the file result status is rejected_too_large and no facts from that file are created.
- If any invalid line exists in a file, the file result status is rejected_invalid and no facts from that file are created.

## Security Rules

- All setup routes require the same authenticated admin boundary as existing admin CRUD pages.
- An admin may read only import runs that they started.
- Status responses must not expose raw file contents.

## Documentation Contract

- README must describe the setup menu, markdown format expectations, 10,000-line limit, duplicate handling, progress feedback, and final added/ignored summary.
- README changelog must include a 1.2.0 entry for the feature in English.
