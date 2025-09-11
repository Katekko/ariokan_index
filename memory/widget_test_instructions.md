# Widget Test Instructions (Authoritative)

(Originally from `.github/instructions/widget_test.instructions.md`)

Covers component-level widgets (forms/cards/list items/etc.).

## Differences vs Page Tests
- Explicit fixed viewport size for each golden (`size:`).
- Avoid full routing unless required.
- Goldens named `<feature>_<component>_<state>`.

## Structure
1. Imports: target widget & controller/state, flutter packages, third-party utils, helpers, feature mocks.
2. `const goldenSize = Size(w, h);` near top.
3. Register only direct dependencies.
4. `Widget widgetBuilder()` returns localized test app with providers.
5. Groups: `Interfaces` & `Interactions`.
6. Use `testWidgetsGolden` / `testGoldenClickable` with `size: goldenSize`.

## Example Skeleton
See historical version; keep concise.

## Interaction Cases
- Validation errors.
- Successful submit triggers intent once.
- Error path renders expected UI.
- Debounce/double-click safety.

## Anti-Patterns
- Missing explicit golden size.
- Over-mocking unrelated page-level dependencies.
- Asserting private fields instead of rendered output.

## Maintenance
- Adjust golden size only with structural layout changes.

Version: v0.1 (2025-09-11)
