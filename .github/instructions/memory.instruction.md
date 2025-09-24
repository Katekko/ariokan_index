---
applyTo: '**'
---

## Non-Negotiable

1. UI pages must only access controllers, never repositories or services directly. All business/data access must be mediated by a controller or viewmodel.
2. Controllers (state management) must be injected using BlocProvider (from flutter_bloc), not Provider or other DI mechanisms, unless otherwise justified in the spec.
3. All user-facing strings must be added to the ARB localization files (e.g., app_en.arb). The Dart localization files (e.g., app_localizations.dart) must only be generated using `flutter gen-l10n` and must never be edited by hand. No hardcoded user-visible text is allowed in widgets, pages, or controllers.
