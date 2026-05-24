# Feature Specification: Fact Hub Public API and Admin

**Feature Branch**: `[001-fact-hub-api-admin]`  
**Created**: 2026-05-23  
**Status**: Shipped  
**Input**: User description: "je veux contruire une API Rest nommée Fact Hub, permettant à un client de récupérer un fun fact aléatoire. En complément de cette API, je veux aussi une interface web d'administration permettant de gérer les fun facts. Un fun fact consiste en une phrase texte. En détail il faut : une api simple, sans besoin d'authentification. celle-ci donne au hasard un fun fact persisté en base de données. une interface d'administration qui permet d'afficher la liste complète des fun facts, et aussi les modifier (ajout, modification, suppression). l'accès à l'interface d'administration doit se faire via login d'un compte administrateur"

## Clarifications

### Session 2026-05-23

- Q: Quel modèle d'authentification doit être retenu pour l'interface d'administration ? → A: Un compte administrateur local avec identifiant et mot de passe.
- Q: Quand aucun fun fact n'est disponible, quel comportement métier doit adopter l'API publique ? → A: Retourner une réponse d'indisponibilité claire, sans fun fact.
- Q: Quel comportement doit avoir l'interface d'administration quand la session administrateur expire ? → A: Bloquer les actions, rediriger vers la connexion et demander une nouvelle authentification.
- Q: Quelle règle métier faut-il appliquer si un administrateur tente d'enregistrer deux fun facts avec exactement le même texte ? → A: Refuser les doublons exacts.
- Q: Quel cycle de vie doit avoir un fun fact dans ce périmètre ? → A: Un fun fact existe jusqu'à sa suppression, sans état actif ou inactif distinct.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrieve a random fun fact (Priority: P1)

En tant que client de l'API publique, je veux récupérer un fun fact aléatoire afin d'afficher rapidement un contenu surprenant sans authentification ni configuration préalable.

**Why this priority**: C'est la valeur principale du produit Fact Hub. Sans cette capacité, le service n'apporte aucune valeur aux consommateurs externes.

**Independent Test**: Peut être testé indépendamment en appelant l'API publique sans identifiants et en vérifiant qu'un fun fact persisté est renvoyé au format attendu.

**Acceptance Scenarios**:

1. **Given** au moins un fun fact est disponible, **When** un client appelle le point d'accès public, **Then** le système renvoie un unique fun fact choisi aléatoirement parmi les fun facts stockés qui n'ont pas été supprimés.
2. **Given** plusieurs fun facts sont disponibles, **When** un client appelle plusieurs fois le point d'accès public, **Then** le système peut renvoyer des fun facts différents sans exiger d'authentification.
3. **Given** aucun fun fact n'est disponible, **When** un client appelle le point d'accès public, **Then** le système renvoie une réponse d'indisponibilité claire, sans fun fact, pour indiquer qu'aucun contenu ne peut être fourni pour le moment.

---

### User Story 2 - Access the administration area (Priority: P2)

En tant qu'administrateur, je veux me connecter à l'interface d'administration afin d'accéder de manière sécurisée à la gestion des fun facts.

**Why this priority**: L'administration doit être protégée avant toute fonction d'édition. Cette story borne l'accès aux utilisateurs autorisés et protège l'intégrité du contenu.

**Independent Test**: Peut être testé indépendamment en essayant d'accéder à l'interface d'administration sans connexion, avec des identifiants invalides puis avec un compte administrateur valide.

**Acceptance Scenarios**:

1. **Given** un visiteur non authentifié, **When** il tente d'ouvrir l'interface d'administration, **Then** le système exige une authentification avant d'afficher les données d'administration.
2. **Given** un utilisateur saisit des identifiants administrateur valides, **When** il soumet le formulaire de connexion, **Then** le système lui ouvre une session d'administration et affiche la liste des fun facts.
3. **Given** un utilisateur saisit des identifiants invalides, **When** il soumet le formulaire de connexion, **Then** le système refuse l'accès et affiche un message d'erreur compréhensible.
4. **Given** un administrateur possède une session expirée, **When** il tente d'accéder à une page d'administration ou d'exécuter une action d'administration, **Then** le système bloque l'action, redirige vers la connexion et exige une nouvelle authentification.

---

### User Story 3 - Manage fun facts (Priority: P3)

En tant qu'administrateur authentifié, je veux consulter, ajouter, modifier et supprimer des fun facts afin de maintenir un catalogue exact et à jour.

**Why this priority**: Une fois l'accès sécurisé établi, la gestion du contenu permet de maintenir la qualité et la fraîcheur des réponses publiques.

**Independent Test**: Peut être testé indépendamment après connexion en vérifiant qu'un administrateur peut voir toute la liste, créer un nouveau fun fact, modifier un texte existant et supprimer un fun fact.

**Acceptance Scenarios**:

1. **Given** un administrateur authentifié, **When** il ouvre l'interface d'administration, **Then** le système affiche la liste complète des fun facts existants.
2. **Given** un administrateur authentifié, **When** il ajoute un nouveau fun fact textuel valide, **Then** le système l'enregistre et le rend disponible dans la liste d'administration.
3. **Given** un administrateur authentifié, **When** il modifie le texte d'un fun fact existant, **Then** le système enregistre la nouvelle version et l'affiche immédiatement dans la liste.
4. **Given** un administrateur authentifié, **When** il supprime un fun fact existant, **Then** le système retire ce fun fact de la liste d'administration et il n'est plus sélectionné pour la diffusion publique.
5. **Given** un administrateur authentifié, **When** il tente d'ajouter ou de modifier un fun fact pour reproduire exactement un texte déjà existant, **Then** le système refuse l'enregistrement et affiche une erreur de validation explicite.

---

### Edge Cases

- Que se passe-t-il si le catalogue est vide au moment où un client demande un fun fact aléatoire.
- Comment le système gère-t-il la tentative de création ou de modification d'un fun fact avec un texte vide, composé uniquement d'espaces ou dupliquant exactement un texte déjà existant.
- Comment l'interface d'administration se comporte-t-elle si un fun fact est supprimé pendant qu'un administrateur consulte la liste.
- Comment l'expérience reste-t-elle cohérente pendant les états de chargement, d'erreur de connexion, de session expirée et de récupération après une action d'administration.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a public API endpoint that returns exactly one random fun fact per successful request.
- **FR-002**: System MUST allow anonymous access to the public API endpoint without requiring authentication.
- **FR-003**: System MUST source public fun facts from persisted records rather than hard-coded content.
- **FR-004**: System MUST return the public response in a consistent structure containing the fun fact text.
- **FR-005**: System MUST return a clear unavailable-content response without a fun fact when no persisted fun fact is available to fulfill a public request.
- **FR-006**: System MUST provide an administration interface protected by login with a local administrator username and password.
- **FR-007**: System MUST prevent unauthenticated users from viewing the administration interface or performing administrative actions.
- **FR-008**: System MUST allow an authenticated administrator to view the complete list of stored fun facts.
- **FR-009**: System MUST allow an authenticated administrator to create a new fun fact by entering a text sentence.
- **FR-010**: System MUST allow an authenticated administrator to update the text of an existing fun fact.
- **FR-011**: System MUST allow an authenticated administrator to delete an existing fun fact.
- **FR-012**: System MUST validate that each fun fact contains non-empty text before saving administrative changes.
- **FR-013**: System MUST reject administrative create or update attempts that would produce two fun facts with exactly the same text.
- **FR-014**: System MUST make successful administrative changes visible in the administration interface without requiring a manual refresh beyond the completed action flow.
- **FR-015**: System MUST ensure deleted fun facts are no longer eligible for random public retrieval.
- **FR-016**: System MUST treat a fun fact as available for public retrieval from creation until deletion, with no separate active or inactive status in this feature scope.
- **FR-017**: System MUST define UX consistency for the administration flows by presenting clear states for loading, empty lists, validation errors, failed authentication, and successful save or delete actions.
- **FR-018**: System MUST support the public random fact retrieval flow such that a user receives a response quickly enough to feel immediate during normal usage.
- **FR-019**: System MUST support exactly one local administrator account in this feature scope.
- **FR-020**: System MUST block all administration page access and administration actions when the administrator session has expired, then require a new login.

### Key Entities *(include if feature involves data)*

- **Fun Fact**: Une unité de contenu composée d'une phrase textuelle unique, sans doublon textuel exact dans le catalogue, stockée de façon persistante et exposée soit dans l'interface d'administration, soit par tirage aléatoire via l'API publique.
- **Administrator Account**: Un compte local unique identifié par un identifiant et un mot de passe, autorisé à accéder à l'interface d'administration et à effectuer les opérations de création, modification et suppression sur les fun facts.
- **Administrator Session**: Une preuve de connexion active associée à un compte administrateur, utilisée pour autoriser les actions d'administration jusqu'à déconnexion ou expiration.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of public requests for a random fun fact return either a fun fact or a clear unavailable-content response without a fun fact in under 2 seconds under normal operating conditions.
- **SC-002**: 100% of attempts to open the administration interface without a valid administrator login are blocked from viewing administrative content.
- **SC-003**: An authenticated administrator can complete add, edit, or delete actions for a fun fact in under 30 seconds in routine usage.
- **SC-004**: At least 90% of administrative content changes are confirmed by administrators on the first attempt without needing to retry because of avoidable validation or flow confusion.
- **SC-005**: The administration interface presents explicit feedback for loading, success, validation error, and authentication failure states in 100% of the primary management flows.

## Assumptions

- L'API publique et l'interface d'administration concernent une première version web et ne nécessitent pas de parcours mobile dédié au-delà d'une consultation web standard.
- Le contenu d'un fun fact est limité à une seule phrase textuelle et ne comprend ni image, ni catégorie, ni métadonnées éditoriales dans ce périmètre.
- Un seul compte administrateur local est nécessaire dans ce périmètre.
- Le stock initial de fun facts peut être géré entièrement depuis l'interface d'administration; aucune importation en masse n'est requise.
- La politique exacte de rotation aléatoire n'a pas besoin de garantir une distribution uniforme parfaite à ce stade, tant que la sélection est aléatoire du point de vue utilisateur.
