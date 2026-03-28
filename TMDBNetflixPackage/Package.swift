// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMDBNetflixFeature",
    platforms: [.iOS("26.0")],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TMDBNetflixFeature",
            targets: ["TMDBNetflixFeature"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TMDBNetflixFeature",
            dependencies: [
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),
        .testTarget(
            name: "TMDBNetflixFeatureTests",
            dependencies: [
                "TMDBNetflixFeature"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
