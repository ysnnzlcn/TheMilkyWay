# CLAUDE.md

Guidance for Claude Code in this repository.

## Product

TheMilkyWay is a sample iOS app for browsing and searching NASA's image library
(`https://images-api.nasa.gov`, no API key).

## Status

SwiftUI and TCA throughout, networking with async/await. Explore, Image details and Favorites (SwiftData) are built;
an on-device AI explanation comes next.

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
TheMilkyWay (app)   AppState → MainTabBar root; only target importing *Impl (as `private import`), wires AppInterface
  ↑
ExploreBase         Explore tab: paged image grid with search
FavoritesBase       Favorites tab: saved images, updated live
  ↑
ImageDetails        the image details screen with the favorite button, pushed from both tabs
  ↑
CoreUI              DS tokens, SwiftUI components, image loader, error text
CoreLogic | Impl | Mocks   service protocols / live services (favorites in SwiftData) / test doubles
CoreAPI | Impl | Stubs | Mocks   API protocols / NASA over URLSession / offline stubs / test doubles
CoreAssets          String Catalogs + `L10n`, `SystemImage`
CoreBase            models, AppError, Log, Global… helpers (no dependencies)
```

- Response models end in `DTO`, request models in `Request`. NASA's raw response shape stays inside `CoreAPIImpl`.
- The API is chosen once at launch in `AppInterface.apiEnvironment(for:)`: every build uses NASA's live API.
  `CoreAPIStubs` is the offline switch: change the `.debug` line there to work without the network (don't commit it).
- Test doubles live in `*Mocks` targets (`CoreAPIMocks`, `CoreLogicMocks`), which only test targets depend on, so
  they never ship in the app. A new protocol gets its mock there.
- `AppError` is grouped by where it happened: `.network(kind)`, `.storage`, `.unexpected`. Cancellation never
  reaches a screen: a cancelled effect's answer is dropped by TCA, so reducers don't check for it.
- SwiftData lives only in `CoreLogicImpl`: `@Model` records are internal and mapped to DTOs before they leave the
  service. The service is a plain actor that creates its `ModelContainer` and `ModelContext` on first use, on the
  actor (never on the main thread, never at launch), not a `@ModelActor`, whose default executor ran on the main
  thread on iOS 27. The schema is versioned (`FavoritesSchemaV1` + `FavoritesMigrationPlan`): a model change adds a
  new version and a migration stage. Services with state are actors.
- Shared data that several screens show (favorites) is followed as an `AsyncStream` of the whole list, never read
  once, so a change on one screen shows on the others.
- Each tab owns its `NavigationStack`; tapping the open tab sends its `popToRoot`.
- User-facing text comes from `L10n` (CoreAssets), never a literal in a view. One catalog per owner: `coreui`,
  `errors` (read only by `AppError+Strings`), one per feature. Add the catalog entry, then its `L10n` accessor.
- SF Symbols are `SystemImage` cases, drawn with `Image(systemImage:)` / `Label(_:systemImage:)`.
- Views use `DS` tokens, never raw colors or sizes. Text uses `.textStyle(...)` (`DS.TextStyle`, the system font at
  Dynamic Type sizes), never `.font(...)`.
- Every screen sits in `BaseContentView(mode:)`; `.loading` dims the content under a spinner and blocks taps, so
  screens never draw their own loading state (a next page's spinner is part of its list). A failed first load shows
  `.headerMessage(...)` with "Try again"; any later failure keeps what is shown and uses `.toast(model:)`. Toasts
  never have buttons. How an error looks (copy, icon, toast style) is chosen only in `AppError+Strings`.
- `DS` holds only the tokens in use; add one with its first user.
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
- The app uses the SwiftUI `App` lifecycle with `WindowGroup`. Do not add a `UIWindow` or `SceneDelegate`. While
  unit tests run, the app skips `AppInterface.setup` and shows nothing.
- No UI test target: UI flows are checked in the simulator (see the reducer tests for logic).
- Async APIs and services return `Result<T, AppError>`. Error text is produced only in CoreUI `AppError+Strings`.
- Keep comments short.
- Do not build ahead of the current migration phase.

## Git

Claude never runs git commands that change this repository: no commit, branch, tag, fetch, pull, stash or push. Edit
files in the working tree and let the maintainer review and commit.
