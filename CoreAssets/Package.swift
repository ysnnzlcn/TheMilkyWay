// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "CoreAssets",
    defaultLocalization: "en",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreAssets", targets: ["CoreAssets"]),
    ],
    targets: [
        .target(name: "CoreAssets", resources: [.process("Resources")]),
        .testTarget(name: "CoreAssetsTests", dependencies: ["CoreAssets"]),
    ]
)
