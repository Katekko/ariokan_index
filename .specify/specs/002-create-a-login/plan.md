# Implementation Plan: Login Screen Feature

**Branch**: `002-create-a-login` | **Date**: 2025-09-13 | **Spec**: `specs/002-create-a-login/spec.md`
**Input**: Feature specification from `/specs/002-create-a-login/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, or `GEMINI.md` for Gemini CLI).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
8. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Primary requirement: Provide a username + password login screen that authenticates users, persists session until logout/cache clear, routes to Decks screen, distinguishes network errors from credential failures, and offers a secondary sign-up navigation. Exclusions: password recovery, brute-force mitigation, accessibility enhancements, performance targets.

High-level approach (aligned with existing architecture): Implement a new feature slice `auth_login` under `features/auth_login/` with `ui/login_page.dart`, `ui/widgets/login_form.dart`, state model `model/login_state.dart`, and controller `logic/login_controller.dart` using Cubit pattern similar to signup implementation. It will depend on an existing or extended `AuthService` (under `shared/services/auth_service.dart`) and potentially `UserRepository` for session retrieval. Session persistence uses existing Firebase Auth (assumed) and local persistence semantics already established by signup flow.

## Technical Context
**Language/Version**: Dart (Flutter stable per project)  
**Primary Dependencies**: Flutter, Firebase Auth (implied by existing signup references / firebase options), Provider/Bloc (Cubit pattern), shared `AuthService` & `AppLogger`  
**Storage**: Firebase Auth (credentials/session), Firestore (user profiles)  
**Testing**: flutter_test, widget tests, potential goldens, repository/controller unit tests  
**Target Platform**: Flutter Web (primary), adaptable to other Flutter targets  
**Project Type**: Single Flutter app (feature-sliced vertical architecture)  
**Performance Goals**: None specified for login (explicitly out of scope)  
**Constraints**: Unlimited attempts, persistent session until logout, generic failure messaging, network error differentiation  
**Scale/Scope**: Single screen + controller + integration with existing auth services; minimal incremental complexity

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 1 (existing app; no new project boundaries)
- Using framework directly: Yes (direct Flutter UI + Cubit; no excess wrappers)
- Single data model: Yes (extends existing User/session context; no DTO duplication introduced)
- Avoiding extra patterns: Yes (reusing existing service/repository contracts; no new abstraction layers)

**Architecture**:
- Feature slice `auth_login` under `features/` owning UI/state; adheres to vertical slice principle
- No additional library packages introduced
- No CLI scope for this UI feature
- Documentation limited to spec + plan + quickstart; no llms.txt needed

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN: Will add failing widget test (login form behavior) + controller unit tests first
- Commit ordering: Tests introduced before functional code
- Order adaptation: Controller + state contract tests (unit) precede widget integration test; no external API endpoints to contract-test (client only)
- Real dependencies: Firebase Auth interactions abstracted; may use fake in-memory adapter for deterministic tests while avoiding fragile live network calls
- Integration: Widget test covers credential submission flow + loading state transitions
- No implementation before initial failing tests

**Observability**:
- Use `AppLogger` for submit start, success, failure (generic reason vs network) without sensitive data
- No backend log streaming required beyond existing dev logging
- Error context: include outcome + classification (network/auth)

**Versioning**:
- Follows repo implicit versioning; no public API surface change beyond adding a feature slice
- No breaking changes introduced
- No semantic bump required (pre-1.0 internal addition)

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Flutter feature-sliced app (existing structure) — integrate `auth_login` under `lib/features/auth_login/` matching README conventions.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved (none remaining; document rationale + excluded concerns)

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate UI interaction contracts** (no external API endpoints in this feature):
   - Define controller interface methods: `submit(username, password)`, `logout()` reference (existing), state fields (username, password, status, errorType, isLoading)
   - Define result/error states enumerations in `login_state.dart`.
   - No OpenAPI schema generated (client-only feature); `contracts/` will contain a `ui_contract.md` describing state machine & events.

3. **Generate contract tests** from controller contract:
   - `login_controller_test.dart`: ensures initial state, trimming behavior, loading state during async, success transition, failure (auth vs network), unlimited retry.
   - `login_widget_test.dart`: ensures button disabled when fields empty, shows spinner during submit, preserves password on failure, error message variants.

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation) (deferred until tasks execution; not critical in planning output):
   - Run `/scripts/update-agent-context.sh [claude|gemini|copilot]` for your AI assistant
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/ui_contract.md, quickstart.md (failing tests added later in tasks phase per repo workflow adaptation—this plan documents them but will not create test files yet under /plan scope)

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 15-20 focused tasks (smaller scope than template default) in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none required)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*