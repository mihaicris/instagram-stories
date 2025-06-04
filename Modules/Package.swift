// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Modules",
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "Stories", targets: ["Stories"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
    .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.3.0")),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMajor(from: "1.9.0")),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.0"),
  ],
  targets: [
    .target(
      name: "Stories",
      dependencies: commonDependencies() + [
        .product(name: "Kingfisher", package: "Kingfisher"),
        "Networking",
        "UIComponents",
      ],
      resources: [
        .process("Resources/")
      ],
      swiftSettings: commonSwiftSettings(languageMode: .v6),
      plugins: commonPlugins()
    ),
    .target(
      name: "Networking",
      dependencies: commonDependencies() + [
        .product(name: "Alamofire", package: "Alamofire")
      ],
      swiftSettings: commonSwiftSettings(languageMode: .v6),
      plugins: commonPlugins()
    ),
    .target(
      name: "UIComponents",
      dependencies: [],
      swiftSettings: commonSwiftSettings(languageMode: .v6),
      plugins: commonPlugins(),
    ),
  ]
)

func commonSwiftSettings(languageMode: SwiftLanguageMode) -> [SwiftSetting] {
  [
    //       .define("MOCKING", .when(configuration: .debug)),
    .swiftLanguageMode(languageMode)
  ]
}

func commonDependencies() -> [Target.Dependency] {
  [
    .product(name: "Dependencies", package: "swift-dependencies")
    //      .product(name: "Mockable", package: "Mockable"),
  ]
}

func commonPlugins() -> [Target.PluginUsage] {
  [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
  ]
}
