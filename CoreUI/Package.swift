// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreUI",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreUI", targets: ["CoreUI"]),
    ],
    dependencies: [
        .package(path: "../CoreAssets"),
        .package(path: "../CoreBase"),
    ],
    targets: [
        .target(
            name: "CoreUI",
            dependencies: [
                .product(name: "CoreAssets", package: "CoreAssets"),
                .product(name: "CoreBase", package: "CoreBase"),
            ],
            swiftSettings: strict
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: [
                "CoreUI",
                .product(name: "CoreAssets", package: "CoreAssets"),
                .product(name: "CoreBase", package: "CoreBase"),
            ],
            swiftSettings: strict
        ),
    ]
)
