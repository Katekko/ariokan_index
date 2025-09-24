# Quickstart: Auth Signup Feature

## Goal
Validate core signup flow: new user registers, becomes authenticated, and is redirected.

## Preconditions
- Firebase project configured (auth + Firestore) (placeholder until infra scripts exist)
- App launched in development mode

## Steps
1. Open Signup Page (/signup route)
2. Enter username: `test_user_123`
3. Enter email: `test_user_123@example.com`
4. Enter password: `hunter22` (>=6 chars)
5. Submit form
6. Expect redirect to deck list page
7. Refresh page → confirm still authenticated (session persists)
8. Attempt to navigate to /signup → redirected away (FR-010)
9. Sign out (future global nav) → navigate to /signup allowed again

## Negative Case: Username Taken
1. Repeat Steps 1-5 with same credentials after sign out
2. Expect inline error: "Username already taken"

## Negative Case: Rollback Simulation (Manual)
- Disconnect network after auth step (simulate via dev tools offline) and force error before Firestore batch
- Expect error message and not authenticated state.

## Success Criteria
- All acceptance scenarios traceable.
- No dangling username docs on failed attempts.
