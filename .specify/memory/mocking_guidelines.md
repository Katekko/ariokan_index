# Mocking & Test Double Guidelines

Version: 0.1 | Date: 2025-09-10

Purpose: Provide a consistent pattern so widget and feature tests can rely on deterministic initial states and DI wiring.

## General Rules
1. Location: Place mocks under `test/<layer>/<feature_or_entity>/mocks/` mirroring the production path (e.g. `test/features/auth_signup/mocks/`).
2. Naming: `<TypeName>Mock` (e.g. `SignupControllerMock`, `UserRepositoryMock`). One mock per file named `snake_case` (e.g. `signup_controller_mock.dart`). For composite page setup mocks that also handle initial Cubit state, suffix with `_page_setup_mock.dart`.
3. Class Form:
   - Cubit/Bloc controllers: `class XControllerMock extends MockCubit<XState> implements XController { ... }` so we can stub stream + methods.
   - Repositories / plain abstract classes: `class XRepositoryMock extends Mock implements XRepository { ... }`.
4. Factory Registration (`static <Type> register()`):
  - Instantiate single private instance (`XMock._()`).
  - `setUpAll(() => di.registerFactory<XType>(() => mock));`
  - Per-test `setUp()` stubs (and `whenListen` for Cubits) for deterministic initial state.
  - `tearDown(() => reset(mock));` to clear stubs/interactions.
  - Return the mock so callers can keep a strongly typed reference when extra stubbing/verification is needed without resolving through DI.
5. Initial State (Cubits): Always stub with `whenListen` using `<State>.initial()` to avoid null/uninitialized build states.
6. Stubbing Methods: Only stub what the test needs. Provide benign defaults (void futures → `() async {}`, repository calls → `Success(entityFake())`). Override inside individual tests for alternative paths.
7. Determinism: Emit no extra states by default. Tests explicitly drive additional emits.
8. Avoid Global State: Do not assign mocks to global variables; keep them inside `register()` scope.
9. Fakers: Use centralized faker helpers (e.g. `entities_faker.dart`).
10. Golden / Widget Tests: Page-level setup mocks ensure all DI dependencies resolve without real network/Firebase.

## Controller (Cubit) Mock Template
```dart
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/<feature>/logic/<controller>.dart';
import 'package:ariokan_index/features/<feature>/model/<state>.dart';

class <ControllerPascal>Mock extends MockCubit<<StatePascal>> implements <ControllerPascal> {
  <ControllerPascal>Mock._();

  static <ControllerPascal> register() {
    final mock = <ControllerPascal>Mock._();

    setUpAll(() => di.registerFactory<<ControllerPascal>>(() => mock));

    setUp(() {
      // Stub intent methods
      when(mock.submit).thenAnswer((_) async {});
      // Deterministic initial state
      whenListen<<StatePascal>>(
        mock,
        Stream.empty(),
        initialState: <StatePascal>.initial(),
      );
    });

    tearDown(() => reset(mock));

    return mock;
  }
}
```

## Repository Mock Template
```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/<entity>/<repo_file>.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import '../../mocks/entities_faker.dart';

class <RepoPascal>Mock extends Mock implements <RepoPascal> {
  <RepoPascal>Mock._();

  static <RepoPascal> register() {
    final mock = <RepoPascal>Mock._();
    setUpAll(() => di.registerFactory<<RepoPascal>>(() => mock));
    setUp(() {
      when(() => mock.createSomething(
        arg: any(named: 'arg'),
      )).thenAnswer((_) async => Success(<entityFake>()));
    });
    tearDown(() => reset(mock));
    return mock;
  }
}
```

## Usage in Tests
1. Capture returned instance if you need direct handle:
  ```dart
  final signupControllerMock = SignupControllerMock.register();
  final userRepoMock = UserRepositoryMock.register();
  ```
2. Write tests; DI also supplies mocks automatically where the type is requested.
3. Re-stub inside a specific test for alternate behavior (e.g. `when(signupControllerMock.submit).thenThrow(SomeError());`).

## Rationale
- Predictable baseline state across tests.
- Reduces duplicate DI wiring.
- Prevents unintended real side-effects (network/Firebase).
- Supports Testing Strategy (Constitution Section G).

## Do NOT
- Emit states beyond initial in global setup.
- Register duplicate factories for same type without cleanup.
- Over-stub unrelated methods (can hide missing coverage).

## Future Enhancements
- Helper `registerFeatureMocks([...])` for common bundles.
- Lint script to detect feature-to-feature imports in mocks.

---
Generated from project standards; keep version updated on substantive changes.
