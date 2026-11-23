# CLAUDE.md

Guidance for Claude Code in this repository.

## Product

TheMilkyWay is a sample iOS app for browsing and searching NASA's image library
(`https://images-api.nasa.gov`, no API key).

## Status

The app is moving from UIKit, MVVM-C and Combine to SwiftUI, TCA and Swift Concurrency. The current screens are UIKit,
hosted by `LegacyRootView` until they are replaced. Swift 5 language mode stays on until the concurrency migration ends.

## Build

Open `TheMilkyWay.xcworkspace`, not the `.xcodeproj`: the workspace is what connects the local packages.

- **Minimum iOS:** 27.0. Never add `#available` checks for iOS 27 or older.
- **Swift tools:** 6.4.
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

- `Core`: networking, NASA service and models
- `CoreUI`: reusable UIKit components
- `Home`: image list and details screens

## Conventions

- The app uses the SwiftUI `App` lifecycle with `WindowGroup`. Do not add a `UIWindow` or `SceneDelegate`.
- Keep comments short.
- Do not build ahead of the current migration phase.

## Git

Claude never runs git commands that change this repository: no commit, branch, tag, fetch, pull, stash or push. Edit
files in the working tree and let the maintainer review and commit.
