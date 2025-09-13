# Test Instructions (Authoritative)

This is the canonical test guideline document. Any pointer `.instructions.md` files under `.github/instructions/` must reference this file and remain minimal.

(Original content moved from `.github/instructions/test_instructions.md`.)

## Principles
- Deterministic: no reliance on wall-clock delays or real network/services.
- Fast feedback: prefer unit / lightweight widget tests over full integration unless required.
- Focused assertions: verify intent (state change, navigation invoked) over framework internals.
- Mirror production layout: place tests in matching directory structure under `test/`.
- Every test should have di.reset inside the tearDownAll

## Navigation / Route Testing
Widgets often invoke `context.go('/path')` via `go_router`. Two approaches:

### 1. Mocked GoRouter (Preferred)
Fast, isolates navigation intent, no real route tree.

Requirements: `test/helpers/mock_go_router.dart`, `mocktail`, and (when state-driven) `bloc_test`'s `whenListen`.

```dart
final mockRouter = MockGoRouter();
when(() => mockRouter.go('/decks')).thenAnswer((_) {});

whenListen(
  signupControllerMock,
  Stream.fromIterable([
    SignupState.initial().copyWith(status: SignupStatus.submitting),
    SignupState.initial().copyWith(status: SignupStatus.success),
  ]),
  initialState: SignupState.initial(),
);

await tester.pumpWidget(
  mockedRouterApp(
    localizedTestApp(const AuthSignupPageSetup()),
    mockRouter: mockRouter,
  ),
);
await tester.pump(); // submitting
await tester.pump(); // success triggers listener
verify(() => mockRouter.go('/decks')).called(1);
```
Guidelines:
- Only verify one navigation call (`called(1)`).
- Don’t assert internal router state.
- Inline route strings unless reused widely.

### 2. Real Minimal Router (Only When Destination UI Assertions Needed)
Build a minimal `GoRouter` only if you must assert destination UI:
```dart
final router = GoRouter(routes: [
  GoRoute(path: '/signup', builder: (_, __) => const AuthSignupPageSetup()),
  GoRoute(path: '/decks', builder: (_, __) => const DecksPage()),
]);
await tester.pumpWidget(MaterialApp.router(routerConfig: router));
```
Then drive state and `expect(find.text('Decks'), findsOneWidget);`

## Cubit / Bloc State Streams
Use `whenListen` with mocks for emitted sequences; otherwise trigger via public intents.

## Dependency Injection (GetIt)
- Use `di.reset(dispose: false)` in `setUp` for isolation.
- Register mocks before widget pump.
- Factories -> assert new instance per request: `expect(identical(di<T>(), di<T>()), isFalse);`

## Golden Tests
- Use `test/helpers/golden.dart` harness.
- Semantic golden names.

## Error Mapping / Switch Coverage
Cover each enum branch (parameterized or individual asserts) to avoid missed lines.

## Logging (AppLogger)
- Invoke methods; assert no exceptions.
- Capture output only if necessary (avoid slowing suite).

## Mocks
See authoritative `memory/mocking_guidelines.md` for patterns (controllers, repositories, DI setup). Do not duplicate those details here.

## DO / AVOID
Do: cover success & failure, exceptional branches, keep tests small.
Avoid: sleeps, unnecessary mocks, asserting private implementation details.

## Adding New Patterns
Add a new section here before widespread adoption; keep pointer stubs unchanged.

---
Last updated: 2025-09-11
