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
            name: "NewReactor",
            targets: ["NewReactor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.8.1"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/GoodRequest/GoodLogger.git", .upToNextMajor(from: "1.1.0"))
    ],
    targets: [
        .target(
            name: "GoodReactor",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "./Sources/GoodReactor",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "NewReactor",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "GoodLogger", package: "GoodLogger")
            ],
            path: "./Sources/NewReactor",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "GoodReactorTests",
            dependencies: ["GoodReactor"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "NewReactorTests",
            dependencies: ["NewReactor"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
