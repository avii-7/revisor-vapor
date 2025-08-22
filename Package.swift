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
    ],
    targets: [
        .executableTarget(
            name: "RevisorVapor",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt")
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
