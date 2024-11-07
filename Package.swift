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
        .library(name: "GoogleClient", targets: ["GoogleClient"]),
        .library(name: "AuthFeature", targets: ["AuthFeature"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "SessionClient", targets: ["SessionClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "SplashFeature", targets: ["SplashFeature"]),
        .library(name: "Styleguide", targets: ["Styleguide"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
        .library(name: "TabsFeature", targets: ["TabsFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.4.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
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
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                ),
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AuthFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SplashFeature",
                "TabsFeature",
            ]
        ),
        .target(
            name: "GoogleClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Helpers",
                "SharedModels"
            ]
        ),
        .target(
            name: "AuthFeature",
            dependencies: [
                "APIClient",
                "GoogleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Helpers",
                "Styleguide",
                "SharedModels",
                "KeychainClient",
                "SessionClient",
            ],
            resources: [.process("Resources")]
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
            name: "KeychainClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "SessionClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                "KeychainClient",
                "SharedModels",
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        ),
        .target(
            name: "SplashFeature",
            dependencies: [],
            resources: [.process("Resources")]
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
