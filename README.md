# Ariokan Deck Portal (MVP)

Architecture Style: Feature-Sliced Design (adapted for Flutter Web + Firebase)

## Guiding Principles
- Vertical slices around business capabilities (deck publication, discovery, user identity) rather than pure technical layers.
- Each slice owns UI + state + domain adapters but respects cross-slice layering rules.
- Centralized shared abstractions (config, firebase, design system) avoid duplication.
- Immutability constraints (deck core fields) enforced at repository and Firestore rules layers.

## Layer Overview
From outer (more concrete) to inner (more abstract):
1. app (composition root, routing, global providers)
2. processes (multi-step flows spanning multiple features, e.g., deck_publish_flow)
3. features (user-facing atomic capabilities: create_deck, edit_deck_tags, list_decks, view_deck, auth_login, auth_signup; each owns its page widget)
4. entities (core domain models + small domain logic: deck, tag, version, user)
5. shared (reusable primitives: ui kit, theming, utils, firebase adapters, config)

(If a layer is not needed initially it can be omitted until first use.)

## Directory Skeleton (Proposed)
```
app/
  lib/
    app/                # Root app setup, MaterialApp, routes, dependency injection
      app.dart
      router.dart
      di/
        providers.dart
    processes/          # Orchestrated flows
      deck_publish_flow/
        deck_publish_flow.dart
  // Pages removed; each feature exposes its own page widget under features/<feature>/ui/
    features/
      create_deck/
        ui/
          create_deck_form.dart
        model/
          create_deck_state.dart
        logic/
          create_deck_controller.dart
      edit_deck_tags/
        ui/
          edit_tags_sheet.dart
        model/
          edit_tags_state.dart
      list_decks/
        ui/
          deck_list_view.dart
        model/
          deck_list_state.dart
        logic/
          deck_list_controller.dart
      view_deck/
        ui/
          deck_detail_view.dart
        model/
          deck_detail_state.dart
      auth_signup/
        ui/signup_form.dart
        model/signup_state.dart
        logic/signup_controller.dart
      auth_login/
        ui/login_form.dart
        model/login_state.dart
        logic/login_controller.dart
    entities/
      deck/
        deck.dart
        deck_repository.dart
      tag/
        tag.dart
        tag_repository.dart
      user/
        user.dart
        user_repository.dart
      version/
        version.dart
        version_provider.dart
    shared/
      firebase/
        firebase_init.dart
        firestore_paths.dart
        security_notes.md
      config/
        active_version_provider.dart
      ui/
        widgets/
          primary_button.dart
          tag_chip.dart
        theme/
          app_theme.dart
      utils/
        result.dart
        validators.dart
      constants/
        limits.dart
      services/
        auth_service.dart
        remote_config_service.dart
```

## Dependency Rules
Higher layer can depend on same or inner layers only.
- app -> (processes, features, entities, shared)
- processes -> features, entities, shared
- features -> entities, shared
- entities -> shared (avoid upward references)
- shared -> (no dependencies on other slices; only platform & packages)

Forbidden: features referencing each other directly (coordinate via entities or processes). Avoid singletons; use DI/providers.

## State Management Strategy
- Use bloc/Cubit for reactive state; each feature owns a small state notifier, use the cubit state pattern instead of copywith.
- No global monolithic state store; composition at page/process level.

## Repositories & Services
- Repositories live under entities/* and expose domain-centric interfaces (DeckRepository, TagRepository, UserRepository, VersionProvider).
- Services (firebase auth, remote config) in shared/services; repositories depend on them.

## Naming Conventions
- Snake_case for files, lowerCamelCase for members, PascalCase for types.
- Feature folder names reflect user intent (create_deck, list_decks) not technical terms.

## Testing Layout
```
app/
  test/
    features/
      create_deck/
        create_deck_controller_test.dart
    entities/
      deck/
        deck_repository_test.dart
    shared/
      utils/
        validators_test.dart
```
- Unit tests for domain logic & validators.
- Golden tests using alchymist lib for form validation & deck list filtering.

## Example Firestore Path Strategy
- users/{uid}
- usernames/{username}
- tags/{tagId}
- decks/{deckId}
No subcollections required for MVP.

## Environment & Config
- Remote Config: activeVersion { id, label, discordUrl }
- Build-time flavors (optional later): dev, prod.
- .env style (Flutter --dart-define) for non-secret flags (e.g., ENABLE_ANALYTICS=false for MVP).

## Future Extension Points
- Add analytics module under shared/services/analytics_service.dart
- Add moderation feature slice later (report_deck)
- Introduce Serverpod adapter by implementing new repositories while keeping interfaces stable.

## Workflow Summary
1. User logs in (auth_login feature)
2. Active version fetched (version_provider)
3. Tags loaded (tag_repository > Firestore)
4. Deck creation form (create_deck feature) validates & submits to repository
5. Deck list page queries decks (list_decks feature)
6. Detail view (view_deck) renders code, tags, version link
7. Edit tags sheet (edit_deck_tags) updates only strategy tags

## Debug Logging (Development)

Lightweight debug logging utility added at `lib/shared/utils/app_logger.dart`.

Highlights:
* Initialized in `main.dart` via `AppLogger.init()` and `AppLogger.runGuarded()`.
* Captures framework (`FlutterError.onError`), platform dispatcher, and zone uncaught errors.
* Colorized log levels (INFO/WARN/ERR) only in debug/profile; release minimizes noise.
* Repository example: user signup repository logs auth failures and rollback issues without exposing sensitive input.

Usage example:
```
AppLogger.info('Starting fetch', 'endpoint=/decks');
try {
  // ... work ...
} catch (e, s) {
  AppLogger.error('DeckRepository', 'Fetch failed', error: e, stack: s);
}
```

Avoid logging secrets (passwords, tokens, PII). Sanitize values first.

### AppLogger Usage Patterns
```dart
// Initialization (already invoked in main.dart)
await AppLogger.init();

// Info with context key-value pairs (serialize lightweight primitives only)
AppLogger.info('SignupController', 'submit_start', fields: {
  'username': usernameMasked(username), // never raw if sensitive
});

// Warning (non-fatal unexpected state)
AppLogger.warn('UserRepository', 'username_collision_retry');

// Error with exception + stack
try {
  await _repo.createUserWithUsername(...);
} catch (e, s) {
  AppLogger.error('UserRepository', 'create_failed', error: e, stack: s, fields: {
    'phase': 'firestore_batch',
  });
  rethrow; // still propagate if caller needs to handle
}

// Helper masking example (pseudo)
String usernameMasked(String raw) => raw.length <= 2
    ? '**'
    : raw.substring(0, 2) + ('*' * (raw.length - 2));
```

Guidelines:
- Use stable event identifiers (e.g., submit_start, create_failed) for future log aggregation.
- Prefer one log per significant user intent phase (start, success, failure).
- Do not log full email or password; mask or omit.


## License
TBD.

## Current Implemented Features (MVP Progress)

### Auth Signup (Feature 001)
Status: Initial implementation merged on branch `001-auth-signup-feature`.

Capability: Allows unauthenticated visitor to create an account with unique immutable username (regex ^[a-z0-9_]{3,20}$), email, and password (6-128 chars). Performs client-side validation and repository-mediated submission.

Key Components:
- `features/auth_signup/ui/signup_page.dart`: Page scaffold & success redirect to `/decks`.
- `features/auth_signup/ui/signup_form.dart`: Form fields + validation + error mapping.
- `features/auth_signup/logic/signup_controller.dart`: Cubit controlling state machine (idle → submitting → success|error) and guards against double submission.
- `features/auth_signup/model/signup_state.dart`: Immutable state + error codes.
- `entities/user/user.dart`: User entity (id, username, email, createdAt).
- `entities/user/user_repository.dart`: Abstract repository ensuring atomic username + user profile creation (implementation stubbed / to be completed with Firebase integration).
- `shared/utils/validators.dart`: Username/email/password validation helpers (regex + length bounds).
- `shared/utils/result.dart`: Lightweight Result type (success/failure) enabling error mapping without exceptions.

User Flow (Happy Path):
1. User enters valid values → submit.
2. Controller performs sync validation; on success invokes repository.
3. Repository (future impl) creates auth user + Firestore docs atomically.
4. State transitions to success → page redirects to `/decks`.

Failure Modes & Handling:
- Invalid fields → immediate `SignupStatus.error` with specific `SignupErrorCode`.
- Network/unknown failure → `networkFailure` surfaced.
- Username taken (repository-level) → `usernameTaken` error.

Open Items / TODOs:
- Concrete Firebase-backed `UserRepository` + `AuthService` implementation.
- Tests (unit, widget, integration) outlined in `specs/001-auth-signup-feature/tasks.md` pending migration into test suite (some placeholders currently absent).
- Redirect guard for already-authenticated users (FR-010) to be formalized in router middleware.

Specification Artifacts:
- `specs/001-auth-signup-feature/spec.md` (functional requirements & scenarios)
- `specs/001-auth-signup-feature/tasks.md` (TDD task breakdown)
- `specs/001-auth-signup-feature/quickstart.md` (manual validation steps)

Traceability Matrix (Excerpt):
- FR-001/002/007/015: Handled via validators + controller early checks.
- FR-009: `_inFlight` guard in controller prevents double-submit.
- FR-011: Logging pending integration with `AppLogger` (add in repository/controller on completion).
- FR-016: Rollback semantics require concrete repository + auth service (NOT YET IMPLEMENTED).

### Upcoming
Next planned features: auth login, deck creation slice. Each will follow the same spec → tasks → implementation → README update workflow.

## Contribution Workflow (Spec → Tasks → Branch)
Standard steps for adding a new feature slice:
1. Create spec under `specs/NNN-feature-slug/` using templates.
2. Add `plan.md` + `tasks.md` describing TDD order.
3. Branch: `NNN-feature-slug` (e.g., `002-auth-login-feature`).
4. Write failing tests first.
5. Implement minimal code to pass tests incrementally.
6. Update READMEs with new slice summary.
7. Open PR referencing spec & tasks; ensure constitution rules upheld.

See `CONTRIBUTING.md` for detailed guidelines (lint, commit messages, review gates).