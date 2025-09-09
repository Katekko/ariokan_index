# Ariokan Deck Portal (MVP)

Architecture Style: Feature-Sliced Design (adapted for Flutter Web + Firebase)

## Guiding Principles
- Vertical slices around business capabilities (deck publication, discovery, user identity) rather than pure technical layers.
- Each slice owns UI + state + domain adapters but respects cross-slice layering rules.
- Centralized shared abstractions (config, firebase, design system) avoid duplication.
- Immutability constraints (deck core fields) enforced at repository and Firestore rules layers.

## Layer Overview
From outer (more concrete) to inner (more abstract):
1. app (composition root, routing, global providers)
2. processes (multi-step flows spanning multiple features, e.g., deck_publish_flow)
3. pages (route-level widgets binding features)
4. features (user-facing atomic capabilities: create_deck, edit_deck_tags, list_decks, view_deck, auth_login, auth_signup)
5. entities (core domain models + small domain logic: deck, tag, version, user)
6. shared (reusable primitives: ui kit, theming, utils, firebase adapters, config)

(If a layer is not needed initially it can be omitted until first use.)

## Directory Skeleton (Proposed)
```
app/
  lib/
    app/                # Root app setup, MaterialApp, routes, dependency injection
      app.dart
      router.dart
      di/
        providers.dart
    processes/          # Orchestrated flows
      deck_publish_flow/
        deck_publish_flow.dart
    pages/              # Route-level widgets mapping to URL paths
      deck_publish_page/
        deck_publish_page.dart
      deck_detail_page/
        deck_detail_page.dart
      deck_list_page/
        deck_list_page.dart
      profile_page/
        profile_page.dart
      auth_login_page/
        auth_login_page.dart
      auth_signup_page/
        auth_signup_page.dart
    features/
      create_deck/
        ui/
          create_deck_form.dart
        model/
          create_deck_state.dart
        logic/
          create_deck_controller.dart
      edit_deck_tags/
        ui/
          edit_tags_sheet.dart
        model/
          edit_tags_state.dart
      list_decks/
        ui/
          deck_list_view.dart
        model/
          deck_list_state.dart
        logic/
          deck_list_controller.dart
      view_deck/
        ui/
          deck_detail_view.dart
        model/
          deck_detail_state.dart
      auth_signup/
        ui/signup_form.dart
        model/signup_state.dart
        logic/signup_controller.dart
      auth_login/
        ui/login_form.dart
        model/login_state.dart
        logic/login_controller.dart
    entities/
      deck/
        deck.dart
        deck_repository.dart
      tag/
        tag.dart
        tag_repository.dart
      user/
        user.dart
        user_repository.dart
      version/
        version.dart
        version_provider.dart
    shared/
      firebase/
        firebase_init.dart
        firestore_paths.dart
        security_notes.md
      config/
        active_version_provider.dart
      ui/
        widgets/
          primary_button.dart
          tag_chip.dart
        theme/
          app_theme.dart
      utils/
        result.dart
        validators.dart
      constants/
        limits.dart
      services/
        auth_service.dart
        remote_config_service.dart
```

## Dependency Rules
Higher layer can depend on same or inner layers only.
- pages -> features, entities, shared
- features -> entities, shared
- processes -> features, entities, shared
- entities -> shared (avoid upward references)
- shared -> (no dependencies on other slices; only platform & packages)

Forbidden: features referencing each other directly (coordinate via entities or processes). Avoid singletons; use DI/providers.

## State Management Strategy
- Use bloc/Cubit for reactive state; each feature owns a small state notifier, use the cubit state pattern instead of copywith.
- No global monolithic state store; composition at page/process level.

## Repositories & Services
- Repositories live under entities/* and expose domain-centric interfaces (DeckRepository, TagRepository, UserRepository, VersionProvider).
- Services (firebase auth, remote config) in shared/services; repositories depend on them.

## Naming Conventions
- Snake_case for files, lowerCamelCase for members, PascalCase for types.
- Feature folder names reflect user intent (create_deck, list_decks) not technical terms.

## Testing Layout
```
app/
  test/
    features/
      create_deck/
        create_deck_controller_test.dart
    entities/
      deck/
        deck_repository_test.dart
    shared/
      utils/
        validators_test.dart
```
- Unit tests for domain logic & validators.
- Golden tests using alchymist lib for form validation & deck list filtering.

## Example Firestore Path Strategy
- users/{uid}
- usernames/{username}
- tags/{tagId}
- decks/{deckId}
No subcollections required for MVP.

## Environment & Config
- Remote Config: activeVersion { id, label, discordUrl }
- Build-time flavors (optional later): dev, prod.
- .env style (Flutter --dart-define) for non-secret flags (e.g., ENABLE_ANALYTICS=false for MVP).

## Future Extension Points
- Add analytics module under shared/services/analytics_service.dart
- Add moderation feature slice later (report_deck)
- Introduce Serverpod adapter by implementing new repositories while keeping interfaces stable.

## Workflow Summary
1. User logs in (auth_login feature)
2. Active version fetched (version_provider)
3. Tags loaded (tag_repository > Firestore)
4. Deck creation form (create_deck feature) validates & submits to repository
5. Deck list page queries decks (list_decks feature)
6. Detail view (view_deck) renders code, tags, version link
7. Edit tags sheet (edit_deck_tags) updates only strategy tags

## License
TBD.
