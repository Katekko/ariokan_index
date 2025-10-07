
<!--
Sync Impact Report
Version change: 1.0.0 → 1.1.0
Modified principles: I (Feature-Sliced Architecture), II (Layered Dependency Rules)
Added sections: Feature Structure diagram, Layer Responsibilities, Feature Layer Dependencies, Changelog
Removed sections: None
Templates requiring updates: ✅ All future features must follow data/domain/presentation structure
Follow-up TODOs: Migrate existing features (auth_login, auth_signup) to new structure
-->

# Ariokan Deck Portal (MVP) Constitution

## Core Principles


### I. Feature-Sliced Architecture
All business capabilities are implemented as vertical slices (features) that own their UI, state, and domain adapters. Slices must not cross-reference each other directly; shared abstractions are centralized.

Each feature follows a three-layer Clean Architecture pattern:

#### Feature Structure
```
features/
  <feature_name>/
    data/
      models/
        <action>_response.dart    # Response DTOs from backend/Firebase
        <action>_body.dart         # Request body DTOs
      providers/
        <feature>_provider_impl.dart  # Concrete data provider implementations
    
    domain/
      usecases/
        <action>_usecase.dart      # Business logic use cases
      providers/
        <feature>_provider.dart    # Abstract provider interfaces/contracts
      exceptions/
        <feature>_exceptions.dart  # Domain-specific exceptions
    
    presentation/
      models/
        <feature>_state.dart       # UI state models
      cubit/
        <feature>_cubit.dart       # State management (Cubit/Bloc)
        <feature>_state.dart       # Cubit states
      widgets/
        <feature>_widget.dart      # Reusable UI components
      pages/
        <feature>/
            <feature>_page.dart        # Full-screen pages
            <feature>_tag.dart         # Tag file for analytics
      setup.dart                   # Feature dependency injection setup
```

**Layer Responsibilities:**
- **data/**: Handles external data sources (API, Firebase, local storage). Contains DTOs and concrete provider implementations.
- **domain/**: Contains pure business logic, use cases, provider contracts, and domain exceptions. No framework dependencies.
- **presentation/**: Manages UI state, widgets, pages, and user interactions. Depends on domain layer only.

### II. Layered Dependency Rules
Higher layers may depend only on the same or inner layers. Features must not import each other directly; entities depend only on shared; shared depends only on platform/packages. Dependency direction is strictly enforced.

**Feature Layer Dependencies:**
- `presentation/` → `domain/` (allowed)
- `data/` → `domain/` (allowed for interfaces)
- `domain/` → NO dependencies on `presentation/` or `data/`
- Features → `shared/` (allowed)
- Features ↔ Features (forbidden - use shared abstractions)

### III. Immutability & Data Integrity
Core domain fields (e.g., deck identity, username) are immutable after creation. This is enforced at both repository and Firestore security rules layers. All data mutations must be validated and reversible.

### IV. Test-First & Coverage Discipline
All domain logic and validators require unit tests. Golden/widget tests are required for critical UI. No implementation may proceed before failing tests are written. PRs must not reduce test coverage for changed lines.

### V. Observability & Logging
Structured logging is required for all significant user and system actions. The AppLogger utility must be used for all logs. No secrets or sensitive data may be logged. Logs must use stable event identifiers and be sanitized.



## Technology & Compliance Constraints

The project is implemented using Flutter Web and Firebase (Firestore). All configuration is managed via .env-style variables (using --dart-define for Flutter). No Firestore subcollections are used for MVP. All data access and mutation must comply with Firestore security rules. Only platform and package dependencies are allowed in shared code.


## Development Workflow & Quality Gates

All new features follow a spec → tasks → branch workflow. Failing tests must be written before implementation. PRs must reference the relevant spec and tasks, and reviewers must verify compliance with this constitution. Linting, commit message style, and review gates are enforced as described in CONTRIBUTING.md. Breaking changes require migration notes and security review if Firestore invariants are affected.

## Governance

This constitution supersedes all other practices. Amendments require documentation, approval, and a migration plan. All PRs and reviews must verify compliance with these principles. Versioning follows semantic rules: MAJOR for breaking/removal, MINOR for new/expanded principles, PATCH for clarifications. Compliance reviews are required for all architectural or contract changes.

**Version**: 1.1.0 | **Ratified**: 2025-09-24 | **Last Amended**: 2025-10-07

---

## Changelog

### 1.1.0 (2025-10-07)
- **MINOR**: Expanded Feature-Sliced Architecture with detailed three-layer structure (data/domain/presentation)
- Added comprehensive feature structure documentation with file naming conventions
- Clarified layer responsibilities and dependency rules
- Added explicit layer dependency matrix

### 1.0.0 (2025-09-24)
- Initial ratification of core principles
- Established base architecture, dependency rules, and quality gates