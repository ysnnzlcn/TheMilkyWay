# CLAUDE.md

Guidance for Claude Code in this repository.

## Product

TheMilkyWay is a sample iOS app for browsing and searching NASA's image library
(`https://images-api.nasa.gov`, no API key).

## Status

The app is moving from UIKit and MVVM-C to SwiftUI and TCA. The current screens are UIKit, hosted by `LegacyRootView`
until they are replaced, and still bind to their view models with Combine. Networking uses async/await.

## Build

Open `TheMilkyWay.xcworkspace`, not the `.xcodeproj`: the workspace is what connects the local packages.

- **Minimum iOS:** 27.0. Never add `#available` checks for iOS 27 or older.
- **Swift:** tools version 6.4, Swift 6 language mode with strict concurrency.
- **Schemes:** `TheMilkyWayDebug` (development and tests), `TheMilkyWay` (Release).
- **Per-build values** (bundle id, display name) live in `Configurations/<Name>.xcconfig`. Never set them in the
  target's build settings.
- App and test targets use synchronized folders, so new files need no project file edits.

```bash
swiftlint
xcodebuild -workspace TheMilkyWay.xcworkspace -scheme TheMilkyWayDebug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro Max' test
```

CI runs SwiftLint, build and tests from `.github/workflows/ci.yml`, with compiler warnings as errors. SwiftLint
warnings stay allowed until the UIKit code is replaced, then CI moves to `--strict`.

## Modules

Every module is a local Swift package, and packages reference each other with `../` paths.

```
TheMilkyWay (app)   only target importing *Impl (as `private import`), wires it in AppInterface
  ↑
Home                image list and details screens
  ↑
CoreUI              reusable UIKit components, error text
CoreAPI | Impl | Stubs   API protocols / NASA over URLSession / offline stubs
CoreBase            models, AppError, Log, Global… helpers (no dependencies)
```

- Response models end in `DTO`, request models in `Request`. NASA's raw response shape stays inside `CoreAPIImpl`.
- The API is chosen once at launch in `AppInterface.apiEnvironment(for:)`: every build uses NASA's live API.
  Stubs serve tests and previews.
- Dates and other shown values are formatted once in CoreBase `Global…` helpers, never inline.
- Log with `Log` from CoreBase, never `print`. Never log personal data.

## Conventions

- The app uses the SwiftUI `App` lifecycle with `WindowGroup`. Do not add a `UIWindow` or `SceneDelegate`.
- Async APIs and services return `Result<T, AppError>`. Error text is produced only in CoreUI `AppError+Strings`.
- Keep comments short.
- Do not build ahead of the current migration phase.

## Git

Claude never runs git commands that change this repository: no commit, branch, tag, fetch, pull, stash or push. Edit
files in the working tree and let the maintainer review and commit.
