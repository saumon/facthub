# Feature Specification: Client Alias Management

**Feature Branch**: `005-client-alias`  
**Created**: 2026-05-25  
**Status**: Shipped
**Input**: User description: "Je veux pouvoir saisir un alias de client, lors de la creation d'un client. L'alias est juste a titre informatif. Les alias doivent apparaitre dans l'ecran de liste des clients. L'alias peut etre modifie a tout moment. L'alias doit egalement etre visible dans l'ecran de visualisation d'un client."

## Clarifications

### Session 2026-05-25

- Q: Where should administrators edit an existing client alias? → A: On the client detail page via a dedicated form on that page.
- Q: How should alias whitespace be normalized when saving? → A: Trim leading and trailing whitespace, but preserve internal spaces as entered.
- Q: When an alias exists, should the UI still show the client identifier? → A: Yes, show the alias while keeping the client identifier visible in management views.
- Q: What exact fallback text should be shown when no alias exists? → A: Use the exact text "No alias defined" in all management views.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a client with an alias (Priority: P1)

An administrator can optionally assign a human-readable alias while creating a new client so the client can be recognized immediately after creation without relying only on the generated identifier.

**Why this priority**: Client creation is the entry point for the workflow. If alias capture is missing there, administrators must create the client first and then perform extra work to label it.

**Independent Test**: Can be fully tested by creating one client with an alias and one client without an alias, then confirming both creations succeed and the alias appears only where expected.

**Acceptance Scenarios**:

1. **Given** an authenticated administrator is on the new client form, **When** they provide a valid alias and create the client, **Then** the client is created successfully and the alias is shown on the resulting client detail view.
2. **Given** an authenticated administrator is on the new client form, **When** they leave the alias blank and create the client, **Then** the client is created successfully and the interface shows the exact fallback text "No alias defined" where alias information is displayed.

---

### User Story 2 - Update an existing client alias (Priority: P2)

An administrator can add, change, or clear a client's alias at any time from a dedicated form on the client detail page so that the displayed label stays aligned with operational needs.

**Why this priority**: The user explicitly requires aliases to remain editable over time. Without this capability, alias data would become stale and lose value.

**Independent Test**: Can be fully tested by opening an existing client detail page, changing its alias in the dedicated alias form, saving, and confirming the new value replaces the old value everywhere the client is shown.

**Acceptance Scenarios**:

1. **Given** an existing client has an alias, **When** the administrator updates the alias from the dedicated form on the client detail page and saves, **Then** the new alias is persisted and displayed on the client detail view and client list.
2. **Given** an existing client has an alias, **When** the administrator clears the alias from the dedicated form on the client detail page and saves, **Then** the alias is removed and the interface falls back to the exact text "No alias defined" in management views.

---

### User Story 3 - Identify clients by alias in management views (Priority: P3)

An administrator can see each client's alias in the client list and on the client detail page so they can distinguish clients faster during review and support tasks.

**Why this priority**: Visibility is the payoff for collecting the alias. It is valuable, but it depends on the alias data existing first.

**Independent Test**: Can be fully tested by visiting the client list and client detail page for clients with and without aliases and verifying the displayed information matches the saved state.

**Acceptance Scenarios**:

1. **Given** multiple clients exist, **When** the administrator opens the client list, **Then** each row shows the alias for labeled clients while keeping the client identifier visible, and shows the exact fallback text "No alias defined" for unlabeled clients.
2. **Given** a client exists, **When** the administrator opens that client's detail page, **Then** the page shows the alias when present while keeping the client identifier visible, and shows the exact fallback text "No alias defined" when absent.

### Edge Cases

- A client is created with an alias that contains only whitespace; the system should treat it as empty and keep the client creatable without storing a meaningless label.
- Leading and trailing whitespace in an alias should be removed before validation and persistence, while internal spacing remains unchanged.
- Two or more clients share the same alias; the system should allow this because the alias is informational only and must not replace the client identifier as the true unique reference.
- An administrator enters an alias whose trimmed value exceeds 100 characters as counted by the standard Rails length validation; the system should reject the change with clear guidance instead of truncating it silently.
- A client created before this feature has no alias; the list and detail screens should continue to work and should show the same no-alias fallback as newly created unlabeled clients.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow an authenticated administrator to optionally provide a client alias during client creation.
- **FR-002**: The system MUST store the client alias as informational data associated with the client without altering the client identifier or progression state.
- **FR-003**: The system MUST allow an authenticated administrator to add, change, or remove a client alias after the client has been created from a dedicated form on the client detail page.
- **FR-004**: The system MUST display the current alias on the client detail view whenever an alias exists while keeping the client identifier visible.
- **FR-005**: The system MUST display the current alias in the client list for every client whenever an alias exists while keeping the client identifier visible.
- **FR-006**: The system MUST show the exact fallback text "No alias defined" in client management views when no alias is defined.
- **FR-007**: The system MUST trim leading and trailing whitespace from alias input before validation and persistence.
- **FR-008**: The system MUST treat alias input containing only whitespace as empty input after trimming.
- **FR-009**: The system MUST allow multiple clients to share the same alias because aliases are not unique identifiers.
- **FR-010**: The system MUST validate alias input so that values whose trimmed length exceeds 100 characters, as counted by the standard Rails length validation, are rejected with clear feedback before saving.
- **FR-011**: The system MUST make alias changes visible in the affected client management views immediately after a successful save.
- **FR-012**: The system MUST preserve the existing client management interaction patterns for navigation, confirmation, success messaging, empty states, and error handling unless a deviation is explicitly approved.
- **FR-013**: The system MUST support client creation, client detail viewing, client list viewing, and alias updates with alias information visible in under 2 seconds for at least 95% of administrator interactions when managing up to 500 clients.

### Key Entities *(include if feature involves data)*

- **Client**: A managed client record identified by a system-generated identifier, with optional informational alias text and existing progression data.
- **Client Alias**: A human-readable label attached to a client for administrator recognition, editable over time and not required to be unique.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In acceptance testing, 100% of newly created clients can be saved successfully whether an administrator provides a valid alias or leaves the alias empty.
- **SC-002**: In acceptance testing, 100% of clients created or updated with an alias display the same alias on the client detail view and the client list immediately after saving while the client identifier remains visible in both views.
- **SC-003**: In acceptance testing, 100% of alias removals result in the exact fallback text "No alias defined" being shown consistently across client management views without changing the client identifier or progression data.
- **SC-004**: In a representative manual walkthrough of 20 client-creation attempts with alias entry, at least 19 attempts complete in under 30 seconds from opening the new-client page to seeing the creation success state.
- **SC-005**: Client list, detail, creation confirmation, and alias update confirmation remain visible to administrators in under 2 seconds for at least 95% of interactions with up to 500 clients.

## Assumptions

- Alias support applies only to the authenticated admin client management experience and does not change public client-facing behavior.
- The alias is optional and purely descriptive; uniqueness, search, filtering, and sorting by alias are out of scope for this feature.
- Existing client records may remain without aliases until an administrator chooses to add one.
- Existing authentication and authorization rules for client management remain unchanged.
