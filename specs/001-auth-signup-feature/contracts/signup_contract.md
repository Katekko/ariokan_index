# Domain Contract: Signup Use Case

## Use Case: SignupUseCase
**Purpose**: Atomically create Firebase auth user + Firestore user profile + username reservation.

### Interface
```dart
class SignupUseCase {
  Future<Result<User, SignupError>> call({
    required String username,
    required String email,
    required String password,
  });
}
```

### Input Validation (Pre-conditions)
- `username`: Must match regex `^[a-z0-9_]{3,20}$` (client-side validation before call)
- `email`: Valid email format (client-side validation before call)
- `password`: Length 6-128 characters (client-side validation before call)

### Success Result
```dart
Result.success(User(
  id: "string (Firebase UID)",
  username: "string (lowercase, immutable)",
  email: "string",
  createdAt: DateTime (UTC timestamp)
))
```

### Error Results
| Error Code | Domain Exception | Meaning |
|------------|------------------|---------|
| `usernameInvalid` | `AuthSignupException` | Fails regex validation (server-side double-check) |
| `usernameTaken` | `AuthSignupException` | Already reserved in Firestore |
| `emailInvalid` | `AuthSignupException` | Invalid format (rare, should be caught client-side) |
| `emailAlreadyInUse` | `AuthSignupException` | Firebase Auth reports email collision |
| `passwordWeak` | `AuthSignupException` | Password below Firebase minimum (should be caught client-side) |
| `networkFailure` | `AuthSignupException` | Transient network/service failure |
| `rollbackFailed` | `AuthSignupException` | Compensating action failed after partial success |
| `unknown` | `AuthSignupException` | Unmapped/unexpected errors |

### Orchestration Flow
1. **Validate inputs** (use case pre-checks, redundant to client validation)
2. **Create Firebase Auth user** via provider (`createUserEmailPassword`)
3. **Create Firestore documents** atomically:
   - `users/{userId}` document with profile data
   - `usernames/{username}` document for uniqueness enforcement
4. **On any failure after step 2**: Execute rollback (delete auth user via provider)
5. **Return Result**: Success with User object OR Error with appropriate code

### Idempotency & Retry Behavior
- Multiple identical requests: First succeeds, subsequent return `usernameTaken` or `emailAlreadyInUse`
- Use case is not inherently idempotent; client must handle errors appropriately
- Retry logic: Cubit allows unlimited retries (no rate limiting in MVP)

### Atomicity Guarantees
- **MUST NOT** leave orphaned Firebase auth user without Firestore profile
- **MUST NOT** leave orphaned username reservation without user profile
- Rollback mechanism: Delete auth user if Firestore operations fail
- Uses Firestore batch write for user profile + username document

### Performance Expectations
- Target end-to-end: < 1500ms P95 on stable network
- Local validation: < 16ms (instant feedback)
- Network operations: Majority of latency from Firebase round-trips

### Security & Privacy
- Password never logged or stored outside Firebase Auth
- Rate limiting: Deferred to future iteration
- Username enumeration: Intentionally allows checking availability (explicit trade-off)

### Observability
- Log events via `AppLogger`:
  - `AUTH_SIGNUP_START` with sanitized context (no password)
  - `AUTH_SIGNUP_SUCCESS` with userId
  - `AUTH_SIGNUP_ERROR` with error code (usernameTaken, networkFailure, etc.)
  - `AUTH_SIGNUP_ROLLBACK_FAILED` with critical severity (requires manual intervention)
