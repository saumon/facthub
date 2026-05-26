# Implementation Plan: Facthub Marketing Landing Page

**Branch**: `006-marketing-landing-page` | **Date**: 2026-05-26 | **Spec**: `/home/robu/projects/facthub/specs/006-marketing-landing-page/spec.md`
**Input**: Feature specification from `/home/robu/projects/facthub/specs/006-marketing-landing-page/spec.md`

## Summary

Create a single-page static landing page published from `docs/index.html` for GitHub Pages at `https://saumon.github.io/facthub/`. The page will use plain HTML, CSS, and minimal optional JavaScript, store all required assets under `docs/`, mirror the admin UI's dark indigo visual language, and explain Facthub's value around curated fact management and controlled fact delivery for content managers and product owners.

## Technical Context

**Language/Version**: HTML5, CSS3, and optional vanilla JavaScript (ES2020-compatible)  
**Primary Dependencies**: No runtime framework; existing repository test stack for verification; browser DevTools/Lighthouse for manual validation  
**Storage**: N/A  
**Testing**: Repository automated smoke test for static landing page structure and links, plus manual responsive review and Lighthouse performance audit  
**Target Platform**: Modern desktop and mobile browsers, direct filesystem opening, and GitHub Pages project-site hosting  
**Project Type**: Static marketing page inside an existing Rails repository  
**Performance Goals**: Primary visible content readable within 2 seconds; no horizontal scrolling at common mobile widths; non-critical JavaScript must not block first render  
**Constraints**: Must live under `docs/`; must open without a web server; must use relative asset paths; must not require Rails helpers, API calls, or live backend data; must stay visually aligned with the admin theme  
**Scale/Scope**: One landing page, a small static asset set, one primary CTA, and a focused automated smoke-test slice

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Code quality: Keep the change isolated to `docs/` plus any narrowly scoped repository tests or documentation updates. Avoid introducing a separate frontend framework or build pipeline unless implementation reveals a concrete need. Run `bundle exec rubocop test/test_helper.rb test/support/static_landing_page_helper.rb test/integration/docs_landing_page_contract_test.rb test/integration/docs_landing_page_content_test.rb test/integration/docs_landing_page_responsive_test.rb test/integration/docs_landing_page_theme_test.rb` for repository-managed Ruby files. No repository-local formatter, linter, or static-analysis tool is currently defined for standalone `docs/` HTML/CSS/JS assets, so those files are governed by focused diff review, direct-file browser validation, and the landing-page smoke tests.
- Testing: Add repository-level tests that verify the static landing page entry point, required sections, English-only visible copy, responsive contract, and repository CTA link. Validate the touched slice with `bundle exec rails test test/integration/docs_landing_page_contract_test.rb test/integration/docs_landing_page_content_test.rb test/integration/docs_landing_page_responsive_test.rb test/integration/docs_landing_page_theme_test.rb`. Supplement automation with manual browser checks by opening `docs/index.html` directly from disk, reviewing desktop/mobile layouts in browser DevTools, and confirming the CTA and asset paths behave correctly.
- UX consistency: Reuse the admin interface's dark indigo gradient backdrop, white headings, slate body text, rounded cards, rounded indigo buttons, compact navigation rhythm, and accessible contrast expectations. Preserve clear section hierarchy, keyboard-usable links/buttons, and degraded readability when decorative assets or JavaScript are unavailable.
- Performance: Hold the page to a fast first-read budget by keeping assets lightweight, making core content available without JavaScript, and validating that the hero and first visible content are readable within 2 seconds using a Lighthouse performance audit against the GitHub Pages URL or an equivalent local static preview.

Post-design re-check: Pass. The design artifacts keep the feature static, define an automated smoke-test strategy, preserve the established admin visual language, and set explicit rendering and responsiveness budgets without requiring an exception.

## Project Structure

### Documentation (this feature)

```text
specs/006-marketing-landing-page/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── landing-page-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
docs/
├── index.html
├── openapi.yml
└── assets/
    ├── styles.css
    ├── app.js          # Optional, only if progressive enhancement is needed
    └── images/

app/views/layouts/
└── admin.html.erb

app/views/admin/
├── facts/
├── clients/
└── setup/

test/
└── integration/
```

**Structure Decision**: Use the existing Rails repository as the source of visual reference only, while implementing the landing page as a self-contained static surface under `docs/`. Keep any automated verification in the existing `test/` tree so the feature remains reviewable and compatible with repository quality gates.

## Complexity Tracking

No constitution violations or justified exceptions are required at planning time.
