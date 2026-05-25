# Quickstart: Client Alias Management

## Goal

Verify that administrators can create clients with or without an alias, see alias information consistently on the clients list and detail page, update or clear aliases from the detail page, and keep the existing client identifier and progression behavior unchanged.

## Prerequisites

- Dependencies installed with `bundle install`
- Databases prepared with `bin/setup` or `bin/rails db:prepare`
- Seeded admin account available
- Development server running via `bin/dev`
- At least one fact available if you want the detail page to show next-fact content during the walkthrough

## Prepare Representative Data

1. Ensure one existing client has no alias.
2. Ensure one existing client has an alias.
3. For performance validation, seed or create enough clients to reach 500 total client records.

## Manual Verification Flow

1. Start the app with `bin/dev`.
2. Sign in at `/admins/sign_in` with the seeded admin account.
3. Open `/admin/clients/new`.
4. Repeat the client-creation flow with alias entry 20 times, timing each run from the moment the new-client page is visible until the creation success state is visible.
5. Confirm that at least 19 of the 20 timed runs complete in under 30 seconds to satisfy SC-004.
6. In any successful timed run, verify that the detail page still shows the generated client identifier and now shows the saved alias.
7. Open `/admin/clients` and confirm the newly created client row shows both the identifier and the alias.
8. Create another client without entering an alias and confirm the detail page shows the exact fallback text `No alias defined`.

## Alias Update Verification

1. Open an existing client detail page.
2. Use the dedicated alias form to change the alias value and submit.
3. Confirm the updated alias is immediately visible on the detail page.
4. Return to `/admin/clients` and confirm the same updated alias is visible in the corresponding row.
5. Clear the alias from the detail-page form and submit.
6. Confirm the detail page and the index now show the exact fallback text `No alias defined`.

## Edge-Case Verification

1. Submit an alias containing only whitespace during create and confirm the client is still created while the UI shows `No alias defined`.
2. Submit an alias such as ` Operations West ` and confirm the saved value is displayed as `Operations West`.
3. Submit an alias whose trimmed value exceeds 100 characters and confirm the form is re-rendered with validation feedback and no silent truncation.
4. Save the same alias on two different clients and confirm both saves succeed.
5. Confirm the existing reset and deletion confirmations on the detail page still behave exactly as before.
6. Confirm create and update success flashes remain present after successful alias-related actions.
7. Confirm validation errors on both the create form and the detail-page alias form remain readable and preserve the submitted alias input.

## Performance Verification

1. Record 20 timed client-creation runs with alias entry, measuring from the moment the create form is submitted until the creation confirmation is visible, and confirm that at least 19 complete in under 2 seconds.
2. With roughly 500 clients in the database, record 20 timed loads of `/admin/clients` and confirm that at least 19 complete in under 2 seconds.
3. Record 20 timed loads of representative client detail pages and confirm that at least 19 complete in under 2 seconds.
4. Record 20 timed alias-update submissions from the detail page and confirm that at least 19 reach the updated success state in under 2 seconds.
5. Save the timing log used for these checks in specs/005-client-alias/verification-evidence.md so reviewers have project-appropriate evidence for the budget claim.

## Validation Commands

```bash
bundle exec rails test test/models/client_test.rb test/controllers/admin/clients_controller_test.rb
bundle exec rails test:system test/system/clients_management_test.rb
bundle exec rubocop app/models/client.rb app/controllers/admin/clients_controller.rb test/models/client_test.rb test/controllers/admin/clients_controller_test.rb test/system/clients_management_test.rb
```

## Automated Validation Targets

- Model tests for alias trimming, whitespace-only handling, maximum length rejection, and duplicate alias allowance
- Controller tests for authenticated create and update flows, redirect behavior, and invalid alias handling
- System tests for alias creation, list visibility, detail visibility, alias update, alias clearing, and fallback copy consistency
- Manual or instrumented verification that creation confirmation, list, detail, and alias update interactions stay within the documented timing budgets with a retained timing log in specs/005-client-alias/verification-evidence.md
