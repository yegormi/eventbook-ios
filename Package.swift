// swift-tools-version: 6.0

import PackageDescription
import Foundation

let package = Package(
    name: "eventbook-ios",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "APIClientLive", targets: ["APIClientLive"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "TabsFeature", targets: ["TabsFeature"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "Styleguide", targets: ["Styleguide"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                "SharedModels"
            ]
        ),
        .target(
            name: "APIClientLive",
            dependencies: [
                "APIClient",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "TabsFeature",
            ]
        ),
        .target(
            name: "Helpers",
            dependencies: []
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "APIClientLive",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Helpers",
                "SharedModels",
                "Styleguide",
                "SwiftUIHelpers"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        ),
        .target(
            name: "Styleguide",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SwiftUIHelpers",
            dependencies: [
                "Styleguide",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "TabsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Helpers",
                "HomeFeature",
                "Styleguide",
                "SwiftUIHelpers"
            ],
            resources: [.process("Resources")]
        ),
    ]
)
