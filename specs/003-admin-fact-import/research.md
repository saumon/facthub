# Research: Bulk Fact Import Setup

## Decision 1: Use a persisted import run plus background job for progress-aware processing

- Decision: Model each admin import as a persisted import run processed by Active Job, with the admin UI polling import status to drive a visible progress bar and final summary.
- Rationale: The feature requires progress feedback during processing, not just during file upload. A background job plus persisted status lets the browser receive incremental progress while the server parses and imports large markdown files. The repository already includes Solid Queue, so the design can stay within the existing Rails stack.
- Alternatives considered:
  - Synchronous controller processing: rejected because the UI cannot observe true server-side progress during a single blocking request.
  - Action Cable or Turbo Stream push updates: rejected for v1 because polling a status endpoint is simpler, easier to test, and consistent with the current lightweight Stimulus usage.

## Decision 2: Validate each file completely before inserting any fact from that file

- Decision: Parse each selected file line by line, classify usable fact candidates, and reject the entire file if any invalid or non-usable fact line is encountered.
- Rationale: This matches the approved clarification, keeps file-level outcomes deterministic, and avoids partially imported files that are hard for administrators to reason about.
- Alternatives considered:
  - Import valid lines and skip only invalid lines: rejected by clarified product rule.
  - Abort the entire multi-file batch on the first invalid file: rejected because the specification explicitly allows valid files in the same batch to succeed.

## Decision 3: Track progress using line-based completion and file-level result aggregation

- Decision: Measure progress as processed lines over total lines across the accepted upload batch, while also storing per-file counts for added facts, ignored duplicates, invalid-file failures, and over-limit failures.
- Rationale: A line-based counter maps directly to the 10,000-line requirement, scales to multi-file batches, and yields a progress bar that reflects real parsing/import work. File-level results are still needed for operator comprehension at the end of the import.
- Alternatives considered:
  - File-count-only progress: rejected because it is too coarse for very large files.
  - Row-insert-count-only progress: rejected because invalid files can be rejected before inserts begin, which would make progress misleading.

## Decision 4: Deduplicate using normalized fact body text before insert, while preserving the existing Fact validation boundary

- Decision: Treat duplicate candidates as equal after trimming leading and trailing whitespace, deduplicate once in memory across the whole batch, then rely on the existing Fact uniqueness validation and database uniqueness as the final guard.
- Rationale: This matches the specification, reduces repeated database lookups, and preserves the current Fact model as the source of truth for allowed persisted bodies.
- Alternatives considered:
  - Case-insensitive normalization: rejected because the current Fact uniqueness is case-sensitive and the spec does not broaden equivalence.
  - Database-only duplicate detection: rejected because it would add avoidable repeated writes and less precise import reporting.

## Decision 5: Document the feature in README and changelog as part of the implementation slice

- Decision: Update the English README feature list, admin usage guidance, and changelog entry for version 1.2.0 in the same feature implementation.
- Rationale: Documentation is an explicit requirement of this feature and must ship with the code, not as follow-up cleanup.
- Alternatives considered:
  - Defer documentation until after implementation: rejected because it would violate the spec and weaken release readiness.

## Decision 6: Prefer polling over push for progress updates in the current admin stack

- Decision: Expose a status endpoint for the import run and have a dedicated Stimulus controller poll at a short interval while the import is pending or running.
- Rationale: The current frontend already uses a minimal Stimulus setup and does not yet depend on live broadcast flows for admin interactions. Polling keeps the change smaller and easier to verify with system tests.
- Alternatives considered:
  - Turbo Stream broadcasts via background job: rejected for this iteration because it adds more moving parts than necessary for a single-admin operational workflow.
  - Meta-refresh or full-page polling: rejected because it would provide a poor user experience compared to an in-place progress bar.
