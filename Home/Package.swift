// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "Home", targets: ["Home"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../CoreUI"),
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "CoreUI", package: "CoreUI"),
            ]
        ),
        .testTarget(name: "HomeTests", dependencies: ["Home"]),
    ]
)
