---
applyTo: '**'
---

## Mocking & Test Double Guidelines

All test doubles (mocks, fakes, stubs) must follow the project guidelines in `.specify/memory/mocking_guidelines.md`:

1. Place mocks under `test/<layer>/<feature_or_entity>/mocks/` mirroring the production path.
2. Name mocks `<TypeName>Mock` (e.g. `AuthServiceMock`), one per file, named in snake_case (e.g. `auth_service_mock.dart`).
3. Use the static `register()` pattern for DI registration and per-test setup/teardown.
4. Always stub benign defaults and deterministic initial state for Cubits/Blocs.
5. Never assign mocks to global variables; keep them inside the test or register() scope.
6. See `.specify/memory/mocking_guidelines.md` for full details and templates.
7. Only register each mock once per test file, outside the test group, not per test. Use the returned instance in all tests in that file.

## Non-Negotiable

1. UI pages must only access controllers, never repositories or services directly. All business/data access must be mediated by a controller or viewmodel.
2. Controllers (state management) must be injected using BlocProvider (from flutter_bloc), not Provider or other DI mechanisms, unless otherwise justified in the spec.
3. All user-facing strings must be added to the ARB localization files (e.g., app_en.arb). The Dart localization files (e.g., app_localizations.dart) must only be generated using `flutter gen-l10n` and must never be edited by hand. No hardcoded user-visible text is allowed in widgets, pages, or controllers.

## Readability

4. For readability, always assign `AppLocalizations.of(context)!` to a variable (e.g., `l10n`) at the top of the build method in UI widgets, and use this variable for all localized strings in the widget tree.
