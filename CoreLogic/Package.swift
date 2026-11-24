// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreLogic",
    platforms: [.iOS(.v27)],
    products: [
        // Service protocols. Feature modules import this.
        .library(name: "CoreLogic", targets: ["CoreLogic"]),
        // Live services. Only the app target imports this.
        .library(name: "CoreLogicImpl", targets: ["CoreLogicImpl"]),
        // Test doubles. Only test targets import this, so they never ship in the app.
        .library(name: "CoreLogicMocks", targets: ["CoreLogicMocks"]),
    ],
    dependencies: [
        .package(path: "../CoreBase"),
    ],
    targets: [
        .target(
            name: "CoreLogic",
            dependencies: [.product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreLogic",
            swiftSettings: strict
        ),
        .target(
            name: "CoreLogicImpl",
            dependencies: ["CoreLogic", .product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreLogicImpl",
            swiftSettings: strict
        ),
        .target(
            name: "CoreLogicMocks",
            dependencies: ["CoreLogic", .product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreLogicMocks",
            swiftSettings: strict
        ),
        .testTarget(
            name: "CoreLogicTests",
            dependencies: ["CoreLogic", "CoreLogicImpl", .product(name: "CoreBase", package: "CoreBase")],
            swiftSettings: strict
        ),
    ]
)
