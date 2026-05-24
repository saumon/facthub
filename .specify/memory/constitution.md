<!--
Sync Impact Report
Version change: template -> 1.0.0
Modified principles:
- Template Principle 1 -> I. Code Quality Is a Release Gate
- Template Principle 2 -> II. Tests Prove Behavior
- Template Principle 3 -> III. User Experience Stays Consistent
- Template Principle 4 -> IV. Performance Budgets Are Explicit
Added sections:
- Delivery Standards
- Review and Quality Gates
Removed sections:
- Template Principle 5
Templates requiring updates:
- ✅ updated .specify/templates/plan-template.md
- ✅ updated .specify/templates/spec-template.md
- ✅ updated .specify/templates/tasks-template.md
Follow-up TODOs:
- None
-->

# FactHub Constitution

## Core Principles

### I. Code Quality Is a Release Gate

All production changes MUST be small enough to review, MUST preserve clear module
boundaries, and MUST leave touched code more readable than before. Every change
MUST pass repository formatting, linting, and static analysis checks before review
approval. Temporary shortcuts, dead code, and undocumented branching logic MUST
be removed or explicitly justified in the implementation plan.

Rationale: maintainability degrades through unchecked local exceptions; reviewable,
well-scoped changes keep the codebase understandable as FactHub grows.

### II. Tests Prove Behavior

Every feature change MUST define automated tests for its intended behavior before
the implementation is considered complete. Bug fixes MUST include a regression test
that fails without the fix. Plans and tasks MUST name the required test levels for
the affected slice, with unit tests for local logic and integration or end-to-end
tests for user-visible flows, contracts, or cross-boundary behavior.

Rationale: executable proof is the only reliable way to prevent regressions and to
show that specifications and implementation still match.

### III. User Experience Stays Consistent

User-facing work MUST reuse established content patterns, interaction rules, visual
tokens, and accessibility behaviors unless the specification explicitly approves a
change to the product language. Each specification MUST describe the affected user
journey, consistency constraints, and acceptance criteria for errors, empty states,
and feedback states. Reviews MUST reject changes that introduce avoidable UX drift.

Rationale: consistency reduces user friction, shortens learning time, and keeps new
features aligned with the product users believe they are already using.

### IV. Performance Budgets Are Explicit

Every feature specification and implementation plan MUST define measurable
performance expectations for the critical path it changes, including latency,
throughput, rendering responsiveness, resource usage, or build-time impact as
appropriate. Implementations MUST include measurement or validation steps when a
change can affect those budgets, and a change MUST NOT ship if it knowingly breaks
an agreed budget without an approved exception.

Rationale: performance regressions are product regressions; explicit budgets make
trade-offs visible early enough to manage them.

## Delivery Standards

Specifications MUST include independently testable user stories, measurable success
criteria, UX consistency expectations, and quantified performance targets for each
critical journey. Implementation plans MUST translate those requirements into
quality gates, validation commands, and explicit exceptions when a principle cannot
be fully met. Task lists MUST include the work needed for automated tests, UX
validation, and performance verification rather than treating them as optional
polish.

## Review and Quality Gates

Before implementation begins, the Constitution Check in the plan MUST confirm how
the work satisfies code quality, testing, UX consistency, and performance budget
requirements. Before merge, reviewers MUST verify that required automated checks
ran, user-facing acceptance criteria were covered, and any performance claims were
measured with project-appropriate evidence. Unresolved exceptions MUST be tracked
in the plan with owner, rationale, and expiration criteria.

## Governance

This constitution overrides conflicting local habits and template defaults. Changes
to this constitution MUST be made in the same pull request as any dependent
template or workflow updates they require. Semantic versioning applies to this
document: MAJOR for incompatible governance changes or principle removal, MINOR for
new principles or materially expanded obligations, and PATCH for clarifications
that do not change enforcement. Compliance review is mandatory for every plan,
specification, task list, and pull request that claims readiness for implementation
or merge.

**Version**: 1.0.0 | **Ratified**: 2026-05-23 | **Last Amended**: 2026-05-23
