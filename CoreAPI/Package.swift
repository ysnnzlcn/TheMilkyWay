// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "CoreAPI",
    platforms: [.iOS(.v27)],
    products: [
        // Protocols only. Feature modules import this.
        .library(name: "CoreAPI", targets: ["CoreAPI"]),
        // Real network implementations. Only the app target imports this.
        .library(name: "CoreAPIImpl", targets: ["CoreAPIImpl"]),
        // Offline stubs for previews and tests. Only the app target and tests import this.
        .library(name: "CoreAPIStubs", targets: ["CoreAPIStubs"]),
    ],
    dependencies: [
        .package(path: "../CoreBase"),
    ],
    targets: [
        .target(
            name: "CoreAPI",
            dependencies: [.product(name: "CoreBase", package: "CoreBase")],
            path: "Sources/CoreAPI"
        ),
        .target(name: "CoreAPIImpl", dependencies: ["CoreAPI"], path: "Sources/CoreAPIImpl"),
        .target(name: "CoreAPIStubs", dependencies: ["CoreAPI"], path: "Sources/CoreAPIStubs"),
        .testTarget(
            name: "CoreAPITests",
            dependencies: ["CoreAPI", "CoreAPIImpl", "CoreAPIStubs"],
            resources: [.process("Fixtures")]
        ),
    ]
)
