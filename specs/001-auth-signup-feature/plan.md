# Implementation Plan: Auth Signup Feature

**Branch**: `001-auth-signup-feature` | **Date**: 2025-09-09 | **Spec**: `/specs/001-auth-signup-feature/spec.md`
**Input**: Feature specification from `/specs/001-auth-signup-feature/spec.md`

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
Enable unauthenticated visitors to create an account using a unique immutable username, email, and password. After successful signup the user is authenticated and redirected to the deck list. Atomic guarantee: no username reservation or profile document persists unless all steps (auth user, profile, username doc) succeed. Rollback deletes auth user on partial failure. Local validation (regex, email format, password length) prevents unnecessary backend calls; Firestore username uniqueness enforced via first-write-wins on `usernames/{username}`.

## Technical Context
**Language/Version**: Dart (Flutter web)  
**Primary Dependencies**: Firebase Auth, Cloud Firestore, Bloc/Cubit (state), shared Result utility  
**Storage**: Firestore (collections: users, usernames)  
**Testing**: Flutter test (unit), alchemist for golden test, future integration harness for repository logic  
**Target Platform**: Web (Flutter Web MVP)  
**Project Type**: Single Flutter app (feature-sliced)  
**Performance Goals**: Signup end-to-end < 1500ms P95; local validation instant (<16ms)  
**Constraints**: No social login, no email verification; username immutable; atomic signup or full rollback  
**Scale/Scope**: MVP user count low (<<10k); design supports future growth without refactor

## Constitution Check
*Initial Gate (pre-Phase 0) & Post-Design Review*

**Simplicity**:
- Projects: 1 (single Flutter app) → PASS
- Using framework directly: Yes (Firebase SDK directly) → PASS
- Single data model: Yes (no DTO layer introduced) → PASS
- Avoiding unnecessary patterns: Repository exists already as constitutional standard for entities → JUSTIFIED (consistent architecture)

**Architecture**:
- Features as slices within app/lib/features → PASS
- Separate libraries: Not required for MVP; staying in single package → PASS
- CLI: Not applicable (mobile/web app) → N/A
- llms.txt docs: Deferred (not required) → PASS

**Testing**:
- Will create failing tests first for validators & repository logic before implementation → PLAN
- Order: Model & contract tests precede feature controller → PLAN
- Real dependencies: For Firestore, may use emulator (future). For now repository logic abstracted; unit tests cover validation states → ACCEPTABLE MVP
- No implementation before tests: To be enforced in tasks.md → PLAN

**Observability**:
- Console logging with structured codes (AUTH_SIGNUP_*) → PLAN
- Unified backend log stream: Deferred → ACCEPTABLE
- Error context includes code + message → PLAN

**Versioning**:
- Feature addition; no public version bump mechanism yet (pre-1.0) → PASS
- Breaking changes: None introduced → PASS

Initial Constitution Check: PASS
Post-Design Constitution Recheck: PASS

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

**Structure Decision**: Use existing feature-sliced Flutter `app/lib` layout (Option 1 analogous). No new top-level projects required.

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

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `/scripts/update-agent-context.sh [claude|gemini|copilot]` for your AI assistant
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*Description only; tasks.md will be created by /tasks command*

**Task Generation Strategy**:
- Parse `contracts/signup_contract.md` → derive contract test tasks (failing) for success + each error code.
- From `data-model.md` → model/state + repository interface creation tasks.
- From controller state machine → state & cubit test tasks (failing first).
- From acceptance scenarios → integration/widget test tasks (redirect, username taken, validation, rollback path simulated via injected failure stub).
- Quickstart steps → smoke test script task.

**Ordering Strategy**:
1. Contract test skeletons (failing)
2. Data model & Result types wiring
3. Repository interface + mock/fake for tests
4. Validation utilities (tests first)
5. Controller state tests then implementation
6. Widget form tests (validation + submit)
7. Integration test for atomic rollback (with injected failure)
8. Cleanup & logging tasks

Parallelizable ([P]): independent validator tests, model creation, contract test scaffolds.

**Estimated Output**: ~18-24 tasks (reduced due to single endpoint scope)

**Stop Condition**: After describing ordering & parallelization (no tasks.md yet)

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
- [ ] Complexity deviations documented (none required yet)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*