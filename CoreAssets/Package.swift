// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreAssets",
    defaultLocalization: "en",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreAssets", targets: ["CoreAssets"]),
    ],
    targets: [
        .target(name: "CoreAssets", resources: [.process("Resources")], swiftSettings: strict),
        .testTarget(name: "CoreAssetsTests", dependencies: ["CoreAssets"], swiftSettings: strict),
    ]
)
