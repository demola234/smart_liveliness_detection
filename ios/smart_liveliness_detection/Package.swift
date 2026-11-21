// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smart_liveliness_detection",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "smart-liveliness-detection", targets: ["smart_liveliness_detection"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "smart_liveliness_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [],
            linkerSettings: [
                .linkedFramework("ARKit")
            ]
        )
    ]
)
