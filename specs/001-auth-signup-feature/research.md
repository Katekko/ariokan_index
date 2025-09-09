# Phase 0 Research: Auth Signup Feature

## Decisions Overview
- Decision: Use Firebase Authentication (email/password) already implied by project direction for MVP.
  - Rationale: Fast integration, built-in session handling, aligns with future social provider expansion.
  - Alternatives considered: Custom auth (too heavy), Auth0 (external dependency, cost), Supabase (would fragment existing Firebase usage).
- Decision: Username uniqueness enforced via separate `usernames/{username}` document created atomically with user profile.
  - Rationale: O(1) existence check; avoids scanning users collection.
  - Alternatives: Query users collection (inefficient), Cloud Function reservation (adds latency & complexity for MVP).
- Decision: Client performs preflight regex validation before attempting signup.
  - Rationale: Immediate feedback reduces failed backend calls; complements server/security rule enforcement.
  - Alternatives: Backend-only validation (worse UX), Cloud Function interceptor (unneeded complexity).
- Decision: Treat signup as a two-step sequence with compensating rollback if profile creation fails.
  - Rationale: Ensure atomic perception; prevents orphaned auth user without profile.
  - Alternatives: Create username first (risk of dangling reservation), profile first (cannot until userId exists).
- Decision: Minimum password length 6; allow up to 128 characters.
  - Rationale: Aligns with Firebase baseline; simple rule for MVP.
  - Alternatives: Complexity rules (out-of-scope), longer minimum (harms conversion).
- Decision: Immediate redirect target = deck list page.
  - Rationale: Fast path to core value; profile editing not yet defined.
  - Alternatives: Profile page (feature not implemented), landing page (extra click).
- Decision: Logging limited to console warnings/errors with clear codes (e.g., AUTH_SIGNUP_USERNAME_TAKEN).
  - Rationale: Lightweight observability within constitution constraints.
  - Alternatives: Remote logging (not yet needed), no logging (hurts diagnostics).

## Uncertainties Resolved
- NEEDS CLARIFICATION markers: None remaining in spec.
- Email verification: Explicitly out of scope; plan ensures no logic depends on verified state.
- Rate limiting: Not mandated for MVP; rely on Firebase built-in abuse protections.

## Detailed Research Notes
### Atomic Write Strategy
Flow:
1. Create auth user (email/password)
2. In a Firestore batched write:
   - usernames/{username} → { userId, createdAt }
   - users/{userId} → { username, email, createdAt }
If batch fails, delete auth user (best-effort) and sign out to maintain invariants.

Edge: Failure after auth success but before batch commit → captured by FR-016; rollback logic required in controller/repository.

### Validation Strategy
- Username regex: ^[a-z0-9_]{3,20}$ applied client-side; trimmed input; lowercase enforced.
- Email: Basic format validation (simple regex or framework validator) before submission.
- Password: length check only.
- Disable submit button unless all local validations pass and not currently submitting.

### Idempotency / Double Submit Protection
- Controller state machine with statuses: idle → validating → submitting → success | error
- Ignore additional submit intents while state=submitting.

### Error Classification
Codes (internal):
- USERNAME_TAKEN
- USERNAME_INVALID
- EMAIL_INVALID
- PASSWORD_WEAK (length<6)
- ROLLBACK_FAILED (rare; log only)
- NETWORK_FAILURE
- UNKNOWN

### Security & Rules Alignment (Preview)
Rules must ensure:
- usernames doc create only if auth.uid matches userId in users doc in same request (batched / transaction semantics via security rules patterns) — design placeholder; implementation later.
- No updates to usernames docs.
- No username field mutation in users doc.

### Data Growth & Scaling
- usernames collection cardinality = user count; small for MVP.
- Single document lookup per signup; negligible latency.

### Future Extension Hooks
- Add optional displayName distinct from immutable username.
- Introduce email verification gating deck creation (post-MVP).
- Add rate limiting if abuse detected (Cloud Functions or Firebase App Check).

## Alternatives Rejected Summary
| Topic | Alternative | Reason Rejected |
|-------|-------------|-----------------|
| Auth Provider | Auth0 | External dependency, cost, vendor lock-in |
| Auth Provider | Custom backend | Overhead, security complexity |
| Username Uniqueness | Query users collection | Non-atomic, inefficient |
| Username Reservation Timing | Pre-reserve before auth | Risk of dangling reservation |
| Validation | Server-only | Poor UX |
| Logging | Remote analytics early | YAGNI principle |

## Open Risks
- Rollback failure if Firestore batch fails and auth deletion transiently fails (rare); mitigated by sign-out and periodic cleanup script (future if needed).
- Race condition: Two users submit same username simultaneously → Firestore first-write-wins; losing client gets username taken error.

## Decision Log Format Going Forward
Each future change to signup logic must append an entry under this section with: Date, Change, Rationale, Impact.

## Phase 0 Completion Criteria
- All unknowns resolved → Achieved
- Decisions captured with rationale → Achieved
- Edge cases mapped to requirements → Covered

Status: COMPLETE
