# Research: Facthub Marketing Landing Page

## Decision 1: Deliver the landing page as plain static assets in `docs/`

- Decision: Implement the landing page as `docs/index.html` plus static CSS, JavaScript, and optional images under `docs/assets/`.
- Rationale: GitHub Pages can publish directly from the repository `docs/` directory, and a plain static structure guarantees the page can be opened locally without starting Rails or any asset pipeline.
- Alternatives considered:
  - Render the page through Rails views: rejected because it would require a running server and would not satisfy the GitHub Pages hosting requirement.
  - Generate static output from a build tool: rejected for the initial version because it adds avoidable tooling complexity to a single-page marketing site.

## Decision 2: Use relative asset references compatible with local file opening and project-site hosting

- Decision: Reference stylesheets, scripts, images, and internal anchors with document-relative paths such as `./assets/styles.css` and `./assets/app.js`.
- Rationale: Relative paths work both when opening `docs/index.html` directly from disk and when serving the page from `https://saumon.github.io/facthub/`.
- Alternatives considered:
  - Root-relative paths such as `/facthub/assets/...`: rejected because they fail when the page is opened directly from the filesystem.
  - Absolute GitHub URLs: rejected because they couple the page to one hosting origin and make local review less reliable.

## Decision 3: Reuse the admin interface visual language with a static CSS translation

- Decision: Recreate the admin UI's dark indigo gradient backdrop, rounded card surfaces, indigo action buttons, white headings, slate body text, and compact navigation spacing in standalone CSS.
- Rationale: The spec requires visual consistency with the administration interface, and the existing UI already expresses a strong, modern look that can be translated into static marketing components.
- Alternatives considered:
  - Use Rails Tailwind output directly: rejected because the landing page must not depend on the Rails asset pipeline.
  - Introduce a separate design system: rejected because it would create unnecessary UX drift for this feature.

## Decision 4: Keep JavaScript minimal and non-critical

- Decision: Use minimal vanilla JavaScript only for progressive enhancements such as mobile navigation toggling, reveal-on-scroll, or CTA analytics-free interactions if needed.
- Rationale: The page must remain readable and useful with HTML and CSS alone, and minimizing JavaScript improves startup performance and reduces hosting complexity.
- Alternatives considered:
  - No JavaScript at all: viable, but rejected as the only option because a small amount of progressive enhancement can improve mobile navigation and polish.
  - A frontend framework: rejected because the page is a static marketing surface with no stateful client application needs.

## Decision 5: Validate behavior through static smoke tests plus manual responsive and performance review

- Decision: Plan for automated repository tests that verify required static files, key content structure, and repository CTA targets, complemented by manual viewport checks and a Lighthouse audit.
- Rationale: The constitution requires automated proof where feasible, while the spec also requires visual consistency and responsive behavior that still need manual browser validation.
- Alternatives considered:
  - Manual review only: rejected because it would not satisfy the repository's testing principle.
  - Full browser automation against GitHub Pages: rejected for the first implementation plan because it adds setup cost beyond the scope of a single static page.

## Decision 6: Treat the landing page as a marketing-focused document, not an application extension

- Decision: Model the page around content sections, feature highlights, and CTA links rather than adding runtime integrations with the API or admin application.
- Rationale: The feature is intended to explain value to prospects, and the specification explicitly excludes sign-in, live data, and backend interactions.
- Alternatives considered:
  - Embed live API examples fetched at runtime: rejected because it would add runtime dependencies and create failure modes outside the scope of a static page.
  - Mirror admin workflows interactively: rejected because that would blur the line between marketing content and product UI.
