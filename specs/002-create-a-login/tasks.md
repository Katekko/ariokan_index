# Tasks: Login Screen Feature (auth_login)

**Input**: Design documents from `/specs/002-create-a-login/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/ui_contract.md, quickstart.md

## Execution Flow (main)
(Generated per tasks.prompt instructions; follow numbering strictly. Ensure each test is added and fails before implementing dependent code.)

## Phase 3.1: Setup
- [ ] T001 Ensure feature directory structure exists: `lib/features/auth_login/{ui,logic,model}`
- [ ] T002 Add (or extend) `lib/shared/services/auth_service.dart` interface with login method if absent (do not implement logic yet). (Sequential with T001)
- [ ] T003 [P] Add localization keys placeholders for network error & generic auth error (`l10n/app_en.arb`): `login.error.auth`, `login.error.network`, `login.action.signup`, `login.action.submit`
- [ ] T004 [P] Add route entry placeholder in `lib/app/router.dart` for `/login` referencing future `LoginPage` (stub class) without implementation details.
- [ ] T005 Add empty `login_state.dart`, `login_controller.dart`, `login_page.dart`, `login_form.dart` skeleton files (no logic) under feature slice (sequential after T001).

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
Write tests so they FAIL initially. Test paths mirror production layout.
- [ ] T006 Create state unit test in `test/features/auth_login/model/login_state_test.dart` (tests: initial values, canSubmit logic, trimming behavior placeholder).
- [ ] T007 [P] Create controller behavior test in `test/features/auth_login/logic/login_controller_test.dart` (scenarios: submit success routes success state, auth failure retains fields + errorType=auth, network failure sets errorType=network, retry loop unlimited).
- [ ] T008 [P] Create page/widget test in `test/features/auth_login/ui/login_page_test.dart` (page idle render, button disabled when empty fields, navigation to decks on success, bypass when session present) following page test instructions.
- [ ] T009 [P] Create form widget test in `test/features/auth_login/ui/login_form_widget_test.dart` (spinner during submit, error message variants, sign-up navigation trigger) following widget test instructions.
- [ ] T010 Add logging test `test/features/auth_login/logic/login_logging_test.dart` ensuring AppLogger invocations (submit_start, submit_success, submit_failure_auth/network) using a captured logger or spy.

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T011 Implement `login_state.dart` with immutable state, enums `LoginStatus`, `LoginErrorType`, derived `canSubmit`.
- [ ] T012 Implement `login_controller.dart` with submit flow: trim username, set submitting, call AuthService.login, map outcomes to success/auth failure/network failure; emit states.
- [ ] T013 Implement `login_page.dart` scaffolding (route widget) instantiating controller/provider.
- [ ] T014 Implement `login_form.dart` UI: fields, button (spinner state), error message rendering, sign-up secondary action callback.
- [ ] T015 Implement added AuthService `login` method (Firebase Auth invocation or placeholder returning simulated Result until backend ready) without exposing implementation details to UI (respect repository/service layering).
- [ ] T016 Wire router `/login` route to `LoginPage` and ensure post-auth navigation to `/decks` (existing deck list route) on success.
- [ ] T017 Add session bypass logic: on page init, if already authenticated, redirect immediately to Decks (respect constitution layering—no feature-to-feature direct imports beyond allowed services/entities).

## Phase 3.4: Integration
- [ ] T018 Add localized strings to `app_en.arb` with final copy and regenerate localization (if tool configured) then update usages in form.
- [ ] T019 Add AppLogger calls inside controller (submit_start, submit_success, submit_failure_auth, submit_failure_network).
- [ ] T020 Add network error differentiation logic (detecting exception pattern or error code) in controller mapping.
- [ ] T021 Ensure session persistence: confirm AuthService currentUser check used on startup path (adjust DI if needed).

## Phase 3.5: Polish
- [ ] T022 [P] Add additional unit test for trimming edge cases (multiple spaces) in `test/features/auth_login/model/login_state_trimming_test.dart`.
- [ ] T023 [P] Add test ensuring password preserved after auth failure in `test/features/auth_login/logic/login_controller_password_preserve_test.dart` (if not already explicit).
- [ ] T024 [P] Refactor duplicated error mapping logic (if any) into small private helper in controller.
- [ ] T025 Documentation: Append feature summary to `README.md` -> Current Implemented / In Progress features section (do not mark complete until merged).
- [ ] T026 Manual validation pass using `quickstart.md`; update acceptance checklist at bottom of quickstart file (commit updates).
- [ ] T027 Remove any temporary stubs or placeholder comments left in earlier tasks.

## Dependencies
- T001 before T005; T005 before T011-T014.
- T002 before T012 & T015.
- Tests (T006-T010) before implementation tasks (T011+).
- T011 before T012; T012 before T019-T020.
- T015 before T012 completion (AuthService call path).
- T013/T014 depend on T011 & partial T012 (state shape).
- T016 depends on T013 & T012.
- T017 depends on T012 & existing auth session access.
- T018 depends on earlier placeholder keys (T003).
- T019-T021 depend on controller implementation (T012).
- Polish tasks (T022-T027) depend on all core & integration tasks.

## Parallel Execution Guidance
Initial parallel (after T005, still pre-implementation):
- Run T007, T008, T009, T010 in parallel ([P] tasks) while T006 runs (separate file but left non-[P] to serialize base state test first if desired).

Later parallel groups:
- After core implementation: T022, T023, T024 can run concurrently (different files) once main controller stable.

## File Path Summary
- Feature slice root: `lib/features/auth_login/`
- Tests root additions (mirrors production):
	- `test/features/auth_login/model/`
	- `test/features/auth_login/logic/`
	- `test/features/auth_login/ui/`
- Localization: `lib/l10n/app_en.arb`
- Router: `lib/app/router.dart`
- Shared Auth service: `lib/shared/services/auth_service.dart`
- README update: `README.md`

## Validation Checklist
- [ ] All entities (LoginState) have implementation task (T011)
- [ ] All controller behaviors have test tasks (T006-T010)
- [ ] All user stories mapped to tests (T008, T009 integration scenarios)
- [ ] Logging covered (T010, T019)
- [ ] Localization integrated (T003, T018)
- [ ] Session persistence scenario covered (T009, T017, T021)
- [ ] No password recovery tasks (intentional exclusion)

## Notes
- Ensure each test initially fails (missing implementation) before implementing related task.
- Avoid cross-feature direct imports: rely on shared services and entities only.
- Keep controller pure in transforming outcomes to state; side-effects (navigation) handled at UI layer.
