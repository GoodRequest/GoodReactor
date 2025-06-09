// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoodReactor",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "GoodReactor",
            targets: ["GoodReactor"]
        ),
        .library(
            name: "LegacyReactor",
            targets: ["LegacyReactor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.8.1"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3"))
    ],
    targets: [
        .target(
            name: "GoodReactor",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "./Sources/GoodReactor",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "LegacyReactor",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "./Sources/LegacyReactor",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "GoodReactorTests",
            dependencies: ["GoodReactor"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "GoodCoordinatorTests",
            dependencies: ["LegacyReactor"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
