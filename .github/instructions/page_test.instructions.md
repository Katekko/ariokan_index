---
applyTo: '**/*_page_test.dart'
---

# Page Test Instructions

Purpose: Ensure consistency for feature page widget tests (including goldens) across all features.

## Required Structure
1. Import order:
   - Feature page setup widget (e.g. `features/auth_signup/ui/signup_page_setup.dart`)
   - Flutter/material & flutter_test packages
   - Mock registrations (repositories, controllers)
   - Test helpers (`golden.dart`, `test_app.dart`)
   - Feature-specific mocks (e.g. `auth_signup_page_setup_mock.dart`)
2. Mocks registration occurs at top-level (before groups) using the static `register()` pattern.
3. Provide a `Widget builder()` (or `widgetBuilder()`) returning a localized test app wrapper around the page setup widget.
4. Group tests into at least two groups:
   - `Interfaces` (renders, accessibility, golden snapshots)
   - `Interactions` (user flows, state changes)
5. Use `testWidgetsGolden` for golden baseline snapshot of the initial page state. File name format: `<feature>_page_idle`.

## Example Skeleton
```dart
import 'package:ariokan_index/features/auth_signup/ui/signup_page_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../entities/user/mocks/user_repository_mock.dart';
import '../../../helpers/golden.dart';
import '../../../helpers/test_app.dart';
import '../mocks/auth_signup_page_setup_mock.dart';

void main() {
  // Mocks
  SignupControllerMock.register();
  UserRepositoryMock.register();

  // Widget builder
  Widget widgetBuilder() => localizedTestApp(AuthSignupPageSetup());

  group('Interfaces', () {
    testWidgetsGolden(
      'renders initial signup page',
      fileName: 'auth_signup_page_idle',
      builder: widgetBuilder,
    );
  });

  group('Interactions', () {
    // Add interaction tests (e.g., form submit success/failure)
  });
}
```

## Naming Conventions
- Test file: `<feature>_page_test.dart` placed under `test/features/<feature>/ui/`.
- Golden file base name: `<feature>_page_<state>` (state examples: `idle`, `loading`, `error`, `success`).
- Group names are singular, capitalized: `Interfaces`, `Interactions`.

## Golden Tests
- Always include at least the idle state golden for new pages.
- Additional states (loading/error) added when the UI differentiates visually.
- Run with `flutter test --update-goldens` when intentionally updating snapshots.

## Mocks
- Only register mocks necessary for the page to build. Avoid over-registering unused mocks.
- Page-level setup mocks ensure Cubit initial state is deterministic (see `mock.instructions.md` / `memory/mocking_guidelines.md`).
- If the mock `register()` returns the instance (preferred pattern), capture it when you need additional per-test stubbing or verification;.

## Interaction Tests (Guidance)
Add tests for:
- Submitting valid form triggers controller `submit()` once.
- Validation errors show when submitting empty/invalid fields.
- Success path navigates or shows success UI (assert via `expect(find.text('...'), findsOneWidget)` or route mock).
- Error path renders error message or snack bar.

## Edge Cases
- Empty required fields
- Rapid double submit (ensure only one call)
- Focus traversal on form fields (accessibility)
- Keyboard overflow (if relevant to layout)

## Accessibility & Semantics (Optional but Recommended)
- Verify key elements have semantic labels.
- Use `tester.ensureVisible` for off-screen widgets before interactions.

## Anti-Patterns
- Avoid pumping `MaterialApp` directly in each test; use shared `localizedTestApp` helper.
- Do not manually construct DI beyond mock registration—rely on existing DI factories.
- Avoid asserting private implementation details (e.g., internal controller fields). Focus on rendered UI & interactions.

## Adding New Pages
1. Create `<feature>_page_setup.dart` with DI/provider wiring.
2. Create `<feature>_page_test.dart` using this template.
3. Register only required mocks.
4. Add at least one golden test.
5. Expand interaction coverage as behavior is implemented.

## Maintenance
- Update golden snapshots only when UI intentionally changes.
- Keep mock usage minimal; replace with real components in integration tests if needed later.

# Version
v0.1 (2025-09-10)
