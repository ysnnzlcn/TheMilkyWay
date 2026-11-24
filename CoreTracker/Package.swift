// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreTracker",
    platforms: [.iOS(.v27)],
    products: [
        // Events and the service protocol. Feature modules and CoreUI import this.
        .library(name: "CoreTracker", targets: ["CoreTracker"]),
        // The live service and its providers. Only the app target imports this.
        .library(name: "CoreTrackerImpl", targets: ["CoreTrackerImpl"]),
        // Test doubles. Only test targets import this, so they never ship in the app.
        .library(name: "CoreTrackerMocks", targets: ["CoreTrackerMocks"]),
    ],
    dependencies: [
        .package(path: "../CoreBase"),
    ],
    targets: [
        .target(name: "CoreTracker", path: "Sources/CoreTracker", swiftSettings: strict),
        .target(
            name: "CoreTrackerImpl",
            dependencies: ["CoreTracker", .product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreTrackerImpl",
            swiftSettings: strict
        ),
        .target(name: "CoreTrackerMocks", dependencies: ["CoreTracker"], path: "Sources/CoreTrackerMocks", swiftSettings: strict),
        .testTarget(
            name: "CoreTrackerTests",
            dependencies: ["CoreTracker", "CoreTrackerImpl"],
            swiftSettings: strict
        ),
    ]
)
