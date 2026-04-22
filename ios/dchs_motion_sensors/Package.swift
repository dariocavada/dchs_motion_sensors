// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dchs_motion_sensors",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "dchs-motion-sensors", targets: ["dchs_motion_sensors"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "dchs_motion_sensors",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
