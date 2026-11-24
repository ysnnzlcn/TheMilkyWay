# CLAUDE.md

Guidance for Claude Code in this repository.

## Product

TheMilkyWay is a sample iOS app for browsing and searching NASA's image library
(`https://images-api.nasa.gov`, no API key).

## Status

SwiftUI and TCA throughout, networking with async/await. Explore and Image details are built; Favorites (SwiftData)
and an on-device AI explanation come next.

## Build

Open `TheMilkyWay.xcworkspace`, not the `.xcodeproj`: the workspace is what connects the local packages.

- **Minimum iOS:** 27.0. Never add `#available` checks for iOS 27 or older.
- **Swift:** tools version 6.4, Swift 6 language mode with strict concurrency.
- **Schemes:** `TheMilkyWayDebug` (development and tests), `TheMilkyWay` (Release).
- **Per-build values** (bundle id, display name) live in `Configurations/<Name>.xcconfig`. Never set them in the
  target's build settings.
- App and test targets use synchronized folders, so new files need no project file edits.

```bash
swiftlint lint --strict
xcodebuild -workspace TheMilkyWay.xcworkspace -scheme TheMilkyWayDebug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro Max' -skipMacroValidation test
```

CI runs strict SwiftLint, build and tests from `.github/workflows/ci.yml`. SwiftLint is pinned there
(`SWIFTLINT_VERSION`); use the same version locally, and change both together. Compiler warnings are errors in our own
code, set per target: `strict` swift settings in every `Package.swift` and the project's build settings. Never pass
`SWIFT_TREAT_WARNINGS_AS_ERRORS` on the command line: it reaches TCA's packages and fails the build. A new package or
target gets `swiftSettings: strict`.

## Modules

Every module is a local Swift package, and packages reference each other with `../` paths.

```
TheMilkyWay (app)   AppState root; only target importing *Impl (as `private import`), wires it in AppInterface
  ↑
ExploreBase         Explore: paged image grid with search
  ↑
ImageDetails        the image details screen, pushed from features
  ↑
CoreUI              DS tokens, SwiftUI components, image loader, error text
CoreAPI | Impl | Stubs   API protocols / NASA over URLSession / offline stubs
CoreAssets          String Catalogs + `L10n`, `SystemImage`
CoreBase            models, AppError, Log, Global… helpers (no dependencies)
```

- Response models end in `DTO`, request models in `Request`. NASA's raw response shape stays inside `CoreAPIImpl`.
- The API is chosen once at launch in `AppInterface.apiEnvironment(for:)`: every build uses NASA's live API.
  Stubs serve tests.
- User-facing text comes from `L10n` (CoreAssets), never a literal in a view. One catalog per owner: `coreui`,
  `errors` (read only by `AppError+Strings`), one per feature. Add the catalog entry, then its `L10n` accessor.
- SF Symbols are `SystemImage` cases, drawn with `Image(systemImage:)` / `Label(_:systemImage:)`.
- Views use `DS` tokens, never raw colors or sizes. Text uses `.textStyle(...)` (`DS.TextStyle`, the system font at
  Dynamic Type sizes), never `.font(...)`.
- Every screen sits in `BaseContentView(mode:)`; `.loading` dims the content under a spinner and blocks taps, so
  screens never draw their own loading state (a next page's spinner is part of its list). A failed screen load shows `.headerMessage(...)` with "Try again"; other
  errors show `.toast(model:)`. Toasts never have buttons.
- Network images use `RemoteImage` (our `ImageLoader`), never `AsyncImage`.
- Previews only for CoreUI components, not for screens.
- Dates and other shown values are formatted once in CoreBase `Global…` helpers, never inline.
- Log with `Log` from CoreBase, never `print`. Never log personal data.

## Conventions

- Every screen is a TCA `@Reducer` named `<Name>Core` with a `<Name>View`. State: view state (`viewMode`, errors)
  first, then information state. Actions are named `on<Event>`; effects live in a `private extension` under
  `// MARK: Api calls`. Push navigation uses `StackState` with a `@Reducer enum Path`.
- A feature module declares what it needs in `<Module>+Interface.swift` (`exploreBaseImports`), which the app sets
  in `AppInterface+<Module>.swift`; reducers read it through `@DependencyClient`s in `<Module>+Dependencies.swift`.
- Reducer tests use Swift Testing with `TestStore` (exhaustive), built by a `makeTestStore` helper; every action has
  a test. Time-based effects use a `TestClock`.
- No complex UI in screens: cards, grids and messages are CoreUI components.
- The app uses the SwiftUI `App` lifecycle with `WindowGroup`. Do not add a `UIWindow` or `SceneDelegate`.
- Async APIs and services return `Result<T, AppError>`. Error text is produced only in CoreUI `AppError+Strings`.
- Keep comments short.
- Do not build ahead of the current migration phase.

## Git

Claude never runs git commands that change this repository: no commit, branch, tag, fetch, pull, stash or push. Edit
files in the working tree and let the maintainer review and commit.
