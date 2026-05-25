# Quickstart: Bulk Fact Import Setup

## Goal

Verify the admin setup flow that imports markdown fact files, shows progress during processing, and reports added versus ignored duplicate facts at completion.

## Prerequisites

- Dependencies installed with bundle install
- Databases prepared with bin/rails db:setup
- Default admin account available from seeds
- Development server running via bin/dev
- Background job worker running in the same development environment used for manual verification

## Sample Import File

Create a markdown file such as:

```markdown
# Fun facts database (FR)

- Fact x
- Fact y
- Fact z
```

## Manual Verification Flow

1. Start the app with bin/dev and ensure the background job worker is also running for queued imports.
2. Sign in at /admins/sign_in with the seeded admin account.
3. Open the setup menu from the admin navigation.
4. Select one markdown file with new facts and start the import.
5. Confirm that a progress bar appears immediately and advances until the import completes.
6. Confirm that the completion summary shows the number of facts added and the number ignored as duplicates.
7. Navigate to the facts index and verify that the newly imported facts are visible.

## Multi-file Verification

1. Select two valid markdown files that share some duplicate facts.
2. Start the import.
3. Confirm that duplicates across files are counted as ignored and are inserted only once.
4. Confirm that per-file results are visible after completion.

## Invalid File Verification

1. Create one markdown file that contains at least one invalid non-usable fact line.
2. Import that file together with one fully valid file.
3. Confirm that the invalid file is rejected entirely.
4. Confirm that the valid file still imports successfully.
5. Confirm that the final results identify which file failed and why.

## Over-limit Verification

1. Prepare a markdown file containing more than 10,000 lines.
2. Start the import.
3. Confirm that the file is rejected with an explicit limit-related error.
4. Confirm that no facts from that file are created.

## Automated Validation Targets

- Targeted unit tests for markdown parsing, per-file validation, duplicate handling, and result aggregation
- Integration tests for admin setup import creation and status polling endpoints
- System tests for admin navigation, progress bar visibility, and final summary rendering
- README update verification in English, including changelog version 1.2.0 entry
