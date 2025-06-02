// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "Feature", targets: ["Feature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/Kolos65/Mockable.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.9.0")),
    ],
    targets: [
        .target(
            name: "Feature",
            dependencies: commonDependencies() + [
                .product(name: "Kingfisher", package: "Kingfisher"),
                "Networking",
                "UIComponents",
            ],
            swiftSettings: commonSwiftSettings(languageMode: .v6)
        ),
        .target(
            name: "Networking",
            dependencies: commonDependencies() + [
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            swiftSettings: commonSwiftSettings(languageMode: .v6)
        ),
        .target(
            name: "UIComponents"
        ),
    ]
)

func commonSwiftSettings(languageMode: SwiftLanguageMode) -> [SwiftSetting] {
    [
        .define("MOCKING", .when(configuration: .debug)),
        .swiftLanguageMode(languageMode),
    ]
}

func commonDependencies() -> [Target.Dependency] {
    [
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Mockable", package: "Mockable"),
    ]
}

