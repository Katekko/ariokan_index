# Ariokan Index App

Flutter Web MVP for the Ariokan Deck Portal. Implements vertical feature slicing with emphasis on clear specs, test-first tasks, and atomic repository operations (e.g., user signup with immutable username).

## Architecture Snapshot
Layers (current in codebase):
1. app – composition root (router, providers)
2. features – vertical slices (e.g., auth_signup) containing ui/, logic/, model/
3. entities – domain models & repository abstractions (user, deck later)
4. shared – cross-cutting utilities (validators, result, logging)

Standalone `pages/` layer has been removed per Constitution v0.1.2; each feature owns its route page widget inside its ui/ folder.

## Implemented Feature: Auth Signup (001)
Purpose: Allow a visitor to create an account with unique username + email/password.

Core Components:
- `features/auth_signup/ui/signup_page.dart` – route entry & success redirect
- `features/auth_signup/ui/signup_form.dart` – form & validation
- `features/auth_signup/logic/signup_controller.dart` – Cubit state machine
- `features/auth_signup/model/signup_state.dart` – immutable state + errors
- `entities/user/user.dart` – user entity
- `entities/user/user_repository.dart` – atomic creation contract
- `shared/utils/validators.dart` – username/email/password rules
- `shared/utils/result.dart` – Result abstraction

State Flow: idle → submitting → success|error. Double-submits ignored (`_inFlight` guard).

Pending Work:
- Firebase-backed repository + auth service implementation
- Tests (unit/widget/integration) aligned with spec tasks
- Redirect guard for already-authenticated users

## Development
Prereqs: Flutter stable (3.x), web enabled.

Run (placeholder):
```
flutter pub get
flutter run -d chrome
```

Firebase initialization currently placeholder; add your Firebase web config into `firebase_options.dart` (generated via FlutterFire) and ensure `initFirebase()` is invoked in `main.dart` before `runApp` (already scaffolded).

## Validation / Testing Strategy
See `specs/001-auth-signup-feature/tasks.md` for enumerated TDD steps. Result & validator logic will receive unit tests; controller gets state transition tests; widget tests cover validation messaging and disabled submit behavior.

## Spec Artifacts
- `specs/001-auth-signup-feature/spec.md`
- `specs/001-auth-signup-feature/tasks.md`
- `specs/001-auth-signup-feature/quickstart.md`

## Contributing (Snapshot)
1. Create spec under `specs/NNN-feature-slug/` (use templates)
2. Open branch `NNN-feature-slug`
3. Write failing tests per tasks list
4. Implement minimal code to pass
5. Update root & app README with new slice summary

## License
TBD
