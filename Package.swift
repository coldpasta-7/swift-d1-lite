// swift-tools-version: 6.2
import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-d1-lite",
  platforms: [.macOS(.v26)],
  products: [
    .library(
      name: "D1Lite",
      targets: ["D1Lite"],
    ),
    .library(
      name: "D1LiteAsyncHTTPClient",
      targets: ["D1LiteAsyncHTTPClient"],
    ),
    .library(
      name: "D1LiteSQLite",
      targets: ["D1LiteSQLite"],
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0"),
    .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "603.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.0"),
  ],
  targets: [
    .target(
      name: "D1Lite",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOEmbedded", package: "swift-nio"),
        .product(name: "SQLKit", package: "sql-kit"),
        .product(name: "SQLiteKit", package: "sqlite-kit"),
        .target(name: "D1LiteMacro"),
      ],
      swiftSettings: swiftSettings,
    ),
    .testTarget(
      name: "D1LiteTests",
      dependencies: [
        .target(name: "D1Lite")
      ],
      swiftSettings: swiftSettings,
    ),

    .macro(
      name: "D1LiteMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "D1LiteMacroTests",
      dependencies: [
        .target(name: "D1LiteMacro"),
        .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ],
      swiftSettings: swiftSettings
    ),

    .target(
      name: "D1LiteAsyncHTTPClient",
      dependencies: [
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "Configuration", package: "swift-configuration"),
        .product(name: "NIOCore", package: "swift-nio"),
        .target(name: "D1Lite"),
      ],
      swiftSettings: swiftSettings,
    ),
    .testTarget(
      name: "D1LiteAsyncHTTPClientTests",
      dependencies: [
        .target(name: "D1LiteAsyncHTTPClient")
      ],
      swiftSettings: swiftSettings,
    ),

    .target(
      name: "D1LiteSQLite",
      dependencies: [
        .product(name: "SQLiteNIO", package: "sqlite-nio"),
        .product(name: "SystemPackage", package: "swift-system"),
        .product(name: "Configuration", package: "swift-configuration"),
        .target(name: "D1Lite"),
      ],
      swiftSettings: swiftSettings,
    ),
    .testTarget(
      name: "D1LiteSQLiteTests",
      dependencies: [
        .target(name: "D1LiteSQLite")
      ],
      swiftSettings: swiftSettings,
    ),
  ],
  swiftLanguageModes: [.v6],
)
var swiftSettings: [SwiftSetting] {
  [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("NonescapableTypes"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
  ]
}
