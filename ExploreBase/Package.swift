// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "ExploreBase",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "ExploreBase", targets: ["ExploreBase"]),
    ],
    dependencies: [
        .package(path: "../CoreAPI"),
        .package(path: "../CoreAssets"),
        .package(path: "../CoreBase"),
        .package(path: "../CoreUI"),
        .package(path: "../ImageDetails"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.26.2")),
    ],
    targets: [
        .target(
            name: "ExploreBase",
            dependencies: [
                .product(name: "CoreAPI", package: "CoreAPI"),
                .product(name: "CoreAssets", package: "CoreAssets"),
                .product(name: "CoreBase", package: "CoreBase"),
                .product(name: "CoreUI", package: "CoreUI"),
                .product(name: "ImageDetails", package: "ImageDetails"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: strict
        ),
        .testTarget(
            name: "ExploreBaseTests",
            dependencies: [
                "ExploreBase",
                .product(name: "CoreAPI", package: "CoreAPI"),
                .product(name: "CoreAPIMocks", package: "CoreAPI"),
                .product(name: "CoreBase", package: "CoreBase"),
                .product(name: "ImageDetails", package: "ImageDetails"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: strict
        ),
    ]
)
