# Page Test Instructions (Authoritative)

(Originally from `.github/instructions/page_test.instructions.md`)

Purpose: Consistent feature page widget tests (including goldens) across features.

## Required Structure
1. Import order: setup widget, flutter packages, mock registrations, helpers, feature mocks.
2. Register mocks at top-level via static `register()`.
3. Provide a `Widget widgetBuilder()` returning localized test app wrapping the page setup widget.
4. Groups: `Interfaces` (render/accessibility/goldens) & `Interactions` (user flows/state changes).
5. Use `testWidgetsGolden` for baseline golden. File name: `<feature>_page_idle`.

## Example Skeleton
(See repo for latest example in `signup_page_test.dart`).

## Naming
- File: `<feature>_page_test.dart` under `test/features/<feature>/ui/`.
- Golden: `<feature>_page_<state>`.
- Groups: singular, capitalized.

## Goldens
- Always include idle state.
- Add only visually distinct state goldens.
- Update intentionally with `flutter test --update-goldens`.

## Mocks
- Register only what page needs.
- Capture returned mock if additional per-test stubbing required.

## Interaction Coverage
- Form submit success & failure.
- Validation errors.
- Navigation (verify `go()` call or destination widget).
- Double submit prevention.

## Edge Cases
- Empty required fields.
- Rapid actions.
- Layout overflow (esp. small screens) where relevant.

## Accessibility
- Semantics labels present for key interactive elements (where applicable).

## Anti-Patterns
- Over-registering unused mocks.
- Asserting private internals.
- Pumping raw `MaterialApp` repeatedly (use helper).

## Maintenance
- Keep examples updated; prune outdated goldens.

Version: v0.1 (2025-09-11)
