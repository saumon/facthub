# Contract: Static Landing Page Surface

## Purpose

Define the externally visible contract for the static marketing landing page published from `docs/`.

## Entry point

- Public entry point: `docs/index.html`
- Published URL: `https://saumon.github.io/facthub/`
- Local review mode: direct filesystem opening of `docs/index.html`

## Asset contract

- All required styles and scripts must be loaded via relative URLs that resolve from `docs/index.html`.
- The page must not require Rails routes, server-rendered templates, import maps, or API calls to render its primary experience.
- Decorative assets are optional; core meaning must remain available without them.

## Content contract

The page must expose these user-visible content regions in order:

1. A hero section that explains Facthub as a product for curated fact management and controlled fact delivery.
2. A feature section highlighting core capabilities in prospect-friendly language.
3. Supporting proof or benefits sections that reinforce the product's value for content managers and product owners.
4. A primary call to action linking to the public GitHub repository.

## Interaction contract

- Core navigation and content comprehension must work without JavaScript.
- Any JavaScript enhancement must be non-critical and must not block first render.
- Interactive elements must remain keyboard reachable and usable on touch devices.

## Responsive contract

- The page must support laptop and smartphone viewports.
- No primary content may require horizontal scrolling at common mobile widths.
- Calls to action must remain visible and tappable on mobile.

## Performance contract

- Primary visible content must become readable within 2 seconds on a typical consumer connection.
- Non-critical scripts must be deferred or omitted.
- Asset size and rendering choices must prioritize fast first paint over decorative complexity.
