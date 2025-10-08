# Tasks: Login Screen Feature

**Input**: Design documents from `/specs/002-create-a-login/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
2. Load optional design documents: data-model.md, contracts/, research.md
3. Generate tasks by category: Setup, Tests, Core, Integration, Polish
4. Apply task rules: [P] for parallel, sequential for same file, TDD order
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness
9. Return: SUCCESS (tasks ready for execution)
```

## Phase 3.1: Setup
- [X] T001 Ensure `lib/features/auth_login/` and test directories exist per plan.md
 - [X] T002 [P] Ensure all dependencies (Flutter, Firebase Auth, Provider/Bloc) are in `pubspec.yaml`
 - [X] T003 [P] Configure linting and formatting tools (if not already set)

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
 - [X] T004 [P] Create failing contract test for login controller in `test/features/auth_login/login_controller_test.dart` (covers: initial state, submit, loading, success, auth failure, network failure)
 - [X] T005 [P] Create failing widget test for login form in `test/features/auth_login/login_widget_test.dart` (covers: button enable/disable, spinner, error messages, navigation)
 - [X] T006 [P] Create failing integration test for login flow in `test/features/auth_login/login_integration_test.dart` (covers: session persistence, navigation, retries, logging)

## Phase 3.3: Core Implementation (ONLY after tests are failing)
 - [X] T007 [P] Implement `LoginState` model in `lib/features/auth_login/model/login_state.dart` (fields, enums, transitions)
 - [X] T008 [P] Implement `LoginController` in `lib/features/auth_login/logic/login_controller.dart` (submit, state transitions, logging)
 - [X] T009 [P] Implement login form UI in `lib/features/auth_login/ui/login_form.dart` (fields, button, spinner, error display)
 - [X] T010 Implement login page in `lib/features/auth_login/ui/login_page.dart` (wires up form, navigation, sign-up link)
 - [X] T011 Integrate with `AuthService` abstraction in `lib/shared/services/auth_service.dart` and provide implementation via `FirebaseAuthService` in `lib/shared/services/firebase_auth_service.dart` (call, error mapping)
 - [X] T012 Ensure Firebase initialization in `lib/shared/firebase/firebase_init.dart` and correct usage in main app

## Phase 3.4: Integration
 - [X] T013 Add logging for submit_start, submit_success, submit_failure_auth, submit_failure_network in `lib/shared/utils/app_logger.dart`
 - [X] T014 Ensure session persistence and logout behavior via `AuthService` abstraction and `FirebaseAuthService` implementation
 - [X] T015 Add error message localization keys in `lib/l10n/app_en.arb` and `lib/l10n/app_localizations.dart`

## Phase 3.5: Polish
- [ ] T016 [P] Add unit tests for validation and state transitions in `test/features/auth_login/login_state_test.dart`
- [ ] T017 [P] Update feature documentation in `/specs/002-create-a-login/quickstart.md` and `/specs/002-create-a-login/research.md` as needed
- [ ] T018 [P] Manual validation using quickstart scenarios

## Dependencies
- Setup (T001-T003) before all
- Tests (T004-T006) before implementation (T007-T012)
- Model (T007) before controller (T008)
- Controller (T008) before UI (T009, T010)
- AuthService integration (T011) and Firebase initialization (T012) before session/logging (T013-T014)
- Localization (T015) after UI
- Polish (T016-T018) after all core/integration

## Parallel Example
```
# Launch T004-T006 together:
Task: "Create failing contract test for login controller in test/features/auth_login/login_controller_test.dart"
Task: "Create failing widget test for login form in test/features/auth_login/login_widget_test.dart"
Task: "Create failing integration test for login flow in test/features/auth_login/login_integration_test.dart"

# Launch T007-T009 together after tests fail:
Task: "Implement LoginState model in lib/features/auth_login/model/login_state.dart"
Task: "Implement LoginController in lib/features/auth_login/logic/login_controller.dart"
Task: "Implement login form UI in lib/features/auth_login/ui/login_form.dart"
```

## Validation Checklist
- [x] All contracts have corresponding tests
- [x] All entities have model tasks
- [x] All tests come before implementation
- [x] Parallel tasks truly independent
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
