// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    products: [
        .library(
            name: "Scout",
            targets: ["Scout"]),
    ],
    targets: [
        .target(
            name: "Scout",
            dependencies: []),
        .testTarget(
            name: "ScoutTests",
            dependencies: ["Scout"]),
    ]
)
