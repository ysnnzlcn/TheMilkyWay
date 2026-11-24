// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreAPI",
    platforms: [.iOS(.v27)],
    products: [
        // Protocols only. Feature modules import this.
        .library(name: "CoreAPI", targets: ["CoreAPI"]),
        // Real network implementations. Only the app target imports this.
        .library(name: "CoreAPIImpl", targets: ["CoreAPIImpl"]),
        // Offline stubs. Only the app target and tests import this.
        .library(name: "CoreAPIStubs", targets: ["CoreAPIStubs"]),
        // Test doubles. Only test targets import this, so they never ship in the app.
        .library(name: "CoreAPIMocks", targets: ["CoreAPIMocks"]),
    ],
    dependencies: [
        .package(path: "../CoreBase"),
    ],
    targets: [
        .target(
            name: "CoreAPI",
            dependencies: [.product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreAPI",
            swiftSettings: strict
        ),
        .target(name: "CoreAPIImpl", dependencies: ["CoreAPI"], path: "Sources/CoreAPIImpl", swiftSettings: strict),
        .target(name: "CoreAPIStubs", dependencies: ["CoreAPI"], path: "Sources/CoreAPIStubs", swiftSettings: strict),
        .target(name: "CoreAPIMocks", dependencies: ["CoreAPI"], path: "Sources/CoreAPIMocks", swiftSettings: strict),
        .testTarget(
            name: "CoreAPITests",
            dependencies: ["CoreAPI", "CoreAPIImpl", "CoreAPIStubs"],
            resources: [.process("Fixtures")],
            swiftSettings: strict
        ),
    ]
)
