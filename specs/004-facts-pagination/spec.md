# Feature Specification: Facts Pagination

**Feature Branch**: `[004-facts-pagination]`  
**Created**: 2026-05-25  
**Status**: Shipped
**Input**: User description: "La page de visualisation des facts doit etre paginee (10 facts par page). On doit pouvoir naviguer de page a page, mais aussi aller directement a la premiere et derniere page."

## Clarifications

### Session 2026-05-25

- Q: After a create, edit, or delete action, where should the administrator return in the paginated list? → A: Return to the same page when possible; if that page no longer exists after deletion, fall back to the nearest valid page.
- Q: How should the system handle a requested page number outside the valid range? → A: Redirect to the nearest valid page: below range goes to the first page, above range goes to the last page.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse facts in manageable pages (Priority: P1)

En tant qu'administrateur authentifie, je veux consulter la liste des facts par groupes de 10 afin de lire et parcourir la collection sans etre submerge par une liste trop longue.

**Why this priority**: La consultation de la liste des facts est l'entree principale de l'administration. Sans pagination, la page perd en lisibilite et en efficacite a mesure que le volume de facts augmente.

**Independent Test**: Peut etre teste independamment en ouvrant la liste des facts avec plus de 10 elements, puis en verifiant que seuls 10 facts sont affiches sur une page donnee et que le changement de page affiche le groupe suivant ou precedent sans modifier le contenu des facts.

**Acceptance Scenarios**:

1. **Given** une liste contenant plus de 10 facts, **When** l'administrateur ouvre la page de visualisation des facts, **Then** le systeme affiche uniquement les 10 premiers facts de la sequence de consultation et indique que d'autres pages sont disponibles.
2. **Given** une liste contenant plus de 10 facts et l'administrateur se trouve sur la premiere page, **When** il avance d'une page, **Then** le systeme affiche le groupe suivant de 10 facts dans le meme ordre global de consultation.
3. **Given** une liste contenant plus de 10 facts et l'administrateur se trouve sur une page intermediaire, **When** il revient a la page precedente, **Then** le systeme affiche le groupe precedent de facts sans doublonner ou omettre d'elements hors des limites normales de pagination.

---

### User Story 2 - Jump to the first or last page (Priority: P2)

En tant qu'administrateur authentifie, je veux aller directement a la premiere ou a la derniere page afin d'atteindre rapidement le debut ou la fin de la liste sans cliquer repetitivement sur la navigation page par page.

**Why this priority**: L'acces direct aux extremites reduit fortement les manipulations quand la liste est longue et complete la navigation standard attendue sur une liste paginee.

**Independent Test**: Peut etre teste independamment en ouvrant une liste sur plusieurs pages, puis en activant les actions de premiere et derniere page pour verifier que l'affichage saute directement vers l'extremite demandee.

**Acceptance Scenarios**:

1. **Given** une liste contenant plusieurs pages et l'administrateur se trouve sur une page autre que la premiere, **When** il demande l'affichage de la premiere page, **Then** le systeme affiche immediatement les 10 premiers facts de la liste.
2. **Given** une liste contenant plusieurs pages et l'administrateur se trouve sur une page autre que la derniere, **When** il demande l'affichage de la derniere page, **Then** le systeme affiche immediatement les facts de la derniere page avec un nombre d'elements inferieur ou egal a 10.

---

### User Story 3 - Keep navigation coherent at boundaries (Priority: P3)

En tant qu'administrateur authentifie, je veux que les controles de pagination restent coherents sur la premiere, la derniere, les pages vides et les cas limites afin d'eviter toute confusion ou navigation vers un etat invalide.

**Why this priority**: Une pagination utile doit rester explicite et previsible dans les situations limites, sinon elle degrade l'experience de consultation et genere des erreurs evitables.

**Independent Test**: Peut etre teste independamment en verifiant l'affichage des controles lorsque la liste contient 0 a 10 facts, un multiple exact de 10 facts, ou lorsqu'une page demandee n'est plus valide apres une suppression.

**Acceptance Scenarios**:

1. **Given** une liste contenant 10 facts ou moins, **When** l'administrateur ouvre la page, **Then** le systeme affiche l'ensemble des facts sur une seule page et ne propose pas de navigation active vers d'autres pages inexistantes.
2. **Given** une liste contenant un nombre de facts qui n'est pas un multiple de 10, **When** l'administrateur ouvre la derniere page, **Then** le systeme affiche uniquement les facts restants et conserve des controles de navigation coherents.
3. **Given** l'administrateur se trouve sur une page paginee et cree ou modifie un fact, **When** l'action se termine avec succes, **Then** le systeme le ramene sur cette meme page afin de preserver son contexte de navigation.
4. **Given** l'administrateur demande une page inferieure a la premiere page valide, **When** la liste est chargee, **Then** le systeme redirige vers la premiere page.
5. **Given** l'administrateur demande une page superieure a la derniere page valide ou qu'une suppression rend la page courante invalide, **When** la liste est reaffichee, **Then** le systeme affiche automatiquement la derniere page valide plutot qu'un etat vide non explicite ou une erreur bloquante.

### Edge Cases

- Que se passe-t-il lorsque la liste contient exactement 10 facts, afin d'eviter l'affichage de controles inutiles.
- Que se passe-t-il lorsque la derniere page contient moins de 10 facts.
- Comment le systeme se comporte-t-il si une page en dehors des bornes valides est demandee directement.
- Comment la page reste-t-elle coherente si la suppression d'un fact reduit le nombre total de pages et rend la page courante invalide.
- Comment le systeme preserve-t-il le contexte de pagination apres une creation ou une modification de fact.
- Comment l'experience conserve-t-elle les etats existants de liste vide, succes apres action, erreur et retour a la liste sans introduire d'incoherence visuelle.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the facts listing page in pages of at most 10 facts each.
- **FR-002**: System MUST preserve the current global consultation order of facts when splitting the listing into pages.
- **FR-003**: System MUST allow an authenticated administrator to move from the current page to the immediately previous or immediately next page whenever such a page exists.
- **FR-004**: System MUST allow an authenticated administrator to jump directly to the first page of the facts listing whenever more than one page exists.
- **FR-005**: System MUST allow an authenticated administrator to jump directly to the last page of the facts listing whenever more than one page exists.
- **FR-006**: System MUST clearly indicate the current page position and the total number of available pages whenever pagination is active.
- **FR-007**: System MUST keep first-page and previous-page navigation inactive or hidden when the administrator is already on the first page.
- **FR-008**: System MUST keep next-page and last-page navigation inactive or hidden when the administrator is already on the last page.
- **FR-009**: System MUST keep the existing empty-state experience for the facts listing when no fact exists.
- **FR-010**: System MUST avoid presenting pagination controls that imply additional pages when the listing contains 10 facts or fewer.
- **FR-011**: System MUST show the final page with only the remaining facts when the total count is not an exact multiple of 10.
- **FR-012**: System MUST redirect any requested page number below the valid range to the first page of the facts listing.
- **FR-013**: System MUST redirect any requested page number above the valid range to the last page of the facts listing.
- **FR-014**: System MUST keep the listing and its pagination controls consistent with the existing administration visual patterns unless an explicit approved deviation is introduced.
- **FR-015**: System MUST preserve the administrator's ability to reach fact actions from any paginated page without exposing facts from other pages on the same screen.
- **FR-016**: System MUST return the administrator to the same paginated page after a successful create or edit action whenever that page remains valid.
- **FR-017**: System MUST keep pagination usable after list changes such as deletion, including falling back to the nearest valid page when the previously viewed page is no longer valid.
- **FR-018**: System MUST load each page of the facts listing quickly enough to feel immediate during normal administration use.

### Key Entities *(include if feature involves data)*

- **Facts Listing Page**: Une vue de consultation qui presente un sous-ensemble ordonne de facts ainsi que les informations de pagination associees.
- **Pagination State**: L'etat de navigation qui represente le numero de page courant, le nombre total de pages et les actions de navigation disponibles depuis cette page.
- **Facts Slice**: Le groupe de 1 a 10 facts affiche simultanement pour une page donnee selon l'ordre de consultation etabli.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of facts listing pages show no more than 10 facts at a time.
- **SC-002**: 100% of administrators can reach the immediately next, immediately previous, first, and last available pages whenever those pages exist.
- **SC-003**: 100% of first-page and last-page boundary states present only valid navigation actions, with no path leading to an invalid page.
- **SC-004**: 95% of facts listing page loads complete in under 2 seconds under normal administration usage conditions.
- **SC-005**: In usability checks on the updated listing, administrators can identify their current page and total number of pages without ambiguity in 100% of tested multi-page scenarios.

## Assumptions

- La page de visualisation concernee est la liste d'administration des facts deja accessible aux administrateurs authentifies.
- Le perimetre couvre la consultation paginee de la liste existante et n'inclut pas de changement du contenu des facts, de leurs actions d'edition ou de leurs permissions d'acces.
- L'ordre de consultation des facts doit rester celui deja etabli par l'application avant l'ajout de la pagination.
- Les actions existantes de creation, modification et suppression de facts restent disponibles et conservent leur comportement metier actuel.
- Si une page invalide est demandee, le systeme doit privilegier une issue comprehensible pour l'administrateur plutot qu'une erreur bloquante.
