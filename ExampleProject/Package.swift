// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let environment = ProcessInfo.processInfo.environment,
    tagRequirement: Package.Dependency.Requirement? = environment["TRAVIS_TAG"].flatMap(Version.init).flatMap { .exact($0) },
    branchRequirement: Package.Dependency.Requirement? = environment["TRAVIS_BRANCH"] == "master" ? .branch("master") : nil,
    commitRequirement: Package.Dependency.Requirement? = environment["TRAVIS_COMMIT"].flatMap { .revision($0) },
    headRequirement: Package.Dependency.Requirement = .branch("HEAD"),
    requirement = tagRequirement ?? branchRequirement ?? commitRequirement ?? headRequirement

let package = Package(
    name: "ExampleProject",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ExampleProject",
            targets: ["ExampleProject"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bgerstle/Scout", requirement)
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ExampleProject",
            dependencies: []),
        .testTarget(
            name: "ExampleProjectTests",
            dependencies: ["ExampleProject", "Scout"]),
    ]
)
