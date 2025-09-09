# Contributing to Ariokan Deck Portal

Thanks for your interest in improving the project! This document explains how to propose changes while staying aligned with the architecture and governance defined in the Constitution.

Repository: https://github.com/Katekko/ariokan_index

## Ground Rules
- Follow the feature-sliced architecture (see `README.md`).
- Respect dependency direction (no feature→feature imports; entities depend only on shared; shared depends only on platform/packages).
- Keep changes minimal, cohesive, and reversible.
- No speculative abstractions (YAGNI). Duplicate twice before extracting.
- Update tests for all domain logic changes.

## Before You Start
1. Check existing issues / specs under `specs/` or create a lightweight spec if introducing a new capability.
2. Ensure the Constitution (`memory/constitution.md`) does not already forbid or redefine your approach.
3. For architectural adjustments, first propose a Constitution amendment in a PR updating that file.

## Branching
Use numeric prefix + short slug: `NNN-short-slug` (e.g., `002-deck-list-page`). If tied to an issue or spec ID, reuse that number.

## Commit Message Style
Use concise imperative subject, optional body:
```
Add deck repository interface

Explain why if non-trivial. Reference issue/spec: #12.
```
Group logical changes; avoid giant catch-all commits.

## Pull Request Checklist
Before requesting review:
- [ ] Linked issue or spec (if applicable)
- [ ] Updated or added tests (fail first when practical)
- [ ] No forbidden dependency edges (manual check)
- [ ] Updated `CHANGELOG.md` under [Unreleased]
- [ ] Updated `memory/constitution.md` if contracts/architecture changed
- [ ] Added migration notes if breaking change
- [ ] Security rules (if Firestore invariants changed)

## Changelog Updates
Edit `CHANGELOG.md` under `[Unreleased]` using categories:
- Added
- Changed
- Deprecated
- Removed
- Fixed
- Security

The release process will: (future) generate compare links and tag versions.

## Testing Guidance
Recommended minimum per feature:
- Domain/pure logic: unit tests
- Validators: unit tests (`shared/utils/validators.dart`)
- Critical interaction (e.g., create deck form): widget or golden test (planned harness)

## Architecture Guardrails
- Repositories live under `entities/<domain>/*_repository.dart`
- UI widgets limited to rendering + invoking controller intent methods
- Controllers (Cubit/Bloc) expose explicit intent functions (e.g., `submitDeck()`, `loadTags()`).
- Avoid passing raw services (auth, remote config) into UI; inject repositories.

## Adding a New Feature Slice
1. Create folder under `app/lib/features/<feature_name>/`
2. Add `ui/`, `model/`, and optionally `logic/` subfolders
3. Define state class + controller first (with tests) before UI
4. Wire into a page or process (not directly into `app.dart` unless core navigation)

## Code Style & Linting
Use standard Dart/Flutter formatting (`dart format`). Follow naming rules in README (snake_case files, PascalCase types).

## Security & Data Integrity
- Do not relax repository invariants without matching rules update
- Validate tag IDs and normalize input
- Immutable deck core fields enforced at repository + rules level

## Submitting a PR
1. Push branch
2. Open PR against `main`
3. Fill PR template
4. Request review from `@Katekko`

## Reviews
- Focus: correctness, architectural adherence, clarity, tests
- Prefer suggesting improvements rather than rewriting
- If blocked by constitution ambiguity, propose amendment

## Releasing
(Currently manual) Steps once ready:
1. Finalize `[Unreleased]` section
2. Decide new version (semver). 0.x can introduce changes more freely but still document.
3. Tag release and update compare links in `CHANGELOG.md`.

## Roadmap (High-Level)
- Implement deck creation + listing
- Authentication (signup/login) flow
- Tag editing sheet
- Version awareness via remote config
- Observability light logging
- Import guard script (planned)

## Getting Help
Open a discussion or issue, or mention `@Katekko` in a PR.

Happy building!
