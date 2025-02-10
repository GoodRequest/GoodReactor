// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/GoodRequest/GoodLogger.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.5.2")
    ],
    targets: [
        .target(
            name: "GoodReactor",
            dependencies: [
                .target(name: "GoodReactorMacros"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "GoodLogger", package: "GoodLogger")
            ],
            path: "./Sources/GoodReactor",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("BodyMacros"),
                .enableExperimentalFeature("BodyMacros")
            ]
        ),
        .macro(
            name: "GoodReactorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "./Macros",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
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
