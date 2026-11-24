// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "ImageDetails",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "ImageDetails", targets: ["ImageDetails"]),
    ],
    dependencies: [
        .package(path: "../CoreAssets"),
        .package(path: "../CoreBase"),
        .package(path: "../CoreLogic"),
        .package(path: "../CoreTracker"),
        .package(path: "../CoreUI"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.26.2")),
    ],
    targets: [
        .target(
            name: "ImageDetails",
            dependencies: [
                .product(name: "CoreAssets", package: "CoreAssets"),
                .product(name: "CoreBase", package: "CoreBase"),
                .product(name: "CoreLogic", package: "CoreLogic"),
                .product(name: "CoreTracker", package: "CoreTracker"),
                .product(name: "CoreUI", package: "CoreUI"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: strict
        ),
        .testTarget(
            name: "ImageDetailsTests",
            dependencies: [
                "ImageDetails",
                .product(name: "CoreBase", package: "CoreBase"),
                .product(name: "CoreLogicMocks", package: "CoreLogic"),
                .product(name: "CoreTracker", package: "CoreTracker"),
                .product(name: "CoreTrackerMocks", package: "CoreTracker"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: strict
        ),
    ]
)
