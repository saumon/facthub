# Feature Specification: Bulk Fact Import Setup

**Feature Branch**: `[003-admin-fact-import]`  
**Created**: 2026-05-25  
**Status**: Shipped
**Input**: User description: "depuis l'interface administrateur, je souhaite ajouter un menu \"setup\" permettant d'inserer en base un grand nombre de facts via sélection d'un fichier d'import. On doit pouvoir importer plusieurs fichiers, dans ce cas seuls les nouveaux facts devront être importés en base afin de ne pas avoir de doublons.

Le fichier d'import, est un fichier markdown et a la structure ci-dessous :

````markdown
# Fun facts database (FR)

- Fact x
- Fact y
- Fact z
````

## Clarifications

### Session 2026-05-25

- Q: Que faire si un fichier contient à la fois des lignes valides et au moins une ligne invalide ? → A: Rejeter entièrement le fichier concerné.
- Q: Comment traiter une ligne markdown non vide qui n'est ni un titre ni une puce ? → A: La considérer comme invalide et rejeter le fichier.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Importer de nouveaux facts en masse (Priority: P1)

En tant qu'administrateur authentifié, je veux accéder à un menu setup permettant de sélectionner un ou plusieurs fichiers d'import afin d'ajouter rapidement un grand nombre de facts sans saisie manuelle.

**Why this priority**: C'est la valeur principale de la demande. Sans ce flux d'import, le menu setup n'apporte pas de gain opérationnel.

**Independent Test**: Peut être testé indépendamment en ouvrant le menu setup, en sélectionnant un fichier markdown valide contenant plusieurs facts, puis en vérifiant que les nouveaux facts sont ajoutés et consultables dans l'administration.

**Acceptance Scenarios**:

1. **Given** un administrateur authentifié et un fichier markdown valide contenant des lignes de facts, **When** il lance l'import depuis le menu setup, **Then** le système ajoute en base chaque fact nouveau extrait du fichier.
2. **Given** un administrateur authentifié et plusieurs fichiers markdown valides, **When** il lance un import groupé, **Then** le système traite l'ensemble des fichiers dans une seule opération utilisateur et ajoute tous les facts nouveaux détectés.
3. **Given** un administrateur authentifié et un fichier markdown valide ne contenant aucun fact déjà présent, **When** l'import se termine, **Then** le système affiche un résultat explicite indiquant combien de facts ont été ajoutés.
4. **Given** un administrateur authentifié et un import en cours sur un ou plusieurs fichiers volumineux, **When** le traitement démarre, **Then** le système affiche une barre de chargement permettant de suivre l'avancement jusqu'à la fin de l'import.

---

### User Story 2 - Eviter les doublons lors des imports (Priority: P2)

En tant qu'administrateur authentifié, je veux que les facts déjà existants ou répétés dans plusieurs fichiers sélectionnés ne soient pas réimportés afin de garder une base propre sans doublons.

**Why this priority**: L'utilité métier de l'import dépend directement de la capacité à éviter la duplication de contenu lors des imports successifs ou multi-fichiers.

**Independent Test**: Peut être testé indépendamment en important plusieurs fichiers contenant des facts déjà présents en base et des facts répétés entre fichiers, puis en vérifiant que seuls les contenus réellement nouveaux sont ajoutés une seule fois.

**Acceptance Scenarios**:

1. **Given** un administrateur authentifié et un fichier contenant des facts déjà présents en base, **When** il lance l'import, **Then** le système n'ajoute pas ces facts en doublon et les comptabilise comme ignorés.
2. **Given** un administrateur authentifié et plusieurs fichiers sélectionnés contenant le même fact nouveau, **When** il lance l'import groupé, **Then** le système ajoute ce fact une seule fois.
3. **Given** un administrateur authentifié et un import où certains facts sont nouveaux et d'autres déjà connus, **When** l'import se termine, **Then** le système présente séparément le nombre de facts ajoutés et le nombre de facts ignorés car déjà connus.

---

### User Story 3 - Etre guidé en cas de fichier invalide ou vide (Priority: P3)

En tant qu'administrateur authentifié, je veux recevoir un retour clair quand un fichier ne respecte pas le format attendu ou ne contient aucun fact exploitable afin de corriger mon import sans ambiguïté.

**Why this priority**: Les imports en masse sont sensibles aux erreurs de contenu. Un retour explicite évite des imports incompris et réduit les reprises manuelles.

**Independent Test**: Peut être testé indépendamment en important un fichier vide, un fichier sans liste de facts exploitable, puis en vérifiant que le système refuse l'import concerné avec un message compréhensible et sans créer de facts parasites.

**Acceptance Scenarios**:

1. **Given** un administrateur authentifié et un fichier d'import vide, **When** il lance l'import, **Then** le système n'ajoute aucun fact et affiche que le fichier ne contient aucun fact exploitable.
2. **Given** un administrateur authentifié et un fichier qui contient une ligne markdown non vide qui n'est ni un titre ni une puce de fact, **When** il lance l'import, **Then** le système refuse ce fichier avec un message expliquant que seuls le titre, les lignes vides et les lignes de facts en puces sont autorisés.
3. **Given** un administrateur authentifié et un lot de plusieurs fichiers dont certains sont valides et d'autres invalides, **When** il lance l'import, **Then** le système importe uniquement les fichiers entièrement valides, rejette tout fichier contenant au moins une ligne invalide, et affiche pour chaque fichier un résultat explicite permettant d'identifier ceux qui ont été importés et ceux qui ont été refusés.

### Edge Cases

- Que se passe-t-il si plusieurs fichiers sélectionnés contiennent exactement les mêmes facts nouveaux.
- Comment le système gère-t-il un fichier markdown dont le titre est présent mais dont aucune ligne de liste ne contient de fact exploitable.
- Comment le système réagit-il lorsqu'un fichier contient à la fois des lignes valides, des doublons et des lignes non exploitables: le fichier complet est refusé.
- Comment le système réagit-il lorsqu'un fichier contient une ligne markdown non vide qui n'est ni un titre ni une puce: le fichier complet est refusé.
- Que se passe-t-il si un fichier d'import dépasse la limite de 10 000 lignes autorisée.
- Comment l'expérience reste-t-elle cohérente si un import n'ajoute aucun nouveau fact parce que tous les contenus existent déjà.
- Comment l'interface restitue-t-elle clairement les états de chargement, de succès complet, de succès partiel et d'échec de validation sans rompre les patterns existants de l'administration.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an authenticated administrator with a dedicated setup entry point inside the administration interface for bulk fact import.
- **FR-002**: System MUST allow an authenticated administrator to select one file or multiple files in a single import action.
- **FR-002A**: System MUST accept import files up to a maximum of 10,000 lines per file and MUST reject any file that exceeds that limit with an explicit validation message.
- **FR-003**: System MUST accept markdown import files whose only allowed non-empty content is a document title and usable fact entries expressed as one bullet-point fact per line.
- **FR-004**: System MUST ignore the markdown title line and blank lines when extracting facts from an import file.
- **FR-005**: System MUST create one new fact record for each imported fact text that is not already known to the system.
- **FR-006**: System MUST prevent duplicate fact creation when the same fact appears more than once within a single file.
- **FR-007**: System MUST prevent duplicate fact creation when the same fact appears across multiple files selected in the same import action.
- **FR-008**: System MUST prevent duplicate fact creation when an imported fact already exists in the current fact catalog.
- **FR-009**: System MUST treat duplicate prevention as a content comparison based on the fact text after trimming leading and trailing whitespace.
- **FR-010**: System MUST complete a multi-file import without requiring the administrator to import each file separately.
- **FR-011**: System MUST present an import result summary at the end of the import that distinguishes at minimum the number of facts added and the number ignored as duplicates.
- **FR-012**: System MUST provide file-level feedback whenever one or more selected files cannot be imported because they are empty, invalid, or contain no usable facts.
- **FR-013**: System MUST reject any selected file that either does not provide at least one usable bullet-point fact entry in the expected markdown structure or contains a non-empty markdown line that is neither the document title nor a bullet-point fact entry.
- **FR-014**: System MUST reject an entire import file when that file is refused for invalid or non-usable content, and it MUST avoid creating any fact from that refused file.
- **FR-015**: System MUST preserve results from other fully valid files when one file in a multi-file batch is refused, and it MUST report which files succeeded and which failed.
- **FR-016**: System MUST make newly added facts available through the existing administration flows immediately after a successful import completes.
- **FR-017**: System MUST keep the setup import experience consistent with existing administration patterns by showing clear loading, success, partial-success, duplicate-only, empty, and validation-error states.
- **FR-017A**: System MUST display a visible progress bar during import processing so an administrator can track advancement until completion.
- **FR-018**: System MUST provide an administrator-visible confirmation of the completed import action without requiring manual verification in the database.
- **FR-019**: System MUST process an import batch quickly enough that routine imports of typical markdown files feel responsive to an administrator during normal usage.
- **FR-020**: System MUST document the import setup feature in the English README, including how an administrator accesses and uses the markdown import flow.
- **FR-021**: System MUST add the feature to the README changelog under version 1.2.0 in English.

### Key Entities *(include if feature involves data)*

- **Import Batch**: Une action d'import lancée depuis le menu setup qui regroupe un ou plusieurs fichiers sélectionnés et produit un résultat global pour l'administrateur.
- **Import File**: Un fichier markdown fourni par l'administrateur, contenant un titre puis une liste de facts exprimés sous forme de puces exploitables.
- **Imported Fact Candidate**: Un texte de fact extrait d'une ligne de liste markdown et évalué pour déterminer s'il doit être ajouté ou ignoré comme doublon.
- **Import Result**: Le retour utilisateur de l'opération, incluant les volumes ajoutés, ignorés et les éventuels fichiers refusés.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An authenticated administrator can complete a standard import of up to 10,000 lines in a single markdown file, or an equivalent multi-file batch within the defined file-size limits, in under 2 minutes including file selection and result review.
- **SC-002**: 100% of facts already present before an import remain non-duplicated after the import completes.
- **SC-003**: 100% of duplicate facts repeated within the same batch are added at most once.
- **SC-004**: 95% of valid import batches present a visible outcome summary to the administrator in under 5 seconds after submission under normal operating conditions.
- **SC-005**: In 100% of tested import outcomes, the interface communicates a distinct and understandable state for success, duplicate-only import, invalid file, empty file, and mixed-result batch.

## Assumptions

- Le menu setup est réservé aux administrateurs déjà authentifiés dans l'interface d'administration existante.
- Le périmètre couvre l'import de nouveaux facts uniquement; il ne couvre ni mise à jour, ni suppression, ni fusion manuelle de facts existants.
- Le format attendu autorise uniquement un titre markdown de document, des lignes vides et des lignes de liste markdown commençant par un bullet simple suivi du texte du fact.
- Le titre markdown du fichier sert de contexte de document mais n'est pas importé comme fact.
- Deux facts sont considérés identiques si leur texte visible est le même après suppression des espaces en début et fin de ligne.
- La limite de 10 000 lignes s'entend par fichier importé, et non par lot complet multi-fichiers.
- Si plusieurs fichiers sont sélectionnés, l'administrateur préfère un traitement groupé avec un résultat consolidé plutôt qu'un flux séquentiel fichier par fichier.
- En cas de lot mixte, les fichiers valides peuvent être importés même si d'autres fichiers du même lot sont refusés, à condition que le résultat final précise clairement ce qui a été fait.
- Tout fichier contenant au moins une ligne de fact invalide ou non exploitable est entièrement rejeté, même s'il contient aussi des lignes par ailleurs valides.
- Toute ligne markdown non vide qui n'est ni le titre du document ni une puce de fact rend le fichier invalide dans son ensemble.
