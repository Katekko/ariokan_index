# Quickstart: Manual Validation - Login Screen

## Preconditions
- App built with feature branch `002-create-a-login`.
- Test user exists (username + password) created via signup flow.
- User is logged out / fresh session (clear local storage if needed).

## Steps (Happy Path)
1. Launch application → Login screen visible.
2. Enter valid username + password.
3. Click Login.
4. Observe button shows loading spinner; no duplicate taps accepted.
5. After success, routed to Decks screen.
6. Refresh browser → Remains on Decks (session persisted).

## Failure: Empty Fields
1. Ensure both fields empty → Login button disabled.
2. Enter username only → Still disabled.
3. Enter password only → Still disabled.
4. Enter both → Enabled.

## Failure: Wrong Credentials
1. Enter valid username + wrong password.
2. Submit → Error message: "Username or password wrong".
3. Username and password fields retain values.
4. Button re-enabled.

## Failure: Network Error Simulation
1. Temporarily block network (dev tools offline mode).
2. Submit valid credentials.
3. Distinct network error message shown (NOT the generic auth failure string).
4. Restore network → Retry succeeds.

## Sign-Up Navigation
1. From login screen click Sign Up secondary action.
2. Verify navigation to signup screen.
3. Navigate back → Login state preserved.

## Logout Persistence
1. From Decks screen perform logout (existing global/app action).
2. Confirm redirect back to Login screen.

## Logging Verification (Dev Console)
- Expect sequence for success: submit_start → submit_success
- For auth failure: submit_start → submit_failure_auth
- For network failure: submit_start → submit_failure_network

## Acceptance Checklist
- [ ] All above scenarios behave as described
- [ ] No sensitive data in logs
- [ ] Unlimited retries functionally allowed
- [ ] Session persists across refresh
- [ ] Distinct messages for auth vs network failure
