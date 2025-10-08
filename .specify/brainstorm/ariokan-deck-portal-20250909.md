# Ariokan Deck Portal Brainstorm

Metadata:
- Working Title: Ariokan Deck Portal
- Date: 2025-09-09
- Coverage: 84% -> 90% (Decisions locked + rules draft)
- Title History: (initial)

## Open Questions (Rolling)
1. FUTURE: Add moderation/report flow eventually? (Deferred)
2. FUTURE: Basic analytics (views/copies) needed before Serverpod migration? (Deferred)
3. FUTURE: Migration strategy to Serverpod—retain Firestore as cache or full cutover? (Plan later)

## Decision Log (New)
- Tag IDs: lowercase slugs (approved).
- Strategy tag max: 3 (approved) and min 1.
- Tag seeding: script-only for MVP (no admin UI).
- Version update cadence: admin updates Remote Config in console immediately after game patch.
- Username collision: simple error returned (no suggestions) .
- Validation method: Firestore rules will get tag docs to confirm types (no duplication stored beyond IDs).

## Core Features (MVP Snapshot)
(No change — decisions confirmed.)

## Validation Logic (Finalized MVP)
- username: ^[a-z0-9_]{3,20}$, uniqueness via usernames/{slug} doc creation.
- deck create requires: name (immutable), code (immutable), godTagId (type=god), strategyTagIds (1..3 all type=strategy), versionId (auto from Remote Config activeVersion.id), userId = auth.uid.
- deck update allows only strategyTagIds replacement (must still satisfy 1..3 rule).
- Hard delete allowed to owner; no soft delete.

## Firestore Security Rules (Initial Draft)
Pseudo (not full syntax):
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function isUser() { return request.auth != null; }
    function isOwner(resourceData) { return resourceData.userId == request.auth.uid; }

    match /usernames/{uname} {
      allow create: if isUser() && request.resource.id == request.resource.data.userId && !exists(/databases/$(db)/documents/usernames/$(request.resource.id));
      allow read: if true; // public to check availability
      allow write: if false; // no updates/deletes in MVP
    }

    match /users/{uid} {
      allow create: if isUser() && request.auth.uid == uid;
      allow read: if true;
      allow update: if false; // immutable for MVP
      allow delete: if false;
    }

    match /tags/{tagId} {
      allow read: if true;
      allow write: if false; // seeded by admin script outside client
    }

    match /decks/{deckId} {
      allow create: if isUser() &&
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.name is string &&
        request.resource.data.code is string &&
        size(request.resource.data.strategyTagIds) >= 1 && size(request.resource.data.strategyTagIds) <= 3 &&
        request.resource.data.godTagId is string &&
        // verify tag types:
        get(/databases/$(db)/documents/tags/$(request.resource.data.godTagId)).data.type == 'god' &&
        request.resource.data.strategyTagIds.all(tagId, get(/databases/$(db)/documents/tags/$(tagId)).data.type == 'strategy');

      allow update: if isUser() && isOwner(resource.data) &&
        request.resource.data.diff(resource.data).changedKeys().hasOnly(['strategyTagIds','updatedAt']) &&
        size(request.resource.data.strategyTagIds) >=1 && size(request.resource.data.strategyTagIds) <=3 &&
        request.resource.data.strategyTagIds.all(tagId, get(/databases/$(db)/documents/tags/$(tagId)).data.type == 'strategy');

      allow delete: if isUser() && isOwner(resource.data);
      allow read: if true;
    }
  }
}
(Note: Firestore rules language does not have diff/hasOnly exactly like this; will refine in implementation. For now conceptual.)

## Repository Interfaces (Sketch)
- ConfigRepository: getActiveVersion(): Version
- TagRepository: listGodTags(), listStrategyTags(), getTag(id)
- DeckRepository: createDeck(dto), updateDeckStrategies(id, strategyIds), deleteDeck(id), listDecks(filter), getDeck(id)
- UserRepository: createUser(username), getUser(id)
- UsernameRepository: reserveUsername(username, userId)

DTO Example (create): { name, code, godTagId, strategyTagIds[] }

## Next Steps (Implementation Prep)
1. Translate pseudo security rules to valid Firestore rules syntax.
2. Define seed script for tags + optionally initial strategies.
3. Implement repositories in Flutter with abstraction layer for future Serverpod swap.

---
Revision 7 (Decisions consolidated; rules & repos draft).
