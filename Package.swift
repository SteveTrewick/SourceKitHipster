// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceKitHipster",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SourceKitHipster",
            targets: ["SourceKitHipster"]),
    ],
    dependencies: [
        // this is just a modmao tha exposes the sourcekitd headers so we can the
        // appropriate types imported.
        .package(url: "https://github.com/SteveTrewick/CSourceKitD.git", from: "1.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SourceKitHipster",
            dependencies: ["CSourceKitD"]),
        .testTarget(
            name: "SourceKitHipsterTests",
            dependencies: ["SourceKitHipster"]),
    ]
)
