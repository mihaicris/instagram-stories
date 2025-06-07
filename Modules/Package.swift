// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "FeatureStories", targets: ["FeatureStories"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Persistence", targets: ["Persistence"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        // .package(url: "https://github.com/Kolos65/Mockable.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.9.0")),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.0"),
    ],
    targets: [
        .target(
            name: "FeatureStories",
            dependencies: dependencies() + [
                .product(name: "Kingfisher", package: "Kingfisher"),
                "Networking",
                "Persistence",
                "UIComponents",
            ],
            resources: [
                .process("Resources/")
            ],
            swiftSettings: settings(languageMode: .v6),
            plugins: plugins()
        ),
        .target(
            name: "Networking",
            dependencies: dependencies() + [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            swiftSettings: settings(languageMode: .v6),
            plugins: plugins()
        ),
        .target(
            name: "Persistence",
            dependencies: dependencies(),
            swiftSettings: settings(languageMode: .v6),
            plugins: plugins()
        ),
        .target(
            name: "UIComponents",
            dependencies: [],
            swiftSettings: settings(languageMode: .v6),
            plugins: plugins(),
        ),
    ]
)

func settings(languageMode: SwiftLanguageMode) -> [SwiftSetting] {
    [
        //       .define("MOCKING", .when(configuration: .debug)),
        .swiftLanguageMode(languageMode)
    ]
}

func dependencies() -> [Target.Dependency] {
    [
        .product(name: "Dependencies", package: "swift-dependencies")
        //      .product(name: "Mockable", package: "Mockable"),
    ]
}

func plugins() -> [Target.PluginUsage] {
    [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
    ]
}
