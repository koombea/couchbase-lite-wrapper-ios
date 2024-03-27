// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CouchbaseLiteWrapper",
    platforms: [.macOS(.v10_13),
                .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CouchbaseLiteWrapper",
            targets: ["CouchbaseLiteWrapper"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "CouchbaseLiteSwift",
                 url: "https://github.com/couchbase/couchbase-lite-ios.git",
                 .upToNextMajor(from: "3.0.0")),
        .package(name: "Nimble",
                url: "https://github.com/Quick/Nimble.git",
                .upToNextMajor(from: "9.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CouchbaseLiteWrapper",
            dependencies: ["CouchbaseLiteSwift"]),
        .testTarget(
            name: "CouchbaseLiteWrapperTests",
            dependencies: ["CouchbaseLiteWrapper", "Nimble", "CouchbaseLiteSwift"]),
    ]
)
