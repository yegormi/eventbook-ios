// swift-tools-version: 6.0

import PackageDescription
import Foundation

let package = Package(
    name: "eventbook-ios",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AccountFeature", targets: ["AccountFeature"]),
        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "APIClientLive", targets: ["APIClientLive"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "FacebookClient", targets: ["FacebookClient"]),
        .library(name: "GoogleClient", targets: ["GoogleClient"]),
        .library(name: "AuthFeature", targets: ["AuthFeature"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "KeychainClient", targets: ["KeychainClient"]),
        .library(name: "SessionClient", targets: ["SessionClient"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "SplashFeature", targets: ["SplashFeature"]),
        .library(name: "Styleguide", targets: ["Styleguide"]),
        .library(name: "SwiftHelpers", targets: ["SwiftHelpers"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
        .library(name: "TabsFeature", targets: ["TabsFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.2"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", branch: "releases/v17.4.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.21.0"),
    ],
    targets: [
        .target(
            name: "AccountFeature",
            dependencies: [
                "APIClientLive",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SessionClient",
                "SharedModels",
                "SwiftUIHelpers",
            ]
        ),
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
                "SessionClient",
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
            name: "AuthFeature",
            dependencies: [
                "APIClient",
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
                "FacebookClient",
                "GoogleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "KeychainClient",
                "Styleguide",
                "SharedModels",
                "SwiftHelpers",
                "SwiftUIHelpers",
                "SessionClient",
                .product(name: "Supabase", package: "supabase-swift"),
                "SupabaseSwiftClient",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "FacebookClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
                "SwiftHelpers",
                "SharedModels"
            ]
        ),
        .target(
            name: "GoogleClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "SwiftHelpers",
                "SharedModels"
            ]
        ),
        .target(
            name: "SwiftHelpers",
            dependencies: []
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "APIClientLive",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SwiftHelpers",
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
                "FacebookClient",
                "GoogleClient",
                "KeychainClient",
                "SharedModels",
                "SupabaseSwiftClient",
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
            name: "SupabaseSwiftClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                "SwiftHelpers",
                "SharedModels",
                .product(name: "Supabase", package: "supabase-swift"),
            ]
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
                "AccountFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SwiftHelpers",
                "HomeFeature",
                "Styleguide",
                "SwiftUIHelpers"
            ],
            resources: [.process("Resources")]
        ),
    ]
)
