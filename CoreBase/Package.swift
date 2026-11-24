// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "CoreBase",
    platforms: [.iOS(.v27)],
    products: [
        .library(name: "CoreBase", targets: ["CoreBase"]),
    ],
    targets: [
        .target(name: "CoreBase"),
        .testTarget(name: "CoreBaseTests", dependencies: ["CoreBase"]),
    ]
)
