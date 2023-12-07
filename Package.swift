// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TCASharedState",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "TCASharedState",
            targets: ["TCASharedState"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            branch: "observation-beta"
        )
    ],
    targets: [
        .target(
            name: "TCASharedState",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "TCASharedStateTests",
            dependencies: ["TCASharedState"]
        ),
    ]
)
