// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceKitHipster",
    products: [
        .library(
            name:     "SourceKitHipster",
            targets: ["SourceKitHipster"]),
    ],
    dependencies: [
        // this is just a modmap tha exposes the sourcekitd headers so we can
        // import the appropriate types.
        .package(url: "https://github.com/SteveTrewick/CSourceKitD.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name        : "SourceKitHipster",
            dependencies: ["CSourceKitD"]),
        .testTarget(
            name        : "SourceKitHipsterTests",
            dependencies: ["SourceKitHipster"]),
    ]
)
