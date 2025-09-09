# Ariokan Deck Portal Constitution

Authoritative guide for architecture, workflow, and quality standards of the Ariokan Deck Portal (MVP and near-term evolution).

## Core Principles

### 1. Vertical Feature Slices
Features are the primary unit of architecture (create_deck, auth_signup, list_decks). Each slice owns UI, local state, and integration boundary but must not leak internal details across slices. Cross-feature coordination happens only through entities, processes, or shared abstractions. No feature-to-feature direct imports.

### 2. Layered Dependency Integrity
Outer layers (app, processes, pages) may depend inward (features, entities, shared) but never laterally upward. Entities only depend on shared. Shared is foundational and depends only on platform & third-party packages. Violations are refactored before merge.

### 3. Minimal, Focused State
State lives closest to where it is used. Prefer small Cubit/Bloc instances per feature with explicit events and immutable state objects. Avoid global monoliths. State duplication is acceptable when it reduces coupling and complexity.

### 4. Immutability Enforcement at Boundaries
Deck core fields (id, createdAt, authorId, base strategy fields) are immutable post-creation. Enforced in repository methods AND Firestore security rules. Mutations require explicit new versions or targeted field update APIs.

### 5. Explicit Contracts & Repositories
Domain operations flow through repositories under `entities/*`. Repositories expose intent-based methods (e.g., createDeck, listRecentDecks). Services (auth, remote config) remain in shared/services and are never imported by UI directly—only via repositories or providers.

### 6. Testable by Design
Every pure domain rule (validators, repository selection logic, deck filtering) must have unit tests. Critical UX flows (deck creation, tag edit) gain at least one golden/snapshot or widget test before stabilization. Failing tests block merge.

### 7. Simplicity & YAGNI
Defer analytics, flavors, and moderation until justified by user value or adoption metrics. Prefer fewer abstractions until real duplication or volatility emerges. Remove dead code aggressively.

### 8. Evolution Without Breakage
Interfaces in entities/ should be additive-first. Breaking changes require: (a) migration note, (b) version bump, (c) justification in PR description. Shared utilities are versioned implicitly by git history; public API surface documented in README or inline doc comments.

### 9. Observability & Traceability (Lightweight)
Log significant user-intent operations (deck created, tag list loaded) at repository level with structured key-value format (pending implementation). No verbose UI logging. Errors bubble with context.

### 10. Security by Constraint
Firestore security rules mirror repository invariants. Any repository relaxation requires rules update in same PR. No client-only enforced constraints for critical integrity (e.g., author ownership, immutable fields).

## Architectural Sections

### A. Layer Responsibilities
- app: Composition root (MaterialApp, routing, DI wiring)
- processes: Long-lived or multi-step orchestrations (e.g., deck_publish_flow)
- pages: Route widgets mapping URLs to feature assemblies
- features: User-facing capability packages (small public surface)
- entities: Domain models + repository interfaces and implementations
- shared: Cross-cutting primitives (ui kit, firebase adapters, config, services, utils)

### B. Dependency Rules (Enforced)
Allowed edges: pages→(features|entities|shared), features→(entities|shared), entities→shared, processes→(features|entities|shared). Forbidden: features→features, shared→(entities|features|pages|processes|app), entities→(features|pages|processes|app). Cycles are disallowed.

### C. Firestore Data Model (MVP)
Collections: users/{uid}, usernames/{username}, tags/{tagId}, decks/{deckId}. No subcollections initially. Version evolution occurs via field version references or new deck documents (strategy TBD during implementation—must not break reader clients).

### D. Config & Remote Control
Remote Config key: activeVersion { id, label, discordUrl }. Build-time flags via --dart-define for non-secrets (e.g., ENABLE_ANALYTICS=false). Secrets never embedded client-side.

### E. Naming & Structure
Snake_case file names, PascalCase types, lowerCamel members. Feature folders named after user intent verbs/nouns. Avoid suffix redundancy (e.g., deck_repository.dart OK, not deck_data_repository_impl.dart unless multiple impls exist).

### F. State Management Norms
Each feature provides: state (data class), controller (Cubit/Bloc), UI widgets. Controllers expose intent methods; no direct field mutation. Dispose automatically via provider scopes. No global service locator; DI passes dependencies explicitly.

### G. Testing Strategy
Unit tests: validators, repository logic, filtering. Widget/golden tests: core forms & list rendering. Minimum: new repository or feature introduces at least one failing test before implementation (recommended—test-first). Coverage focus over numeric thresholds: critical paths must be exercised.

### H. Version & Change Control
Semantic versioning (MAJOR.MINOR.PATCH) for public API perception (informal until 1.0). Breaking domain contract needs migration note under `memory/` or `CHANGELOG` once introduced.

### I. Performance & Scale (MVP Scope)
Optimize for correctness & clarity. Queries must specify limits (default 50 items for deck lists). No premature caching beyond Firestore SDK built-ins. Introduce caching layer only after measured latency > target (P95 deck list load > 1200ms on baseline connection).

### J. Accessibility & UX Baseline
Primary actions use `primary_button.dart`. Tag chips accessible with semantic labels. Forms validate on submit + dirty fields.

## Workflow & Quality Gates

### Pull Request Requirements
1. PR description links to spec or task.
2. Architectural rule adherence (dependency direction) validated manually or via linter script when added.
3. Tests: added/updated for any domain logic touched.
4. No console TODO left without linked issue.
5. Public API changes documented.

### Branching & Naming
Feature branches: `NNN-short-slug` (e.g., `001-auth-signup-feature`). One feature/spec per branch. Rebase or squash merges to keep linear history.

### Definition of Done
- All acceptance criteria satisfied.
- Tests passing locally.
- No forbidden dependency imports.
- Security rules updated if repository contract changed.
- README or inline docs updated when introducing new layer patterns.

### Tooling (Future Enhancements)
Add script to statically check forbidden imports (planned). Golden test harness to be added before first visual regression requirement.

## Additional Constraints

### Security
- Enforce author ownership on deck mutation.
- Reject writes with unknown tag IDs.
- Immutable fields blocked in rules.

### Data Integrity
- Required deck fields: id, title, code, tags[], createdAt, authorId, versionRef.
- Tag normalization (lowercase, trimmed) occurs in repository.

### Error Handling
- Repositories return Result-like types (success/error) instead of throwing for expected domain faults (validation failure, not found).
- Unexpected conditions (I/O, permission) bubble as exceptions with context message prefix `[Repo]`.

## Governance

This constitution supersedes ad-hoc decisions. Amendments require:
1. Rationale documented under `memory/constitution_update_checklist.md` (create if absent).
2. PR including both the change and its justification.
3. Agreement from at least one maintainer (For now only Katekko).

Non-compliant contributions are refactored prior to merge; exceptions are temporary and must include an expiration issue.

## Versioning & Metadata

**Version**: 0.1.0 | **Ratified**: 2025-09-09 | **Last Amended**: 2025-09-09

Change Log (initial): Establishes core architectural, workflow, and quality principles for MVP.