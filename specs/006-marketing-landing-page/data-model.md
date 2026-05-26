# Data Model: Facthub Marketing Landing Page

## Overview

This feature does not introduce persisted application data. The relevant entities are static content entities used to structure the landing page and verify its completeness.

## Entities

### LandingPage

- Description: The single static marketing document published from `docs/index.html`.
- Fields:
  - `title`: Browser and hero-facing page title.
  - `description`: Meta description summarizing the product value.
  - `sections`: Ordered collection of landing page sections.
  - `primary_cta_url`: Public GitHub repository link.
- Validation rules:
  - Must render without server-side data.
  - Must include at least one hero section, one features section, and one CTA.
  - Must use only static asset references that work from `docs/`.

### LandingPageSection

- Description: A content block with a distinct communication goal and visual treatment.
- Fields:
  - `id`: Stable anchor identifier for intra-page navigation.
  - `heading`: Section heading visible to the user.
  - `supporting_copy`: Body copy describing the section value.
  - `layout_variant`: Presentation mode such as hero, feature grid, benefits strip, proof block, or footer CTA.
  - `position`: Ordered position on the page.
- Validation rules:
  - IDs must be unique within the page.
  - Headings must remain understandable out of context.
  - Section order must support prospect comprehension from value proposition to feature proof to CTA.

### FeatureHighlight

- Description: A highlighted product capability presented in marketing language.
- Fields:
  - `name`: Capability label.
  - `benefit_statement`: Prospect-facing value explanation.
  - `supporting_detail`: Optional short proof or explanation.
  - `emphasis_level`: Primary or secondary.
- Validation rules:
  - Primary highlights must cover curated fact management and controlled fact delivery.
  - Supporting details must reflect current product capabilities only.
  - Copy must remain understandable to non-technical prospects.

### ProspectCallToAction

- Description: The page element that directs an interested visitor to the next step.
- Fields:
  - `label`: Visible CTA text.
  - `url`: Public GitHub repository URL.
  - `placement`: Hero, footer, or both.
  - `style_variant`: Primary or secondary CTA styling.
- Validation rules:
  - At least one primary CTA must link to the public repository.
  - CTA label must describe the destination clearly.
  - CTA must remain visible and tappable on mobile.

## Relationships

- A `LandingPage` contains many `LandingPageSection` entities.
- A `LandingPageSection` may contain zero or more `FeatureHighlight` entities.
- A `LandingPage` contains one or more `ProspectCallToAction` entities referencing the same public repository destination.

## State Transitions

- None. The page is static and has no persisted user or system state transitions.
