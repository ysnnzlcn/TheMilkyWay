// swift-tools-version: 6.4

import PackageDescription

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
            ]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: [
                "CoreUI",
                .product(name: "CoreAssets", package: "CoreAssets"),
                .product(name: "CoreBase", package: "CoreBase"),
            ]
        ),
    ]
)
