// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoodReactor",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GoodReactor",
            targets: ["GoodReactor"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.8.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GoodReactor",
            dependencies: ["CombineExt"],
            path: "./Sources/GoodReactor"
        ),
        .testTarget(
            name: "GoodReactorTests",
            dependencies: ["GoodReactor"]),
    ]
)
