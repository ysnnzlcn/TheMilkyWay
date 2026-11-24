// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "CoreUI",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreUI", targets: ["CoreUI"]),
    ],
    dependencies: [
        .package(path: "../Core"),
    ],
    targets: [
        .target(name: "CoreUI", dependencies: [.product(name: "Core", package: "Core")]),
        .testTarget(name: "CoreUITests", dependencies: ["CoreUI"]),
    ]
)
