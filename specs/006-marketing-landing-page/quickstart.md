# Quickstart: Facthub Marketing Landing Page

## Goal

Build and review a static marketing landing page served from `docs/` and publishable through GitHub Pages at `https://saumon.github.io/facthub/`.

## File layout

```text
docs/
├── index.html
└── assets/
    ├── styles.css
    ├── app.js          # Optional, only if progressive enhancement is needed
    └── images/
```

Only create files that are actually needed. The page must remain functional if `app.js` is omitted.

## Implementation steps

1. Create `docs/index.html` as the single page entry point.
2. Add standalone styles in `docs/assets/styles.css` that reproduce the admin UI's dark indigo gradient, rounded cards, and indigo button treatments.
3. Add minimal `docs/assets/app.js` only if progressive enhancement is needed for mobile navigation or subtle non-critical motion.
4. Keep all asset URLs relative to `docs/index.html`, for example `./assets/styles.css`.
5. Write English marketing copy that leads with curated fact management and controlled fact delivery for content managers and product owners.
6. Add a primary CTA linking to the public GitHub repository.
7. Ensure the page remains readable if images or JavaScript do not load.

## Validation steps

1. Open `docs/index.html` directly in a browser from the filesystem and confirm the page renders without a server.
2. Open the same page through a local static file preview or GitHub Pages preview path and confirm relative assets resolve.
3. Check desktop and mobile viewports, including a narrow mobile width, and verify no horizontal scrolling occurs.
4. Confirm the hero communicates the product purpose and intended audience within 30 seconds.
5. Confirm the CTA points to the public GitHub repository.
6. Run the repository test command covering static landing page checks.
7. Run a Lighthouse audit or equivalent browser performance review to verify the initial readable content target.
