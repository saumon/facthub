# Data Model: Bulk Fact Import Setup

## Fact

- Purpose: Existing persisted fun fact exposed by the product and managed by admins.
- Fields:
  - id: integer, primary key
  - body: string, required, unique, maximum 500 characters
  - created_at / updated_at: timestamps
- Validation rules:
  - body must be present
  - body must be unique with existing case-sensitive behavior
  - body length must not exceed 500 characters
- Relationships:
  - Referenced by import results as newly created or ignored duplicate content

## FactImportRun

- Purpose: Represents one admin-triggered bulk import execution so the UI can show progress and final results.
- Fields:
  - id: integer, primary key
  - admin_id: integer, required, owner of the import run
  - status: enum-like string, required; values: pending, processing, completed, completed_with_errors, failed
  - total_files: integer, required, non-negative
  - processed_files: integer, required, non-negative
  - total_lines: integer, required, non-negative
  - processed_lines: integer, required, non-negative
  - added_facts_count: integer, required, non-negative
  - ignored_duplicates_count: integer, required, non-negative
  - invalid_files_count: integer, required, non-negative
  - error_message: string, optional high-level failure summary
  - started_at: datetime, optional
  - completed_at: datetime, optional
  - created_at / updated_at: timestamps
- Validation rules:
  - counters must never be negative
  - processed_files cannot exceed total_files
  - processed_lines cannot exceed total_lines
  - completed_at must be present once status is terminal
- Relationships:
  - belongs_to admin
  - has_many fact_import_files
- State transitions:
  - pending -> processing when the job starts
  - processing -> completed when all files succeed without file-level errors
  - processing -> completed_with_errors when at least one file is refused but the run finishes
  - processing -> failed when the run cannot finish due to an unexpected execution error

## FactImportFile

- Purpose: Stores the per-file result within an import run for operator feedback and troubleshooting.
- Fields:
  - id: integer, primary key
  - fact_import_run_id: integer, required
  - filename: string, required
  - status: enum-like string, required; values: pending, processing, completed, rejected_invalid, rejected_too_large, failed
  - total_lines: integer, required, non-negative
  - processed_lines: integer, required, non-negative
  - added_facts_count: integer, required, non-negative
  - ignored_duplicates_count: integer, required, non-negative
  - error_message: string, optional
  - created_at / updated_at: timestamps
- Validation rules:
  - filename must be present
  - counters must never be negative
  - processed_lines cannot exceed total_lines
- Relationships:
  - belongs_to fact_import_run
- State transitions:
  - pending -> processing when this file begins parsing
  - processing -> completed when the file is fully valid and imported
  - processing -> rejected_invalid when at least one invalid line is found
  - processing -> rejected_too_large when the file exceeds 10,000 lines
  - processing -> failed when an unexpected runtime error occurs

## ImportedFactCandidate

- Purpose: In-memory normalized representation of a markdown bullet line evaluated during parsing before persistence.
- Fields:
  - raw_line_number: integer
  - raw_text: string
  - normalized_body: string
  - duplicate_scope: one of batch_duplicate, existing_duplicate, new_candidate
  - validity: one of valid, blank, over_length, malformed
- Validation rules:
  - normalized_body is derived by trimming surrounding whitespace from the list item text
  - valid candidates must satisfy the existing Fact body validation constraints before insert
- Relationships:
  - Not persisted directly; contributes to FactImportFile outcomes and Fact creation

## Derived Metrics

- Run progress percent: processed_lines / total_lines, bounded between 0 and 100
- Duplicate summary: sum of ignored_duplicates_count across all file results in a run
- Final import summary: added_facts_count, ignored_duplicates_count, invalid_files_count, terminal status
