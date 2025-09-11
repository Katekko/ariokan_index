---
applyTo: '**/*_widget_test.dart'
---

# Widget Test Instructions

Purpose: Provide a consistent lightweight pattern for feature widget (component-level) tests and their goldens. Complements `page_test.instructions.md` but scoped to smaller UI units (forms, cards, buttons groups, list items, etc.).

## Key Differences From Page Tests
- Must explicitly set a fixed `Size` (golden viewport) for every golden/clickable golden test via `size:`.
- Layout should reflect the widget's natural constraints (avoid full screen unless inherently full-width).
- No navigation shell or route wiring unless the widget's behavior depends on it (keep DI minimal).
- Golden filenames omit `_page_` and instead use the component name.

## Required Structure
1. Import order:
   - Target widget & its controller/state types (if directly used)
   - Flutter/framework packages (`material`, `flutter_test`, `flutter_bloc` if needed)
   - Third-party test utilities (`mocktail`, etc.)
   - Shared test helpers (`golden.dart`, `test_app.dart`)
   - Feature / setup mocks (e.g. `<feature>_page_setup_mock.dart` or specific controller/repository mocks)
2. Define a constant `goldenSize` near top (e.g. `const goldenSize = Size(400, 400);`). Choose the smallest size that fully contains the widget's idle & variant states without clipping.
3. Register only the mocks the widget directly depends on (often the controller mock). Prefer `ControllerMock.register()` pattern.
4. Provide `Widget widgetBuilder()` returning `localizedTestApp(<Providers/BlocProvider>(child: TargetWidget()))`.
5. Two top-level groups:
   - `Interfaces` (render + golden snapshots + accessibility)
   - `Interactions` (user input, state transitions, controller intent calls)
6. Use `testWidgetsGolden` (or `testGoldenClickable` when tapping a finder mutates state) with `size: goldenSize`.

## Example Skeleton
```dart
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/ui/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/golden.dart';
import '../../../../helpers/test_app.dart';
import '../../mocks/auth_signup_page_setup_mock.dart';

void main() {
  const goldenSize = Size(400, 400); // Adjust only if widget needs more space
  final controller = SignupControllerMock.register();

  Widget widgetBuilder() => localizedTestApp(
        BlocProvider<SignupController>(
          create: (_) => controller,
          child: const SignupFormWidget(),
        ),
      );

  group('Interfaces', () {
    testWidgetsGolden(
      'renders initial signup form',
      fileName: 'auth_signup_form_idle',
      size: goldenSize,
      builder: widgetBuilder,
    );

    testGoldenClickable(
      'shows validation errors on empty submit',
      fileName: 'auth_signup_form_validation',
      size: goldenSize,
      builder: widgetBuilder,
      finder: find.text('Sign Up'),
    );
  });

  group('Interactions', () {
    testWidgets('successful submit triggers controller.submit', (tester) async {
      await tester.pumpWidget(widgetBuilder());
      await tester.enterText(find.byType(TextFormField).at(0), 'user');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      verify(controller.submit).called(1);
    });
  });
}
```

## Naming Conventions
- File: `<feature>_<component>_widget_test.dart` under `test/features/<feature>/ui/widgets/`.
- Golden base name: `<feature>_<component>_<state>` (states: `idle`, `validation`, `loading`, `error`, `success`).
- Groups: `Interfaces`, `Interactions`.
- Constant viewport variable: `goldenSize`.

## Golden Guidelines
- Keep aspect ratio tight; prefer square only if neutral. Adjust width/height separately when component is naturally wider or taller.
- Update goldens intentionally with `flutter test --update-goldens`.
- Add additional state goldens only if the visual output changes (avoid redundant snapshots).
- For interactive state changes use `testGoldenClickable` to capture post-click state—name file after resulting state.

## Mocks & DI
- Register only direct dependencies (controller, repository). Avoid pulling in unrelated page-level mocks.
- Ensure Cubit/Bloc initial state is deterministic (use mock guidelines). No spontaneous emits before test-driven actions.

## Interaction Tests (Suggested Cases)
- Validation: empty/invalid input triggers visible errors.
- Debounce / double-click: ensure single intent call.
- Focus traversal (tabbing between fields) if complex forms.
- Error path: stub controller to yield an error state -> assert error UI.
- Success path: assert success message / callback invocation (verify controller method or emitted state in UI).

## Anti-Patterns
- Using full-screen `MediaQuery` from a page unless required; prefer constrained size.
- Registering broad page setup mocks when only a single controller is needed.
- Goldens without specifying `size:` (size MUST be explicit).
- Asserting against internal private fields instead of rendered output.

## Maintenance
- Refactor golden size only when layout fundamentally changes; update all associated goldens together.
- Remove outdated state goldens when UI no longer differentiates those states.

## Version
v0.1 (2025-09-11)
