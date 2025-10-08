# UI Interaction Contract: Login Screen

## Cubit Interface (Implemented)
```dart
class LoginCubit extends Cubit<LoginState> {
  // Update username field (triggers state emission with cleared error)
  void updateUsername(String value);
  
  // Update password field (triggers state emission with cleared error)
  void updatePassword(String value);
  
  // Submit credentials; emits submitting -> success|error
  // Performs local validation before calling use case
  Future<void> submit();
}
```

## State Structure
Refer to `data-model.md` for full field list.

## Events
| Event | Preconditions | Resulting Transitions | Notes |
|-------|---------------|-----------------------|-------|
| submit_start | canSubmit == true | idle\|error -> submitting | Sets status=submitting, clears error |
| submit_success | after submit_start | submitting -> success | Emits success, triggers navigation to Decks |
| submit_error_auth | after submit_start | submitting -> error(invalidCredentials) | Username/password retained |
| submit_error_network | after submit_start | submitting -> error(networkFailure) | Allows retry |
| submit_error_validation | canSubmit == false | idle\|error -> error(usernameEmpty\|passwordEmpty) | Local validation failure |
| retry (alias submit) | error & canSubmit | error -> submitting | Same as submit_start |

## Error Messaging
- invalidCredentials / userNotFound → "Username or password wrong" (generic, FR-006)
- networkFailure → Localized network connectivity message (FR-012)
- usernameEmpty → "Username is required"
- passwordEmpty → "Password is required"

## Loading Behavior
- While submitting: login button disabled & shows spinner; fields remain editable (optional decision: keep editable; no lockout)

## Sign-Up Navigation
- Secondary action button/link triggers route navigation to signup (`/signup` assumed) without mutating login state.

## Constraints
- Unlimited retries.
- No password recovery present.

## Non-Functional Notes
- Logging: submit_start, submit_success, submit_failure_auth, submit_failure_network.
- No analytics events (future addition potential).

## Out of Scope
- Rate limiting, captcha, multi-factor auth, accessibility enhancements.
