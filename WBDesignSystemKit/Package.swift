// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WBDesignSystemKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WBDesignSystemKit",
            targets: ["WBDesignSystemKit"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WBDesignSystemKit"
        ),
        .testTarget(
            name: "WBDesignSystemKitTests",
            dependencies: ["WBDesignSystemKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
