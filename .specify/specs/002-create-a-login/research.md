# Research: Login Screen Feature

## Decisions & Rationale

### Identifier & Credential Handling
- **Decision**: Username + password only; trim username whitespace.
- **Rationale**: Matches signup constraints (unique immutable username); reduces UX ambiguity vs multiple identifier types.
- **Alternatives Considered**: Email-based login (rejected: not required yet), multi-identifier (adds validation complexity prematurely).

### Error Messaging
- **Decision**: Fixed generic string `"Username or password wrong"` for all credential failures.
- **Rationale**: Prevents disclosure which field is invalid; simple and consistent with security minimalism.
- **Alternatives**: Field-specific hints (rejected for security) or dynamic phrasing (adds i18n overhead now).

### Network Error Differentiation
- **Decision**: Distinct network error message separate from credential failure; reuse existing localization system.
- **Rationale**: Improves user recovery actions; avoids confusion.
- **Alternatives**: Generic failure for both (rejected: poor UX).

### Session Persistence
- **Decision**: Indefinite until explicit logout or cache clear.
- **Rationale**: Faster re-entry, minimal session management complexity.
- **Risks**: Potential stale sessions; mitigation deferred.
- **Alternatives**: Fixed inactivity timeout (rejected: added complexity not justified early).

### Unlimited Attempts
- **Decision**: No rate limiting or lockout initial.
- **Rationale**: MVP focus; brute force mitigation deferred until abuse risk observed.
- **Risks**: Potential enumeration/brute force risk; documented for future security hardening.

### Password Recovery Exclusion
- **Decision**: Out of scope.
- **Rationale**: Reduces scope; signup flow functional without recovery.

### Accessibility Deferral
- **Decision**: Formal accessibility enhancements postponed.
- **Rationale**: MVP prioritization; will track as future improvement.

### Visual Loading Indicator
- **Decision**: Transform login button into loading spinner state.
- **Rationale**: Minimal additional UI components; prevents duplicate submits.

### Logging
- **Decision**: Use `AppLogger` with masked/contextual events: submit_start, submit_success, submit_failure_{auth|network}.
- **Rationale**: Aligns with constitution principle 9 (Observability) without leaking secrets.

## Open Risks & Follow-Ups
- Security hardening (rate limit, captcha) placeholder for future threat model.
- Accessibility compliance backlog item.
- Session invalidation on server-side revocation not handled (future work when remote config / security review expands).

## Summary Table
| Topic | Decision | Status |
|-------|----------|--------|
| Identifier Type | Username only | Final |
| Password Recovery | Excluded | Final |
| Rate Limiting | None | Final (risk accepted) |
| Session Persistence | Indefinite | Final |
| Accessibility | Deferred | Future |
| Loading UX | Button spinner | Final |
| Error Messaging | Generic auth failure + distinct network error | Final |
| Logging | AppLogger structured events | Final |

No remaining unknowns; proceed to Phase 1 design.
