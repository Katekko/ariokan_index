# UI Interaction Contract: Login Screen

## Controller Interface (Planned)
```
class LoginController extends Cubit<LoginState> {
  // submit credentials; emits submitting -> success|failure
  Future<void> submit({required String username, required String password});
  // (Reference) logout handled elsewhere; may be exposed for completeness
}
```

## State Structure
Refer to `data-model.md` for full field list.

## Events
| Event | Preconditions | Resulting Transitions | Notes |
|-------|---------------|-----------------------|-------|
| submit_start | canSubmit == true | idle|failure -> submitting | Sets status=submitting, clears errorType |
| submit_success | after submit_start | submitting -> success | Emits success, triggers navigation to Decks |
| submit_failure_auth | after submit_start | submitting -> failure(auth) | Username/password retained |
| submit_failure_network | after submit_start | submitting -> failure(network) | Allows retry |
| retry (alias submit) | failure & canSubmit | failure -> submitting | Same as submit_start |

## Error Messaging
- auth failure → "Username or password wrong"
- network failure → Localized network connectivity message (key to define: `login.error.network`)

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
