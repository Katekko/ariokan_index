
<!--
Sync Impact Report
Version change: (template) → 1.0.0
Modified principles: All placeholders replaced with concrete project rules
Added sections: All (first formalization)
Removed sections: None
Templates requiring updates: ✅ plan-template.md, ✅ spec-template.md, ✅ tasks-template.md (all reviewed, no changes needed)
Follow-up TODOs: None
-->

# Ariokan Deck Portal (MVP) Constitution

## Core Principles


### I. Feature-Sliced Architecture
All business capabilities are implemented as vertical slices (features) that own their UI, state, and domain adapters. Slices must not cross-reference each other directly; shared abstractions are centralized.

### II. Layered Dependency Rules
Higher layers may depend only on the same or inner layers. Features must not import each other directly; entities depend only on shared; shared depends only on platform/packages. Dependency direction is strictly enforced.

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

**Version**: 1.0.0 | **Ratified**: 2025-09-24 | **Last Amended**: 2025-09-24
<!-- Version: 1.0.0 | Ratified: 2025-09-24 | Last Amended: 2025-09-24 -->