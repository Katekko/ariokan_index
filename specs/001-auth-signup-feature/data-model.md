# Data Model: Auth Signup Feature

## Entities

### User (Domain)
Fields:
- id (string, auth UID) - immutable
- username (string, pattern ^[a-z0-9_]{3,20}$, lowercase, immutable)
- email (string, stored as provided normalized to lowercase local-part if desired; uniqueness handled by auth provider)
- createdAt (timestamp, server time)
- (future) profile fields: displayName?, avatarUrl?, bio? (not in MVP)

Invariants:
- username never changes once set.
- usernames collection provides uniqueness guarantee.
- A user document must exist for every auth user (post successful signup) and vice versa.

### UsernameReservation (Logical - represented by usernames/{username})
Fields:
- userId (string, auth UID)
- createdAt (timestamp)

Invariants:
- Document id equals lowercase username.
- Must only be created in same atomic batch as corresponding user document with matching userId.
- Never updated or deleted (unless account deletion flow added later).

## Relationships
- User 1 - 1 UsernameReservation (username doc id references user)
- User 1 - N Deck (out of scope for this feature, but future dependency)

## Validation Rules
| Field | Rule | Failure Handling |
|-------|------|------------------|
| username | regex ^[a-z0-9_]{3,20}$ | Client prevents submit; server rejects | 
| username | uniqueness | Firestore first-write-wins; losing attempt gets USERNAME_TAKEN |
| email | valid format | Client prevents submit |
| password | length >=6 and <=128 | Client prevents submit |

## State Machine (Signup Cubit)
States:
- idle
- validating (optional transient)
- submitting
- success (contains userId)
- error (contains errorCode, message)

Allowed Transitions:
- idle → submitting (after local validation passes)
- submitting → success | error
- error → submitting (retry) | idle (if user edits fields)
- success → (terminal for this feature flow)

## Error Codes (Aligned with Implementation)
Enum: `SignupErrorCode` (camelCase format)
- `usernameTaken` - Username already reserved in system
- `usernameInvalid` - Username fails regex validation  
- `emailInvalid` - Email format invalid
- `emailAlreadyInUse` - Firebase auth reports email collision
- `passwordWeak` - Password below minimum requirements
- `networkFailure` - Transient network/service failure
- `rollbackFailed` - Failure during compensating action
- `unknown` - Unmapped/unexpected errors

## Data Access Contracts (Preview)
(See contracts folder for domain operation signatures.)

## Notes
- DTOs in data layer (`signup_body.dart`, `signup_response.dart`) map between Firebase and domain models.
- Use case orchestrates signup operation and returns Result<User, SignupError>.
- Provider interface defines abstract contract; implementation handles Firebase interactions.
