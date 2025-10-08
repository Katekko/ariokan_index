
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
  - **Use Cases**: Encapsulate ALL business logic and orchestrate operations across multiple providers. A use case may coordinate remote API calls, local storage operations, and any other data operations required to complete a business transaction. For example, a signup use case would handle both creating the user account remotely AND saving user data locally.
- **presentation/**: Manages UI state, widgets, pages, and user interactions. Depends on domain layer only.

### II. Layered Dependency Rules
Higher layers may depend only on the same or inner layers. Features must not import each other directly; entities depend only on shared; shared depends only on platform/packages. Dependency direction is strictly enforced.

**Feature Layer Dependencies:**
- `presentation/` → `domain/` (allowed)
- `data/` → `domain/` (allowed for interfaces)
- `domain/` → NO dependencies on `presentation/` or `data/` concrete implementations
- `domain/usecases/` → `domain/providers/` (allowed - use cases orchestrate via provider interfaces)
- Features → `shared/` (allowed)
- Features ↔ Features (forbidden - use shared abstractions)

**Use Case Orchestration Rules:**
- Use cases are the ONLY place where business logic resides
- Use cases may coordinate multiple provider operations (e.g., save remotely + save locally)
- Use cases receive provider dependencies via constructor injection
- Presentation layer (cubits) should call use cases, not providers directly
- Use cases must remain framework-agnostic (no Flutter/UI dependencies)

### III. Immutability & Data Integrity
Core domain fields (e.g., deck identity, username) are immutable after creation. This is enforced at both repository and Firestore security rules layers. All data mutations must be validated and reversible.

### IV. Test-First & Coverage Discipline
All domain logic and validators require unit tests. Golden/widget tests are required for critical UI. No implementation may proceed before failing tests are written. PRs must not reduce test coverage for changed lines.

**Test Setup Patterns:**
- DO NOT use `late` variables for mock instances in tests
- Create mock instances directly and assign them immediately
- Reset mocks in `tearDown()`, never reset the DI container between tests
- Register all required dependencies in `setUpAll()` exactly once per test file
- Individual tests should not modify DI registrations

**Widget Test Mock Pattern:**
For widget tests requiring Cubit/Bloc mocks, create dedicated mock files:
- Location: `test/features/<feature>/presentation/mocks/<cubit_name>_mock.dart`
- Naming: `<CubitName>Mock` (e.g., `LoginCubitMock`, `SignupCubitMock`)
- Pattern: Follow the Controller Mock Template from `mocking_guidelines.md`
- Usage: Call `final mock = <CubitName>Mock.register();` to get the mock instance
- Benefits: Centralized mock setup, consistent stubbing, proper DI registration
- Example: See `test/features/auth_login/presentation/mocks/login_cubit_mock.dart`

**Widget Test Structure:**
Widget tests (`**/*_widget_test.dart`) should follow these patterns:
- **Golden Tests**: Use the `setUp` parameter within `testWidgetsGolden()` to configure state/mocks before rendering
- **Interaction Tests**: Configure state inline before calling `tester.pumpWidget()`
- **State Mocking**: Use `whenListen()` to mock cubit state, never use `when(() => cubit.state)`
  - Always provide both `Stream.value()` and `initialState` parameters
  - This ensures proper BlocProvider stream subscription
- Keep `buildWidget()` function simple - no state parameters, just build the widget tree
- Example: See `test/features/auth_login/presentation/widgets/login_form_widget_test.dart`

**Page Test Structure:**
Page tests (`**/*_page_test.dart`) must follow a two-group pattern:
- **Interfaces Group**: Contains ONLY golden tests that verify visual appearance and layout
  - Use `testWidgetsGolden()` for all interface tests
  - Use the `setUp` parameter within `testWidgetsGolden()` to configure state/mocks before rendering
  - Each distinct visual state requires its own golden test
- **Interactions Group**: Contains behavioral and navigation tests
  - Use standard `testWidgets()` for interaction tests
  - Test user interactions, navigation, state listeners, and side effects

**Test App Wrappers:**
Use helpers from `test/helpers/test_app.dart` to wrap widgets under test:
- `localizedTestApp(child)`: For simple widget tests requiring localization
- `localizedTestRouterApp(routes)`: For routing-based tests with GoRouter
- `mockedRouterApp(child, mockRouter)`: For tests requiring mocked navigation
- Choose the appropriate wrapper based on test needs; avoid duplicating MaterialApp configuration

### V. Observability & Logging
Structured logging is required for all significant user and system actions. The AppLogger utility must be used for all logs. No secrets or sensitive data may be logged. Logs must use stable event identifiers and be sanitized.



## Technology & Compliance Constraints

The project is implemented using Flutter Web and Firebase (Firestore). All configuration is managed via .env-style variables (using --dart-define for Flutter). No Firestore subcollections are used for MVP. All data access and mutation must comply with Firestore security rules. Only platform and package dependencies are allowed in shared code.


## Development Workflow & Quality Gates

All new features follow a spec → tasks → branch workflow. Failing tests must be written before implementation. PRs must reference the relevant spec and tasks, and reviewers must verify compliance with this constitution. Linting, commit message style, and review gates are enforced as described in CONTRIBUTING.md. Breaking changes require migration notes and security review if Firestore invariants are affected.

## Governance

This constitution supersedes all other practices. Amendments require documentation, approval, and a migration plan. All PRs and reviews must verify compliance with these principles. Versioning follows semantic rules: MAJOR for breaking/removal, MINOR for new/expanded principles, PATCH for clarifications. Compliance reviews are required for all architectural or contract changes.

**Version**: 1.1.6 | **Ratified**: 2025-09-24 | **Last Amended**: 2025-10-07

---

## Changelog

### 1.1.6 (2025-10-07)
- **PATCH**: Added state mocking requirements to widget test structure
- Mandated use of `whenListen()` for cubit state mocking (never `when(() => cubit.state)`)
- Required both `Stream.value()` and `initialState` parameters for proper BlocProvider subscription
- Ensures consistent and reliable state mocking across all widget tests

### 1.1.5 (2025-10-07)
- **PATCH**: Added widget test structure guidelines to Test-First & Coverage Discipline
- Mandated use of `setUp` parameter in `testWidgetsGolden()` for state configuration
- Required simple `buildWidget()` function without state parameters
- Distinguished patterns for golden tests vs interaction tests
- Referenced `login_form_widget_test.dart` as canonical example

### 1.1.4 (2025-10-07)
- **PATCH**: Added widget test mock pattern to Test-First & Coverage Discipline
- Mandated dedicated mock files for Cubit/Bloc in widget tests
- Documented mock file location, naming, and usage patterns
- Referenced `login_cubit_mock.dart` as canonical example

### 1.1.3 (2025-10-07)
- **PATCH**: Added page test structure guidelines to Test-First & Coverage Discipline
- Mandated two-group pattern for page tests (Interfaces with golden tests only, Interactions for behavior)
- Required use of `testWidgetsGolden()` with `setup` parameter for all interface tests
- Documented test app wrapper patterns from `test/helpers/test_app.dart`

### 1.1.2 (2025-10-07)
- **PATCH**: Added test setup patterns to Test-First & Coverage Discipline
- Prohibited use of `late` variables for mocks
- Mandated `setUpAll()` for DI registration (once per test file)
- Prohibited DI reset between tests
- Required mock reset in `tearDown()` only

### 1.1.1 (2025-10-07)
- **PATCH**: Clarified use case responsibility for business logic orchestration
- Added explicit rule that use cases handle ALL business logic including multi-provider coordination
- Documented use case orchestration patterns (e.g., remote + local operations)
- Added use case dependency injection requirements

### 1.1.0 (2025-10-07)
- **MINOR**: Expanded Feature-Sliced Architecture with detailed three-layer structure (data/domain/presentation)
- Added comprehensive feature structure documentation with file naming conventions
- Clarified layer responsibilities and dependency rules
- Added explicit layer dependency matrix

### 1.0.0 (2025-09-24)
- Initial ratification of core principles
- Established base architecture, dependency rules, and quality gates