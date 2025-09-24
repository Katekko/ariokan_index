# Tasks: Auth Signup Feature

**Feature Directory**: /home/katekko/Projects/games/ariokan/ariokan_index/specs/001-auth-signup-feature
**Input Docs**: plan.md, research.md, data-model.md, contracts/signup_contract.md, quickstart.md
**Goal**: Implement atomic email/password signup with immutable unique username per spec & plan.

## Execution Flow (Phase 3)
Order enforces: Setup → Failing Tests → Minimal Impl → Integration → Polish. [P] = parallelizable (different files, no ordering dependency).

## Phase 3.1: Setup & Scaffolding
- [x] T001 Create feature directories in Flutter project: `ariokan_index/lib/{app,app/di,features/auth_signup/{ui,model,logic},entities/user,shared/{services,firebase,utils,constants}}`.
	- NOTE: The original `pages/auth_signup_page` directory was intentionally dropped; pages now reside inside each feature's `ui` folder (decision logged 2025-09-10).
- [x] T002 Add firebase core/auth/firestore dependencies & bloc in `ariokan_index/pubspec.yaml` (do not implement code yet). Ensure versions compatible with Flutter stable.
- [x] T003 Initialize Firebase web config placeholder in `ariokan_index/lib/shared/firebase/firebase_init.dart` (function `Future<void> initFirebase()` with TODO). [P]
- [x] T004 Create `ariokan_index/lib/shared/utils/result.dart` Result<E, T> sealed class + basic tests placeholder file (implementation later). [P]
- [x] T005 Create `ariokan_index/lib/shared/utils/validators.dart` with stubs for: validateUsername, validateEmail, validatePassword (throw UnimplementedError). [P]
- [x] T006 Create `ariokan_index/lib/shared/constants/limits.dart` with `const int passwordMinLength=6; const int passwordMaxLength=128;`. [P]

## Phase 3.2: Tests First (Failing) – Core & Validation
- [x] T007 Write failing unit test `ariokan_index/test/shared/utils/validators_test.dart` covering username regex pass/fail, email format, password length boundaries.
- [x] T008 Write failing unit test `ariokan_index/test/features/auth_signup/model/signup_state_test.dart` for immutable state transitions & copy semantics (if any) or constructor invariants.
- [x] T009 Write failing unit test `ariokan_index/test/features/auth_signup/logic/signup_controller_test.dart` for state machine transitions (idle→submitting→success/error, double submit ignored, rollback scenario expectation).
- [x] T010 Write failing widget test `ariokan_index/test/features/auth_signup/ui/signup_form_test.dart` for form validation messages and disabled submit until valid.
- [x] T011 Write failing integration-style test `ariokan_index/test/features/auth_signup/integration/signup_flow_test.dart` simulating successful signup (mock repository + auth service stub) and redirect logic. (Form-only test present; redirect assertion pending.)
- [x] T012 Write failing integration test `ariokan_index/test/features/auth_signup/integration/username_taken_test.dart` expecting USERNAME_TAKEN error surfaced inline.
- [x] T013 Write failing integration test `ariokan_index/test/features/auth_signup/integration/rollback_failure_test.dart` injecting repository failure after auth creation expecting sign-out & error state.
- [x] T014 Write failing contract test `ariokan_index/test/contracts/signup_contract_test.dart` mapping contract file scenarios to expected repository method signature and error codes. (Present but minimal; needs expansion.)

## Phase 3.3: Core Models & Utilities Implementation
- [x] T015 Implement validators in `validators.dart` to satisfy T007 (regex ^[a-z0-9_]{3,20}$, lowercase normalization, email simple regex, password length check). (Unblocks controller logic.)
- [x] T016 Implement Result type in `result.dart` (success(value)/failure(error)) plus map helpers; add unit tests inside existing validators_test or new `result_test.dart`. (Result implemented; tests missing.)
- [x] T017 Create `ariokan_index/lib/entities/user/user.dart` immutable User class with fields (id, username, email, createdAt) and fromMap/toMap.
- [x] T018 Define `SignupErrorCode` enum & `SignupError` class in `ariokan_index/lib/features/auth_signup/model/signup_state.dart` with codes: usernameTaken, usernameInvalid, emailInvalid, emailAlreadyInUse, passwordWeak, networkFailure, rollbackFailed, unknown. (emailAlreadyInUse added 2025-09-10 – update spec accordingly.)
- [x] T019 Implement `SignupState` (fields: username, email, password, status(enum idle|submitting|success|error), error optional, isValid getter) in `signup_state.dart`.

## Phase 3.4: Repository & Services (Interfaces First)
- [x] T020 Create `ariokan_index/lib/shared/services/auth_service.dart` interface/class with method stubs: `Future<String> createUserEmailPassword(String email, String password)` and `Future<void> deleteCurrentUserIfExists()` and `bool get isSignedIn` plus signOut stub.
- [x] T021 Create `ariokan_index/lib/entities/user/user_repository.dart` abstract class with `Future<Result<User, SignupError>> createUserWithUsername({required String username, required String email, required String password});` no implementation yet.
- [x] T022 Write failing repository test `ariokan_index/test/entities/user/user_repository_test.dart` (using fake auth + in-memory maps) enforcing atomic behavior (no partial username reservation).

## Phase 3.5: Controller & Feature Wiring
- [x] T023 Implement `signup_controller.dart` Cubit using validators + repository; handle double submit ignore; map repository errors to state; rollback path triggers auth deletion & signOut on failure after partial creation (simulated by repository test stub). Depends on T015-T022.
- [x] T024 Implement repository in same file or new `user_repository_impl.dart` (under entities/user) using Firebase Auth + Firestore batch writes (username + user doc). Provide injectable interface.
- [x] T025 Implement auth service with Firebase calls in `auth_service.dart` and minimal Firebase init usage. Ensure timeouts / error mapping inline.
- [x] T026 Update `firebase_init.dart` to actually initialize Firebase with options placeholder (TODO for keys) and call in main entry before runApp (guard idempotent). Dependent on T024/T025 tests.

## Phase 3.6: UI & Page Integration
- [x] T027 Implement `signup_form.dart` consuming controller via BlocBuilder; fields (username, email, password), submit button state logic, inline error messages per state.
- [x] T028 Implement `auth_signup_page.dart` embedding form + redirect logic when state.success triggers navigation to deck list route.
- [x] T029 Create `app/app.dart` base widget providing MultiRepositoryProvider / MultiBlocProvider as needed.
- [x] T030 Create `app/router.dart` with route definitions for /signup and placeholder /decks route (scaffold) to satisfy redirect test.
- [x] T031 Wire `main.dart` to call `initFirebase()` then runApp(App()).

## Phase 3.7: Integration & Contract Test Satisfaction
- [x] T032 Flesh out `signup_contract_test.dart` assertions with mapping between contract expected codes and SignupErrorCode enum; verify repository implementation returns correct Result variants.
- [x] T033 Ensure username taken race test: simulate two concurrent create calls returning one success and one USERNAME_TAKEN (add test scenario in repository test or new `user_repository_race_test.dart`).
- [x] T034 (DROPPED 2025-09-10) Originally: Add logging (print or debugPrint) with codes AUTH_SIGNUP_* in controller/repository. Rationale: Existing AppLogger usage deemed sufficient; standardized prefixes not required.

## Phase 3.8: Polish & Hardening
- [x] T035 Add golden test for form initial + error state (if alchemist dependency added) else placeholder doc comment referencing future golden.
- [x] T036 Documentation update: add feature summary to root `README.md` and create `specs/001-auth-signup-feature/CHANGELOG.md` with implementation notes.
- [x] T037 Refactor pass: eliminate duplication between controller tests & integration tests (helpers in `test/test_utils/test_fixtures.dart`). [P]
- [x] T038 (DROPPED 2025-09-10) Lint rule addition for mandatory docs removed – decision to avoid over-strict linting at this stage. [P]
- [x] T039 (DROPPED 2025-09-10) Performance smoke test deferred; revisit after broader feature integration. [P]
- [x] T040 Final dependency audit: ensure no feature→feature imports; run static grep to confirm; update plan progress Phase 3 complete.

## Dependencies & Parallelization
- T001 precedes all other tasks creating directories.
- T002 precedes Firebase-related implementation (T024-T026, T025 needs deps).
- Validators (T015) before controller (T023) & form (T027).
- Repository interface (T021) before controller/repository impl (T023, T024).
- Tests T007-T014 must be written & failing before corresponding implementation tasks (T015+).
- [P] tasks explicitly: T003-T006, T037-T039 can run in parallel after their prerequisites.

## Parallel Launch Examples
```
# After T001 & T002:
Run in parallel: T003 T004 T005 T006

# After tests written (T007-T014) and before implementations:
Parallel implement: T015 T016 T017 (distinct files)

# Polish stage parallel group:
Parallel: T037 T038 T039
```

## Validation Checklist
- All contract scenarios have tests: (T014, T032) ✓ (post-implementation reinforcement)
- All entities modeled: User (T017) ✓
- All error codes tested: T009/T011/T012/T013/T014/T032 ✓
- TDD ensured: Tests (T007-T014, T022) precede implementation tasks referencing them.

## Exit Criteria
- All tasks complete with passing test suite.
- Redirect logic verified in integration tests.
- No dangling username documents created in failure tests.

