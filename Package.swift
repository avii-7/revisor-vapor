// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "RevisorVapor",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/jwt.git", .upToNextMajor(from: "5.1.2")),
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.12.0")),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", .upToNextMajor(from: "2.10.1")),
        .package(url: "https://github.com/open-spaced-repetition/swift-fsrs.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "RevisorVapor",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FSRS", package: "swift-fsrs")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "RevisorVaporTests",
            dependencies: [
                .target(name: "RevisorVapor"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
