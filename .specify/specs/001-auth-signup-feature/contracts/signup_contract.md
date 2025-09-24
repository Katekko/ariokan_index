# Contract: Signup Operation

## Operation: createUserWithUsername
Purpose: Atomically create an auth user + user profile + username reservation.

### Request Shape (Logical)
```
POST /signup
{
  "username": "string (^[a-z0-9_]{3,20}$)",
  "email": "string (valid email)",
  "password": "string (6-128 chars)"
}
```

### Response (Success)
```
201 Created
{
  "userId": "string",
  "username": "string",
  "email": "string",
  "createdAt": "ISO8601"
}
```

### Error Responses
| HTTP | code | meaning |
|------|------|---------|
| 400 | USERNAME_INVALID | Fails regex |
| 409 | USERNAME_TAKEN | Already reserved |
| 400 | EMAIL_INVALID | Invalid format |
| 400 | PASSWORD_WEAK | Length < 6 |
| 500 | NETWORK_FAILURE | Upstream / connectivity issue |
| 500 | UNKNOWN | Unhandled error |

### Idempotency
- Multiple identical valid requests should create only one user; subsequent attempts after success should error with USERNAME_TAKEN or return already-exists (future optimization). For MVP simply return USERNAME_TAKEN if retried.

### Atomicity Requirements
- MUST NOT leave auth user without profile + username reservation.
- On partial failure after auth creation, must rollback (delete auth user) and return 500 with appropriate code.

### Timing Constraints
- Expected end-to-end latency < 1500ms P95 on baseline network.

### Security Considerations
- Rate limiting deferred.
- Password handled only by Firebase SDK; never logged.

### Observability
- Log WARN on USERNAME_TAKEN with fields: { username }
- Log ERROR on rollback failure with code ROLLBACK_FAILED.
