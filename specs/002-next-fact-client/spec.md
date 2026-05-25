# Feature Specification: Next Fact by Client

**Feature Branch**: `[002-next-fact-client]`  
**Created**: 2026-05-24  
**Status**: Shipped  
**Input**: User description: "Je veux ajouter à l'API un nouvel endpoint \"next fact\" permettant de récupérer dans l'odre un fact depuis la liste des facts. L'objectif ici étant d'éviter au maximum de récupérer un fact déjà récupéré auparavant. Lorsque l'endpoint next arrive au bout des facts, il repart au début. Pour celà, il faut stocker en mémoire, pour un client identifié par un id, le dernier id du fact récupéré. Ainsi, chaque client, aura la possiblité de récupérer dans l'ordre la liste des facts, sans perturber la récupération des facts des les autres clients. L'interface d'administration permet de créer les clients éligibles à l'endpoint \"next fact\". Via l'interface d'administration on peut créer un client, consulter là où il est dans la récupération des facts (i.e. à quel id de fact il est), réinitialiser l'id de fact, supprimer un client. Sans identifant client connu du système, l'endpoint \"next fact\" doit retourner une erreur."

## Clarifications

### Session 2026-05-24

- Q: Quel type d'identifiant client doit être utilisé pour le endpoint next fact ? → A: Le système génère automatiquement un identifiant client opaque et unique.
- Q: Quand un nouveau fact est ajouté pendant qu'un client est déjà en cours de lecture, quand devient-il éligible pour ce client ? → A: Un nouveau fact devient immédiatement éligible dans l'ordre courant du client.
- Q: Comment le système doit-il gérer deux requêtes simultanées pour un même client ? → A: Deux requêtes simultanées du même client doivent recevoir deux facts consécutifs distincts si disponibles.
- Q: Comment l'administrateur accède-t-il à l'identifiant client généré par le système ? → A: L'identifiant client est visible et copiable dans la liste et ou la fiche du client.
- Q: Quel niveau d'authentification côté client est requis pour appeler next fact ? → A: L'identifiant client seul suffit pour appeler next fact.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrieve the next fact for a known client (Priority: P1)

En tant que client autorisé de l'API publique, je veux demander le prochain fact de ma séquence afin de parcourir l'ensemble des facts dans un ordre stable sans recevoir inutilement les mêmes facts avant la fin du cycle.

**Why this priority**: C'est la valeur principale de la fonctionnalité. Sans cette capacité, il n'y a ni progression par client ni réduction concrète des répétitions.

**Independent Test**: Peut être testé indépendamment en enregistrant un client autorisé, en appelant plusieurs fois le point d'accès next fact avec son identifiant, puis en vérifiant que les facts sont renvoyés dans l'ordre attendu et qu'après le dernier fact la séquence repart au début.

**Acceptance Scenarios**:

1. **Given** un client autorisé sans historique de lecture et plusieurs facts disponibles, **When** ce client appelle le point d'accès next fact, **Then** le système renvoie le premier fact de l'ordre canonique et mémorise cette position pour ce client.
2. **Given** un client autorisé ayant déjà reçu un fact, **When** ce client appelle à nouveau le point d'accès next fact, **Then** le système renvoie le fact suivant dans l'ordre canonique et met à jour la position mémorisée de ce client.
3. **Given** un client autorisé ayant déjà reçu le dernier fact disponible dans l'ordre canonique, **When** ce client appelle le point d'accès next fact, **Then** le système renvoie à nouveau le premier fact disponible et démarre un nouveau cycle pour ce client.
4. **Given** deux clients autorisés distincts avec des historiques de lecture différents, **When** chacun appelle le point d'accès next fact, **Then** le système applique à chacun sa propre position mémorisée sans perturber la progression de l'autre.
5. **Given** un client autorisé en cours de cycle et un nouveau fact ajouté avec un identifiant qui l'insère plus loin dans l'ordre canonique, **When** ce client poursuit ses appels next fact, **Then** le système prend immédiatement en compte ce nouveau fact à sa position normale dans l'ordre courant.
6. **Given** deux requêtes simultanées pour un même client et au moins deux facts disponibles dans la suite canonique restante, **When** le système traite ces deux requêtes, **Then** il renvoie deux facts consécutifs distincts et avance la progression du client de deux positions sans doublon entre ces deux réponses.

---

### User Story 2 - Reject unknown clients (Priority: P2)

En tant qu'exploitant de l'API, je veux que seuls les clients connus du système puissent utiliser le point d'accès next fact afin de contrôler qui bénéficie de la progression mémorisée.

**Why this priority**: La règle d'éligibilité des clients protège le comportement métier du point d'accès. Sans elle, le système ne peut pas distinguer les consommateurs autorisés des appels invalides.

**Independent Test**: Peut être testé indépendamment en appelant le point d'accès next fact avec un identifiant inconnu, absent ou supprimé, puis en vérifiant qu'aucun fact n'est renvoyé et qu'une erreur explicite est produite.

**Acceptance Scenarios**:

1. **Given** un identifiant client inconnu du système, **When** un appel est fait au point d'accès next fact, **Then** le système refuse la requête et renvoie une erreur claire sans fact.
2. **Given** un client précédemment autorisé mais supprimé de l'administration, **When** un appel est fait avec cet identifiant, **Then** le système refuse la requête et ne reprend pas l'ancien historique.
3. **Given** une requête sans identifiant client exploitable, **When** le point d'accès next fact est appelé, **Then** le système renvoie une erreur claire indiquant que le client ne peut pas être reconnu.
4. **Given** un identifiant client valide, **When** le point d'accès next fact est appelé sans autre secret ni authentification complémentaire, **Then** le système traite la requête normalement sur la seule base de cet identifiant.

---

### User Story 3 - Administer eligible clients and their progress (Priority: P3)

En tant qu'administrateur authentifié, je veux créer des clients éligibles, consulter leur position courante, réinitialiser leur progression et les supprimer afin de contrôler l'accès au point d'accès next fact et de piloter leur cycle de lecture.

**Why this priority**: Une fois le parcours API défini, l'administration des clients permet d'exploiter durablement la fonctionnalité et de corriger les situations opérationnelles sans toucher aux autres clients.

**Independent Test**: Peut être testé indépendamment après authentification en créant un client, en vérifiant sa position initiale, en observant sa progression après des appels API, puis en réinitialisant et supprimant ce client depuis l'interface d'administration.

**Acceptance Scenarios**:

1. **Given** un administrateur authentifié, **When** il crée un nouveau client éligible, **Then** le système enregistre ce client avec une progression initiale vide et le rend immédiatement disponible dans l'administration.
2. **Given** un administrateur authentifié, **When** il crée un nouveau client éligible, **Then** le système génère automatiquement pour ce client un identifiant opaque unique utilisable avec le point d'accès next fact.
3. **Given** un administrateur authentifié et un client existant, **When** l'administrateur consulte la liste ou la fiche de ce client, **Then** le système affiche son identifiant opaque en clair et permet de le copier sans ressaisie manuelle.
4. **Given** un administrateur authentifié et un client ayant déjà consommé des facts, **When** l'administrateur consulte ce client, **Then** le système affiche le dernier identifiant de fact atteint ou indique clairement qu'aucun fact n'a encore été servi.
5. **Given** un administrateur authentifié et un client existant, **When** l'administrateur réinitialise sa progression, **Then** le système efface la position mémorisée et le prochain appel next fact pour ce client repart du début de la liste.
6. **Given** un administrateur authentifié et un client existant, **When** l'administrateur supprime ce client, **Then** le système retire son éligibilité au point d'accès next fact et son identifiant n'est plus accepté.

### Edge Cases

- Que se passe-t-il si aucun fact n'est disponible au moment où un client autorisé demande le prochain fact.
- Comment le système gère-t-il le cas où le fact mémorisé pour un client a été supprimé depuis son dernier appel.
- Comment le système gère-t-il l'ajout d'un nouveau fact pendant qu'un client est déjà engagé dans un cycle de lecture.
- Comment le système maintient-il une progression cohérente quand deux requêtes pour un même client arrivent simultanément.
- Comment le système se comporte-t-il si un administrateur réinitialise un client pendant qu'un autre client continue sa propre progression.
- Comment l'administration présente-t-elle de manière cohérente les états sans progression, après réinitialisation, après suppression, en cas d'erreur de validation et en cas d'identifiant client devenu invalide.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a public next fact capability that returns at most one fact per successful request for a known client.
- **FR-002**: System MUST require only a client identifier recognized by the system before serving a next fact, with no additional client secret or stronger client authentication in this feature scope.
- **FR-003**: System MUST maintain an independent reading position for each known client so that one client's requests never change another client's progression.
- **FR-004**: System MUST serve facts to each known client in a single canonical order based on ascending fact identifier.
- **FR-005**: System MUST start a newly created or reset client at the beginning of the canonical fact order on its next successful request.
- **FR-006**: System MUST update the stored reading position for a client immediately after each successful next fact delivery.
- **FR-007**: System MUST wrap back to the first available fact after a client reaches the last available fact in the canonical order.
- **FR-008**: System MUST reject requests made with an unknown, missing, unusable, or deleted client identifier and return a clear error without any fact content.
- **FR-009**: System MUST minimize repeated facts for a given client by not serving the same fact again until that client has reached the end of the currently available ordered list, except when the total number of available facts is one.
- **FR-010**: System MUST provide a clear unavailable-content response when no fact is available to serve to a known client.
- **FR-011**: System MUST allow an authenticated administrator to create an eligible client for the next fact capability.
- **FR-012**: System MUST generate an opaque unique client identifier when an administrator creates an eligible client.
- **FR-013**: System MUST allow an authenticated administrator to view the list of eligible clients and each client's current progression state.
- **FR-014**: System MUST display each eligible client's opaque identifier in the administration interface and allow an administrator to copy it without manual re-entry.
- **FR-015**: System MUST display each client's current progression as the last fact identifier served, or as an explicit no-progress state when no fact has yet been delivered.
- **FR-016**: System MUST allow an authenticated administrator to reset a client's progression without affecting any other client.
- **FR-017**: System MUST allow an authenticated administrator to delete an eligible client, after which that identifier is no longer accepted by the next fact capability.
- **FR-018**: System MUST preserve a deleted client's historical position only as long as needed to prevent it from being used again; after deletion, the identifier must not recover its prior progression implicitly.
- **FR-019**: System MUST ensure that if a client's last served fact is no longer available, the next successful request continues from the next available position in the canonical order, or restarts from the beginning when no later fact remains.
- **FR-020**: System MUST treat newly added facts as immediately eligible for subsequent next fact requests and insert them according to the canonical fact order without resetting unaffected clients.
- **FR-021**: System MUST keep the administration experience consistent with existing administration patterns by providing clear states for creation, empty progression, reset confirmation, deletion confirmation, validation errors, rejected access, and identifier copy access.
- **FR-022**: System MUST make successful administrative changes visible in the administration interface as part of the completed action flow.
- **FR-023**: System MUST process simultaneous next fact requests for the same client so that each successful request advances that client's progression exactly once and returns a distinct consecutive fact when enough facts are available.
- **FR-024**: System MUST support the next fact retrieval flow such that an authorized client receives a response quickly enough to feel immediate during normal usage.

### Key Entities *(include if feature involves data)*

- **Eligible Client**: Un consommateur autorisé à utiliser la récupération séquentielle des facts, identifié par un identifiant opaque unique généré par le système.
- **Client Progression**: L'état mémorisé qui associe un client éligible au dernier identifiant de fact qui lui a été servi, ou à l'absence de progression avant toute consommation.
- **Fact Sequence**: L'ensemble des facts actuellement disponibles, ordonnés selon l'identifiant de fact croissant et utilisés comme référence commune pour la progression des clients.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of successful next fact requests for known clients return a fact in under 2 seconds under normal operating conditions.
- **SC-002**: 100% of next fact requests made with an unknown, missing, or deleted client identifier are rejected without returning a fact.
- **SC-003**: For any known client with at least two available facts, 100% of the facts served across one full cycle are unique until the cycle wraps to the beginning.
- **SC-004**: An authenticated administrator can create, inspect, reset, or delete an eligible client in under 30 seconds during routine use.
- **SC-005**: In 100% of primary administration flows, the interface shows an explicit outcome state for success, validation failure, rejected access, empty progression, and reset or deletion completion.

## Assumptions

- L'identifiant client est fourni par le consommateur de l'API à chaque appel next fact et correspond à un client préalablement enregistré dans le système.
- L'identifiant client n'est pas saisi librement par l'administrateur; il est généré par le système lors de la création du client éligible.
- L'identifiant client généré doit rester consultable par un administrateur après création afin de pouvoir être communiqué au consommateur autorisé.
- Le contrat d'accès du endpoint next fact repose uniquement sur la connaissance d'un identifiant client valide reconnu par le système.
- Le périmètre couvre seulement la gestion des clients éligibles et de leur progression; la gestion éditoriale des facts existants reste inchangée.
- Réinitialiser un client signifie effacer sa progression pour que son prochain appel reparte du premier fact disponible dans l'ordre canonique.
- Un fact ajouté devient immédiatement éligible aux appels suivants et s'insère dans la séquence selon l'ordre canonique sans attendre un nouveau cycle complet.
- En cas de requêtes simultanées pour un même client, le système doit préserver une avancée atomique de la progression afin d'éviter qu'un même fact soit servi deux fois alors que des facts distincts sont disponibles.
- Lorsqu'aucun fact n'est disponible, le système renvoie une réponse métier explicite indiquant l'absence de contenu à servir plutôt qu'un fact vide.
