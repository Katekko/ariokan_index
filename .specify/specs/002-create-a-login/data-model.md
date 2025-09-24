# Data Model: Login Screen Feature

## Entities

### LoginState (UI State Model)
Fields:
- username: String (trimmed for submission)
- password: String (raw; retained after failures)
- status: Enum(LoginStatus) → idle | submitting | success | failure
- errorType: Enum(LoginErrorType?) → null | auth | network
- isLoading: bool (derived: status == submitting)

Invariants:
- When status=submitting → errorType == null
- When status=failure → errorType != null
- success implies errorType == null

### SessionContext (Existing / Referenced)
Fields (referenced, not newly defined here):
- userId
- createdAt
- persistsUntilLogout: true

### LoginAttempt (Ephemeral - not persisted)
Fields:
- rawUsernameInput
- trimmedUsername
- timestamp
- outcome: success | failure_auth | failure_network

## Enums
```dart
enum LoginStatus { idle, submitting, success, failure }
enum LoginErrorType { auth, network }
```

## State Transitions
```
idle --submit(valid)--> submitting --success--> success
idle --submit(valid)--> submitting --auth_fail--> failure(auth)
idle --submit(valid)--> submitting --network_fail--> failure(network)
failure --submit(valid)--> submitting (retry loop)
```

## Validation Rules
- Username required (non-empty after trim)
- Password required (non-empty)
- Trimming applied only to username before submit

## Derived/Computed
- canSubmit = username.trim().isNotEmpty && password.isNotEmpty && status != submitting

## Exclusions
- No password strength evaluation
- No username format re-validation (assumed enforced at signup)

## Logging Fields (Non-sensitive)
- event: submit_start | submit_success | submit_failure_auth | submit_failure_network
- username_prefix (first 2 chars masked) (optional future)
- duration_ms (optional future enhancement)

## Notes
No persistent new collections; feature relies on Firebase Auth for credential verification.
