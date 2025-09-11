---
applyTo: '**/*_test.dart'
---

# Test Instructions (Pointer)
Authoritative version: `memory/test_instructions.md`

Do not expand this file. Update the memory version instead and keep this pointer minimal.

Summary:
- Prefer mocked GoRouter for navigation (`MockGoRouterProvider` + verify `go()` once).
- Use minimal real router only when asserting destination UI.
- Use `whenListen` for Cubit/Bloc emission sequences; otherwise drive via intents.
- Reset DI between tests when isolation needed.

See full guidelines (principles, examples, DO/AVOID) in `memory/test_instructions.md`.

Last updated pointer: 2025-09-11
