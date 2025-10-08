# Data Model: Login Screen Feature

## Entities

### LoginState (UI State Model)
Fields:
- username: String (trimmed for submission)
- password: String (raw; retained after failures)
- status: Enum(LoginStatus) → idle | submitting | success | error
- error: LoginError? (null when no error)
- isLoading: bool (derived: status == submitting)

Invariants:
- When status=submitting → error == null
- When status=error → error != null
- success implies error == null

### LoginError (Error Model)
Fields:
- code: Enum(LoginErrorCode) (see below)
- message: String? (optional additional context)

Purpose: Encapsulates all login failure scenarios with typed error codes

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
enum LoginStatus { idle, submitting, success, error }

enum LoginErrorCode {
  invalidCredentials,  // Generic auth failure (maps to FR-006 message)
  userNotFound,        // User doesn't exist (treated as invalidCredentials in UI)
  networkFailure,      // Network connectivity issues (FR-012)
  usernameEmpty,       // Local validation: username required
  passwordEmpty,       // Local validation: password required
  unknown              // Unmapped/unexpected errors
}
```

## State Transitions
```
idle --submit(valid)--> submitting --success--> success
idle --submit(valid)--> submitting --auth_fail--> error(invalidCredentials)
idle --submit(valid)--> submitting --network_fail--> error(networkFailure)
idle --submit(empty_field)--> error(usernameEmpty|passwordEmpty)
error --submit(valid)--> submitting (retry loop)
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
