// swift-tools-version: 6.4

import PackageDescription

/// Our own code builds with warnings as errors (set per target: on the command line it would reach TCA too).
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "CoreBase",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreBase", targets: ["CoreBase"]),
    ],
    targets: [
        .target(name: "CoreBase", swiftSettings: strict),
        .testTarget(name: "CoreBaseTests", dependencies: ["CoreBase"], swiftSettings: strict),
    ]
)
